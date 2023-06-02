library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(DBI)
library(dbplyr)
# library(promises)
# library(future)

# plan(multisession) # Used for promises and future
# Note: promises and future is used to allow really big queries to run asyncronously (don't wait for it before moving on)
# Example:
#     fact_long_tbl %>% 
#       inner_join(myfilters) %>% 
#       group_by(country,market) %>% 
#       summarize(sum_value = sum(value,na.rm=TRUE)) %>% 
#       collect() %>% 
#       plot()
# becomes
#     future_promise({
#       fact_long_tbl %>% inner_join(myfilters) %>% group_by(country,market) %>% 
#       summarize(sum_value = sum(value,na.rm=TRUE)) %>% collect()
#     }) %...>% plot()
# because the database calculation and collection can take a long time. This allows the app to move
# on to other tasks (such as parallel database queries!) without waiting. The cost to do paralels is 
# high though so you should only do this if a page takes more than a couple seconds to load.

ui <- dashboardPage(
  dashboardHeader(title = "ARM Dashboard"),
  dashboardSidebar(
    # geoFilterUI('geofilters')
    geoCountryFilterUI('geocountryfilter'),
    geoMarketsFilterUI('geomarketfilter'),
    prodManufacturerFilterUI('prodmanufacturerfilter')
  ),
  dashboardBody()
)

server <- function(input, output, session) {
  # NOTE: The database connections and queries should really be paralized with the async promises package
  cloudera_prod <- dbConnect(odbc::odbc(), "CLPImpala", timeout = 10)
  
  # Simple table connections automatically detect column names
  # date_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_dates'))
  # geo_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_geo'))
  # prod_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_product'))
  # fact_long_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_values_long'))
  
  # Defining column names manually on connection makes the connection 4 times faster on current cloudera odbc connection 
  date_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_dates'), 
                  vars = c("cr_date","date"))
  geo_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_geo'),
                 vars = c("geo_id","market_type","market","division","state","lowest_level_spirits","aggregatable_spirts","national_flag","report_type","country"))
  prod_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_product'),
                  vars = c("prod_id","price_segment","category","manufacturer","brand_family","brand","size","sku","country"))
  fact_long_tbl <- tbl(cloudera_prod, in_schema('aa_data_science_staging','dev_arm_desc_values_long'),
                       vars = c("geo_id","prod_id","cr_date","date_period","case_volume" ,           
                                "volume","value","price_bin","promotion_value","promotion_volume"  ,     
                                "non_promotion_value","non_promotion_volume","acv","numeric_acv","display_acv"    ,        
                                "feature_acv","feature_display_acv","case_volume_ly","volume_ly","value_ly"    ,           
                                "price_bin_ly","promotion_value_ly","promotion_volume_ly","non_promotion_value_ly","non_promotion_volume_ly",
                                "acv_ly","numeric_acv_ly","display_acv_ly","feature_acv_ly","feature_display_acv_ly" ,
                                "country","roll_period"  ))
  
  # geo_selections <- geoFilterServer('geofilters', geo_tbl = geo_tbl)
  
  geo_lookup <- reactive({ geo_tbl %>% collect() }) # This lookup is fairly quick to collect - borderline whether to run async
  geo_country_selection <- geoCountryFilterServer('geocountryfilter', geo_lookup = geo_lookup)
  geo_markets_selection <- geoMarketsFilterServer('geomarketfilter', geo_lookup = geo_lookup, countries_selected = geo_country_selection)
  
  # prod_lookup <- reactive({ prod_tbl %>% collect() }) # This lookup is slow collect - candidate for async or sql optimization
  prod_lookup <- getProdLookupServer('productlookupid',prod_tbl = prod_tbl, countries_selected = geo_country_selection)
  prod_manufacturer_selection <- prodManufacturerFilterServer('prodmanufacturerfilter', prod_lookup = prod_lookup, countries_selected = geo_country_selection)
  # prod_manufacturer_selection <- prodManufacturerFilterServer('prodmanufacturerfilter', prod_lookup = prod_tbl, countries_selected = geo_country_selection)
}

shinyApp(ui, server)