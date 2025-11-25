# Healthcare Readmission Analytics Dashboard

## Overview
This is a full-stack data analytics application built with **R Shiny** to visualize hospital readmission rates and cost metrics. It simulates a healthcare reporting environment by querying a local **SQL (SQLite)** database and presenting insights via an interactive dashboard.

## Key Features
* **SQL Integration:** Implements a backend pipeline using RSQLite to query data dynamically.
* **Interactive Visualizations:** Features reactive ggplot2 charts that update based on user-defined cost and department filters.
* **Automated Reporting:** Includes a data export function allowing users to download filtered datasets for offline analysis.

## Tech Stack
* **Language:** R
* **Framework:** Shiny
* **Database:** SQL (SQLite)
* **Libraries:** tidyverse (dplyr, ggplot2), bslib, RSQLite

## How to Run
1. Clone this repository.
2. Open hospital_metrics_app.R in RStudio.
3. Click "Run App".
