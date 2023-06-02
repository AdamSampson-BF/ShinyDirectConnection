# Module definition
geoFilterUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # selectizeGroupUI(
    #   'geo_selections',
    #   params = list(
    #     country = list(inputId = "country", title = "Country:"),
    #     market  = list(inputId = "market" , title = "Market:" )
    #   ),
    #   inline = FALSE
    # )
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
    }
  )
}