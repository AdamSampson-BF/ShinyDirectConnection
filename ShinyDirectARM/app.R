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
  # date_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_dates'))
  # geo_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_geo'))
  # prod_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_product'))
  # fact_long_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_values_long'))
  date_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_dates'), 
                  vars = c("cr_date","date"))
  geo_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_geo'),
                 vars = c("geo_id","market_type","market","division","state","lowest_level_spirits","aggregatable_spirts","national_flag","report_type","country"))
  prod_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_product'),
                  vars = c("prod_id","price_segment","category","manufacturer","brand_family","brand","size","sku","country"))
  fact_long_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_values_long'),
                       vars = c("geo_id","prod_id","cr_date","date_period","case_volume" ,           
                                "volume","value","price_bin","promotion_value","promotion_volume"  ,     
                                "non_promotion_value","non_promotion_volume","acv","numeric_acv","display_acv"    ,        
                                "feature_acv","feature_display_acv","case_volume_ly","volume_ly","value_ly"    ,           
                                "price_bin_ly","promotion_value_ly","promotion_volume_ly","non_promotion_value_ly","non_promotion_volume_ly",
                                "acv_ly","numeric_acv_ly","display_acv_ly","feature_acv_ly","feature_display_acv_ly" ,
                                "country","roll_period"  ))
  
  geoFilterServer('geofilters', geo_tbl = geo_tbl)
}

shinyApp(ui, server)