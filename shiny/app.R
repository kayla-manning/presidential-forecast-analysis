
# loaded libraries, read in data, and created functions in other file to keep
# this script nice and clean

source("helper.R")

ui <- navbarPage(
    
    # Application title
    "Presidential Forecast in Retrospect",
    
    fluidPage(theme = shinytheme("journal"),

        includeHTML(file.path("pages/about.html")),
        
        includeMarkdown("state_probabilities.Rmd"),
        
        includeMarkdown("state_simulations.Rmd"),
         
               tabPanel("Predicted Vote Margin Map",
                        # creating this page to show the win margin
                        includeHTML(file.path("pages/margin_maps.html"))

                )
    )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    output$statesimPlotly <- renderPlotly(

        # calling function that I defined at the top of the app
        pv2p_plot(input$state)
        
    )
    
    output$statesharesPlotly <- renderPlotly(
        
        # calling function from helper
        state_voteshares(input$state_type)
        
    )
    
    output$statevictoryPlotly <- renderPlot(
        
        # function from helper
        state_win_probs(input$state_type)
        
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
