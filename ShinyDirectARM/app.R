library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(DBI)
library(dbplyr)

# Test data
# geo_lookup <- reactive({ geo_tbl %>% collect() })

ui <- dashboardPage(
  dashboardHeader(title = "ARM Dashboard"),
  dashboardSidebar(
    geoFilterUI('geofilters')
  ),
  dashboardBody()
)

server <- function(input, output, session) {
  # NOTE: The database connections and queries should really be paralized with the async promises package
  cloudera_prod <- dbConnect(odbc::odbc(), "CLPImpala", timeout = 10)
  date_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_dates'))
  geo_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_geo'))
  prod_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_product'))
  fact_long_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_values_long'))
  
  geoFilterServer('geofilters', geo_tbl = geo_tbl)
}

shinyApp(ui, server)