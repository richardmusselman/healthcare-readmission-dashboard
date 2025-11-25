library(shiny)
library(tidyverse)
library(bslib)
library(RSQLite)

#1. Database Setup

# Connect to a temporary local SQL database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Generate Mock Data
set.seed(2026) 
raw_data = tibble(
  Hospital_Name = rep(c("Capital Health Trenton", "RWJ Hamilton", "Virtua Marlton", "Cooper University Health"), each = 50),
  Month = as.character(rep(seq(as.Date("2024-01-01"), by = "month", length.out = 50), 4)),
  Department = sample(c("Cardiac Care", "Oncology", "Emergency", "Pediatrics"), 200, replace = TRUE),
  Readmission_Rate = runif(200, min = 2, max = 18), 
  Avg_Cost_Per_Stay = round(rnorm(200, mean = 12000, sd = 3000), 2)
)

# Write data into SQL database as table named "HOSPITAL_METRICS"
dbWriteTable(con, "HOSPITAL_METRICS", raw_data)

#2. UI
ui = page_sidebar(
  title = "NJ Hospital Metrics: SQL-Integrated Dashboard",
  theme = bs_theme(bootswatch = "minty"), 
  
  sidebar = sidebar(
    selectInput(
      inputId = "dept_choice",
      label = "Select Department:",
      choices = dbGetQuery(con, "SELECT DISTINCT Department FROM HOSPITAL_METRICS")$Department,
      selected = "Cardiac Care"
    ),
    
    sliderInput(
      inputId = "cost_filter",
      label = "Filter: Max Cost per Stay ($)",
      min = 5000, max = 20000, value = 18000, step = 500
    ),
    
    markdown("---"),
    downloadButton("downloadData", "Download Filtered Data"),
    markdown("**Tech Stack:** R, Shiny, SQL (SQLite), Tidyverse")
  ),
  
  card(
    card_header("Readmission Rate Trends"),
    plotOutput(outputId = "trendPlot")
  ),
  card(
    card_header("Detailed Data View"),
    tableOutput(outputId = "dataTable")
  )
)

#3. SERVER
server <- function(input, output) {
  
  filtered_data <- reactive({
    
    query <- "SELECT * FROM HOSPITAL_METRICS WHERE Department = ? AND Avg_Cost_Per_Stay <= ?"
    
    data_from_db <- dbGetQuery(con, query, params = list(input$dept_choice, input$cost_filter))
    
    data_from_db$Month <- as.Date(data_from_db$Month)
    
    return(data_from_db)
  })
  
  # OUTPUT 1: The Plot
  output$trendPlot <- renderPlot({

    req(nrow(filtered_data()) > 0)
    
    ggplot(filtered_data(), aes(x = Month, y = Readmission_Rate, color = Hospital_Name)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 3) +
      theme_minimal() +
      labs(y = "Readmission Rate (%)", x = "Date", title = paste("Trends for", input$dept_choice)) +
      theme(legend.position = "bottom")
  })
  
  # OUTPUT 2: The Table
  output$dataTable <- renderTable({
    filtered_data() %>%
      head(10)
  })
  
  # DOWNLOAD LOGIC
  output$downloadData <- downloadHandler(
    filename = function() { paste("sql_export_", Sys.Date(), ".csv", sep = "") },
    content = function(file) { write.csv(filtered_data(), file, row.names = FALSE) }
  )
}

#4. RUN APP
onStop(function() {
  dbDisconnect(con)
})

shinyApp(ui = ui, server = server)