
# loaded libraries, read in data, and created functions in other file to keep
# this script nice and clean

source("helper.R")

ui <- navbarPage(
    
    # Application title
    "Presidential Forecast in Retrospect",
    
    tabPanel(
        "About",
        includeHTML(file.path("pages/about.html"))
    ),
    
    navbarMenu("Forecast Simulations",
               tabPanel("State-by-State Two-Party Popular Vote",
                   
                    fluidPage(theme = "journal",
                        tabsetPanel(
                               tabPanel("Simulated Vote Shares", 
                                    selectInput("state",
                                                "State:",
                                                sims %>% pull(state) %>% unique() %>% sort()),
                                    plotlyOutput("statesimPlotly")
                                ),
                               tabPanel("Estimated Vote Shares",
                                   selectInput("state_type",
                                               "State Category:",
                                               types %>% select(type) %>% unique()),
                                    plotlyOutput("state_shares_plotly")
                               ),
                               tabPanel("Probability of Victory",
                                   selectInput("state_type",
                                               "State Category:",
                                               types %>% select(type) %>% unique()),
                                    plotlyOutput("state_victory_plotly")
                                )
                          )
                    )
                ),
         
               tabPanel("Predicted Vote Margin Map",
                        # creating this page to show the win margin
                        includeHTML(file.path("pages/margin_maps.html"))

                )
    )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    output$statesimPlotly <- renderPlotly({

        # calling function that I defined at the top of the app
        pv2p_plot(input$state)
        
    })
    
    output$state_shares_plotly <- renderPlotly(
        
        # calling function from helper
        state_voteshares(input$state_type)
    )
    
    output$statevictoryPlotly <- renderPlotly(
        
        # calling function from helper to make this plot
        state_win_probs(input$state_type)
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
