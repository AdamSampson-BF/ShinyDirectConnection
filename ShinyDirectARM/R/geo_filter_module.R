# Module definition
## Building one large module ----
geoFilterUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectizeInput(
      ns('geo_country_select'),
      label = "Country:",
      choices = NULL,
      selected = NULL
    ),
    selectizeInput(
      ns('geo_market_select'),
      label = "Market:",
      choices = NULL,
      selected = NULL,
      multiple = TRUE
    )
  )
}

geoFilterServer <- function(id, geo_tbl) {
  moduleServer(
    id,
    # Below is the module function
    function(input, output, session) {
      geo_lookup <- reactive({ geo_tbl %>% collect() })
      
      observe({
        countries <- geo_lookup() %>% select(country) %>% pull() %>% unique() %>% sort()
        
        updateSelectizeInput(session,
                             'geo_country_select',
                             choices = countries,
                             selected = countries[1],
                             server = TRUE
                             )
      })
      
      
      observe({
        req(input$geo_country_select)
        
        markets <- geo_lookup() %>% filter(country == input$geo_country_select) %>% select(market) %>% pull() %>% unique() %>% sort()

        updateSelectizeInput(session,
                             'geo_market_select',
                             choices = markets,
                             selected = markets[1],
                             server = TRUE
        )
      })
      
      return(
        reactive(
          list(geoCountry = input$geo_country_select,
               goeMarkets   = input$geo_market_select
               ) # list
          ) # reactive
        ) # return
    }
  )
}

## Building Smaller Interlocking Modules ----
geoCountryFilterUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectizeInput(
      ns('geo_country_select'),
      label = "Country:",
      choices = NULL,
      selected = NULL
    )
  )
}

geoCountryFilterServer <- function(id, geo_lookup) {
  moduleServer(
    id,
    # Below is the module function
    function(input, output, session) {
      
      observe({
        countries <- geo_lookup() %>% select(country) %>% pull() %>% unique() %>% sort()
        
        updateSelectizeInput(session,
                             'geo_country_select',
                             choices = countries,
                             selected = countries[1],
                             server = TRUE
        )
      })
      
      return(
        reactive(
          input$geo_country_select
        ) # reactive
      ) # return
    }
  )
}

geoMarketsFilterUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectizeInput(
      ns('geo_markets_select'),
      label = "Market:",
      choices = NULL,
      selected = NULL,
      multiple = TRUE
    )
  )
}

geoMarketsFilterServer <- function(id, geo_lookup, countries_selected) {
  moduleServer(
    id,
    # Below is the module function
    function(input, output, session) {
      
      observe({
        req(countries_selected())
        
        temp_countries <- countries_selected() # Fix to handle reactive in a sql chain
        
        markets <- geo_lookup() %>% filter(country %in% temp_countries) %>% select(market) %>% pull() %>% unique() %>% sort()
        
        updateSelectizeInput(session,
                             'geo_markets_select',
                             choices = markets,
                             selected = markets[1],
                             server = TRUE
        )
      })
      
      return(
        reactive(
          input$geo_markets_select
        ) # reactive
      ) # return
    }
  )
}
