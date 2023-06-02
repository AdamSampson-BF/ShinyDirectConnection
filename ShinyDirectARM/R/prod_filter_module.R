# Module Definition
## Building Smaller Interlocking Modules ----

getProdLookupServer <- function(id, prod_tbl, countries_selected) {
  moduleServer(
    id,
    # Below is the module function
    function(input, output, session) {
      prod_lookup <- eventReactive(countries_selected(),{
        print("Updating prod table.")
        req(countries_selected())
        temp_countries <- countries_selected() # Fix to handle reactive in a sql chain
        temp_prod_lookup <- prod_tbl %>% filter(country %in% temp_countries) %>% collect()
        return(temp_prod_lookup)
      })
      
      # prod_lookup <- observe({
      #   req(countries_selected)
      #   
      #   temp_countries <- countries_selected() # Fix to handle reactive in a sql chain
      #   prod_lookup <- prod_tbl %>% filter(country %in% temp_countries) %>% collect()
      # })
      
      return(prod_lookup)
    }
  )
}

prodManufacturerFilterUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectizeInput(
      ns('prod_manufacturer_select'),
      label = "Manufacturer:",
      choices = NULL,
      selected = NULL,
      multiple = TRUE
    )
  )
}

prodManufacturerFilterServer <- function(id, prod_lookup, countries_selected) {
  moduleServer(
    id,
    # Below is the module function
    function(input, output, session) {
      
      observe({
        req(countries_selected())
        
        temp_countries <- countries_selected() # Fix to handle reactive in a sql chain
        
        manufacturers <- prod_lookup() %>% filter(country %in% temp_countries) %>% select(manufacturer) %>% pull() %>% unique() %>% sort()
        # manufacturers <- prod_lookup %>% filter(country %in% temp_countries) %>% select(manufacturer) %>% distinct() %>% arrange(manufacturer) %>% collect() %>% pull()
        
        updateSelectizeInput(session,
                             'prod_manufacturer_select',
                             choices = manufacturers,
                             selected = manufacturers[1],
                             server = TRUE
        )
      })
      
      return(
        reactive(
          input$prod_manufacturer_select
        ) # reactive
      ) # return
    }
  )
}