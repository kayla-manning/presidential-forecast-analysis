
{
    library(shiny)
    library(tidyverse)
    library(scales)
    library(plotly)
    library(shinythemes)
    library(usmap)
}

# reading in data, saved as .csv from the last simulation on 11/1

{
    sims <- read_csv("app-data/election_simulation_results.csv")
    ev_sims <- read_csv("app-data/ev_uncertainty.csv")
}


ui <- navbarPage(
    
    # Application title
    "Presidential Forecast in Retrospect",
    
    tabPanel(
        "About",
        includeHTML(file.path("pages/about.html"))
    ),
    
    navbarMenu("Forecast Simulations",
               tabPanel("State-by-State Two-Party Popular Vote",
                   fluidPage(theme = shinytheme("yeti"),
                       
                       # My first page in the drop-down menu
                       titlePanel("State-by-State Two-Party Popular Vote Simulations"),
                       
                       # Drop-down menu to select state to display in histogram
                       sidebarLayout(
                           sidebarPanel(
                               selectInput("state",
                                           "State:",
                                           sims %>% pull(state) %>% unique() %>% sort()
                               )
                           ),
                           
                           # Show a plot of the generated distribution
                           mainPanel(
                               plotlyOutput("statesimPlot")
                           )
                       )
                    )
                 ),
               
               tabPanel("Predicted Vote Margin Map",
                        # creating this page to to show the win margin
                        includeHTML(file.path("pages/margin_maps.html"))
                    )
               )
        )

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$statesimPlot <- renderPlotly({
        
        # filter based on input$state from ui.R
        # getting text to specify the predicted pv2p and the chance of victory
        
        pv2p <- sims %>% 
            drop_na() %>% 
            filter(state == input$state) %>% 
            mutate(d_pv2p = sim_dvotes_2020 / (sim_rvotes_2020 + sim_dvotes_2020),
                   r_pv2p = 1 - d_pv2p) %>% 
            summarise(d_pv2p = mean(d_pv2p) * 100,
                      r_pv2p = mean(r_pv2p) * 100)
        
        win_prob <- sims %>% 
            mutate(biden_win = ifelse(sim_dvotes_2020 > sim_rvotes_2020, 1, 0)) %>% 
            group_by(state) %>% 
            summarise(pct_biden_win = mean(biden_win, na.rm = TRUE)) %>% 
            filter(pct_biden_win < 1 & pct_biden_win > 0) %>% 
            mutate(pct_trump_win = 1 - pct_biden_win) %>% 
            select(state, pct_biden_win, pct_trump_win) %>% 
            filter(state == input$state)
        
        pv2p_lab <- paste0("Forecasted Two-Party Popular Vote: ", round(pv2p$d_pv2p, 2), "% for Biden and ", round(pv2p$r_pv2p, 2), "% for Trump") 
        win_lab <- paste0("Forecasted Probability of Electoral College Victory: ", round(win_prob$pct_biden_win * 100, 2), "% for Biden and ", round(win_prob$pct_trump_win * 100, 2), "% for Trump")
        
        pv_plot <- sims %>% 
            filter(state == input$state) %>% 
            mutate(Democrat = sim_dvotes_2020 / (sim_dvotes_2020 + sim_rvotes_2020),
                   Republican = 1 - Democrat) %>% 
            pivot_longer(cols = c(Democrat, Republican), names_to = "party") %>% 
            ggplot(aes(value, fill = party)) +
            geom_histogram(aes(y = after_stat(count / sum(count))), bins = 1000, alpha = 0.5, position = "identity") +
            scale_fill_manual(breaks = c("Democrat", "Republican"),
                              labels = c("Biden", "Trump"),
                              values = c(muted("blue"), "red3")) +
            labs(title = paste("Simulated Two-Party Popular Vote in", input$state),
                 x = "Predicted Share of the Two-Party Popular Vote",
                 y = "Probability",
                 fill = "Candidate",
                 subtitle = pv2p_lab) +
            theme_minimal()
        
        print(ggplotly(pv_plot) %>% 
                  layout(title = list(text = paste0("Simulated Two-Party Popular Vote in Battleground States",
                                                    '<br>',
                                                    '<sup>',
                                                    pv2p_lab,
                                                    '<br>',
                                                    '<sup>',
                                                    win_lab,
                                                    '</sup>'))))
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
