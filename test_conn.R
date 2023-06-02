library(tidyverse)
library(DBI)
library(dbplyr)

microbenchmark::microbenchmark({
  con <- dbConnect(odbc::odbc(), "CLPImpala", timeout = 10)
  date_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_dates'))
  geo_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_geo'))
  prod_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_product'))
  fact_long_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_values_long'))
}, times = 3L)
# Mean of 2.2s on 2023/06/02

microbenchmark::microbenchmark({
  con <- dbConnect(odbc::odbc(), "CLPImpala", timeout = 10)
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
}, times = 3L)
# Mean of 0.6s on 2023/06/02

microbenchmark::microbenchmark(
  avail_countries <- geo_tbl %>% select(country) %>% distinct() %>% pull(),
  times = 1L)
microbenchmark::microbenchmark(
  geo_df <- geo_tbl %>% collect(),
  times = 1L)
microbenchmark::microbenchmark(
  prod_df <- prod_tbl %>% collect(),
  times = 1L)
microbenchmark::microbenchmark(
  prod_df <- prod_tbl %>% filter(country == "AU") %>% collect(),
  times = 1L)
