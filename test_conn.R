library(tidyverse)
library(DBI)
library(dbplyr)

con <- dbConnect(odbc::odbc(), "CLPImpala", timeout = 10)
date_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_dates'))
geo_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_geo'))
prod_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_product'))
fact_long_tbl <- tbl(con, in_schema('aa_data_science_staging','dev_arm_desc_values_long'))

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
