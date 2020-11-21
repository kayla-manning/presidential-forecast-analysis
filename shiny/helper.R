
# reading in data and defining functions here so that my shiny app stays nice
# and clean

# loading packages

{
  library(shiny)
  library(scales)
  library(plotly)
  library(shinythemes)
  library(usmap)
  library(knitr)
  library(flexdashboard)
  library(lubridate)
  library(tidyverse)
  library(kableExtra)
  library(janitor)
  library(googlesheets4)
  library(miniUI)
}


# reading in data, saved as .csv from the last simulation on 11/1

{
  sims <- read_csv("app-data/election_simulation_results.csv")
  ev_sims <- read_csv("app-data/ev_uncertainty.csv") %>% 
    select(id, biden_ev, trump_ev)
  pred_compare <- read_csv("app-data/pred_compare.csv")
  changes <- read_csv("https://raw.githubusercontent.com/alex/nyt-2020-election-scraper/master/all-state-changes.csv") %>% 
    mutate(state = str_replace(state, " \\(.*\\)", ""),
           state = state.abb[match(state, state.name)],
           timestamp = ymd_hms(timestamp),
           pct_reported = precincts_reporting / precincts_total * 100) %>% 
    mutate(trump_votes = case_when(leading_candidate_name == "Trump" ~ leading_candidate_votes,
                                   TRUE ~ trailing_candidate_votes),
           biden_votes = case_when(leading_candidate_name == "Biden" ~ leading_candidate_votes,
                                   TRUE ~ trailing_candidate_votes),
           trump_pv2p = trump_votes / (biden_votes + trump_votes),
           biden_pv2p = biden_votes / (biden_votes + trump_votes)) %>% 
    pivot_longer(cols = trump_pv2p:biden_pv2p, names_to = "candidate", values_to = "pv2p") %>% 
    mutate(candidate = recode(candidate, "biden_pv2p" = "Biden",
                              "trump_pv2p" = "Trump"))
}


# loading hodp theme

{
  my_red <- '#D84742' 
  my_blue <- '#4B5973'
  monochrome <- c('#760000', '#BE1E26', '#D84742', '#FF6B61', '#FF9586')
  primary <- c('#EE3838', '#FA9E1C', '#78C4D4', '#4B5973', '#E2DDDB')
  sidebysidebarplot <- c("#ef3e3e", "#2c3e50")
  theme_hodp <- function () { 
    theme_classic(base_size=12, base_family="Helvetica") %+replace%
      theme(
        panel.background  = element_rect(fill="#F2F2F2", colour=NA),
        plot.background = element_rect(fill="#F2F2F2", colour="#d3d3d3"),
        legend.background = element_rect(fill="transparent", colour=NA),
        legend.key = element_rect(fill="transparent", colour=NA),
        plot.title = element_text(size=24,  family="Helvetica", face = "bold", margin = margin(t = 0, r = 0, b = 10, l = 0)),
        plot.subtitle = element_text(size=18,  family="Helvetica", color="#717171", face = "italic", margin = margin(t = 0, r = 0, b = 10, l = 0)),
        plot.caption = element_text(size=8,  family="Helvetica", hjust = 1),
        axis.text.x =element_text(size=10,  family="Helvetica"),
        axis.title.x =element_text(size=14, family="Helvetica", margin = margin(t = 10, r = 0, b = 0, l = 0), face = "bold"),
        axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0), size=14, family="Helvetica", angle=90, face ='bold'),
        legend.title=element_text(size=10, family="Helvetica"), 
        legend.text=element_text(size=10, family="Helvetica"),
        legend.position = "bottom",
        axis.ticks = element_blank()
      )
  }
}

# making function to display simulated state-level pv2ps

pv2p_plot <- function(x) {
  
  # filter based on input$state from ui.R
  # getting text to specify the predicted pv2p and the chance of victory
  
  title <- paste("Simulated Two-Party Popular Vote \nin", x)
  
  pv2p <- sims %>% 
    drop_na() %>% 
    filter(state == x) %>% 
    mutate(d_pv2p = sim_dvotes_2020 / (sim_rvotes_2020 + sim_dvotes_2020),
           r_pv2p = 1 - d_pv2p) %>% 
    summarise(d_pv2p = mean(d_pv2p) * 100,
              r_pv2p = mean(r_pv2p) * 100)
  
  biden_pv2p <- enos_data %>% 
    mutate(state = state.abb[match(state, state.name)]) %>% 
    filter(state == x) %>% 
    summarise(d_pv2p = democrat / (democrat + republican)) %>% 
    pull(d_pv2p)
  
  trump_pv2p <- 1 - biden_pv2p
  
  win_prob <- sims %>% 
    mutate(biden_win = ifelse(sim_dvotes_2020 > sim_rvotes_2020, 1, 0)) %>% 
    group_by(state) %>% 
    summarise(pct_biden_win = mean(biden_win, na.rm = TRUE)) %>% 
    filter(pct_biden_win < 1 & pct_biden_win > 0) %>% 
    mutate(pct_trump_win = 1 - pct_biden_win) %>% 
    select(state, pct_biden_win, pct_trump_win) %>% 
    filter(state == x)
  
  pv2p_lab <- paste0("Forecasted Two-Party Popular Vote: ", round(pv2p$d_pv2p, 2), "% for Biden and ", round(pv2p$r_pv2p, 2), "% for Trump") 
  win_lab <- paste0("Forecasted Probability of Electoral College Victory: ", round(win_prob$pct_biden_win * 100, 2), "% for Biden and ", round(win_prob$pct_trump_win * 100, 2), "% for Trump")
  
  pv_plot <- sims %>% 
    filter(state == x) %>% 
    mutate(Democrat = sim_dvotes_2020 / (sim_dvotes_2020 + sim_rvotes_2020),
           Republican = 1 - Democrat) %>% 
    pivot_longer(cols = c(Democrat, Republican), names_to = "party") %>% 
    ggplot(aes(value, fill = party)) +
    geom_histogram(aes(y = after_stat(count / sum(count)),
                       text = paste0("Probability: ", round(after_stat(count / sum(count)), 5))), bins = 1000, alpha = 0.5, position = "identity") +
    geom_vline(xintercept = biden_pv2p) +
    geom_vline(xintercept = trump_pv2p) +
    scale_fill_manual(breaks = c("Democrat", "Republican"),
                      labels = c("Biden", "Trump"),
                      values = c(my_blue, my_red)) +
    labs(title = title,
         x = "Predicted Share of the Two-Party Popular Vote",
         y = "Probability",
         fill = "Candidate",
         subtitle = pv2p_lab) +
    theme_hodp() +
    expand_limits(y = 0)
  
  ggplotly(pv_plot, tooltip = "text")
}

# making state types for the below win probability plots

{
  dem_states <- c("CO", "VA", "CA", "CT", "DE", "HI", "IL", "MD", "MA", "NJ", "NY", "OR", "RI", 
                  "VT", "WA")
  bg_states <- c("FL", "IA", "OH", "GA", "ME", "NC", "MI", "MN", "NE", "NH", "PA", "WI", 
                 "NV", "AZ", "NM", "TX")
  rep_states <- c("AK", "IN", "KS", "MO", "AL", "AR", "ID", "KY", "LA", "MS", "ND", "OK", "SD", "MT",
                  "TN", "WV", "WY", "SC", "UT")
  types <- tibble(type = c("Battleground", "Red", "Blue")) %>% 
    mutate(state = case_when(type == "Battleground" ~ list(bg_states),
                             type == "Red" ~ list(rep_states),
                             type == "Blue" ~ list(dem_states)))
}

# function for plot with estimated vote shares

state_voteshares <- function(x){
  
  title <- paste("Estimated Vote Shares in\n", x, "States")
  
  if (x == "Battleground") {
    type = bg_states
  }
  if (x == "Red") {
    type = rep_states
  }
  if (x == "Blue") {
    type = dem_states
  }
  
  p <- sims %>% 
    filter(state %in% type) %>% 
    mutate(Biden = sim_dvotes_2020 / (sim_dvotes_2020 + sim_rvotes_2020),
           Trump = 1 - Biden) %>% 
    group_by(state) %>% 
    summarise(Biden = mean(Biden, na.rm = TRUE),
              Trump = mean(Trump, na.rm = TRUE)) %>% 
    mutate(state = fct_reorder(as_factor(state), Biden)) %>% 
    pivot_longer(cols = c(Biden, Trump), names_to = "Candidate", values_to = "vote_share") %>% 
    select(state, Candidate, vote_share) %>% 
    rename("State" = state) %>% 
    ggplot(aes(x = State, y = vote_share, fill = Candidate,
               text = paste0(Candidate, "'s Estimated Vote Share \nin ", State, " : ", round(vote_share, 3)))) +
    geom_col() +
    theme_hodp() +
    scale_fill_manual(values = c(my_blue, my_red)) +
    labs(x = "",
         y = "Estimated Vote Share",
         fill = "Candidate",
         title = title)
  
  print(ggplotly(p, tooltip = "text"))
  
}

# writing function to display blots with probabilities of victory

state_win_probs <- function(x) {
  
  title <- paste("Probability of Winning\n", x, "States")
  
  if (x == "Battleground") {
    type = bg_states
  }
  if (x == "Red") {
    type = rep_states
  }
  if (x == "Blue") {
    type = dem_states
  }
  
  p <- sims %>% 
    mutate(biden_win = ifelse(sim_dvotes_2020 > sim_rvotes_2020, 1, 0)) %>% 
    filter(state %in% type) %>% 
    group_by(state) %>% 
    summarise(Biden = mean(biden_win, na.rm = TRUE)) %>% 
    filter(Biden < 1 & Biden > 0) %>% 
    mutate(close = Biden - .5) %>% 
    arrange(abs(close)) %>% 
    select(state, Biden) %>% 
    mutate(Trump = 1 - Biden,
           state = fct_reorder(as_factor(state), Biden)) %>% 
    pivot_longer(2:3, names_to = "Candidate", values_to = "probability") %>% 
    rename("State" = "state") %>% 
    ggplot(aes(State, probability, fill = Candidate,
               text = paste0(Candidate, "'s Probability of Winning ", State, " : ", round(probability, 3)))) +
    geom_col() +
    theme_hodp() +
    scale_fill_manual(labels = c("Biden", "Trump"),
                      values = c(my_blue, my_red)) +
    labs(x = "",
         y = "Probability of \nVictory",
         fill = "Candidate",
         title = title)
    
  print(ggplotly(p, tooltip = "text"))
  
}

us_map <- map_data("state") %>% 
  mutate(region = toupper(region),
         region = state.abb[match(region,  toupper(state.name))])

# data from Professor Enos... will use this to calculate the overall national
# pv2p

{
  enos_data <- read_sheet("https://docs.google.com/spreadsheets/d/1faxciehjNpYFNivz-Kiu5wGl32ulPJhdJTDsULlza5E/edit#gid=0", 
                          col_types = paste0("dcc", paste0(rep("d", times = 39), collapse = ""), collapse = "")) %>% 
    slice(-1) %>% 
    unnest(FIPS) %>% 
    clean_names() %>% 
    rename("democrat" = joseph_r_biden_jr,
           "republican" = donald_j_trump,
           "state" = geographic_name) %>% 
    select(state, democrat, republican) 
  
  enos_pv2p <- enos_data %>% 
    mutate(democrat = democrat / (democrat + republican) * 100,
           republican = 100 - democrat,
           state = state.abb[match(state, state.name)]) %>% 
    pivot_longer(2:3, names_to = "party", values_to = "actual_pv2p")
  
  pred <- sims %>% 
    drop_na() %>% 
    group_by(state) %>% 
    mutate(d_pv2p = sim_dvotes_2020 / (sim_rvotes_2020 + sim_dvotes_2020),
           r_pv2p = 1 - d_pv2p) %>% 
    summarise(d_pv2p = mean(d_pv2p),
              r_pv2p = mean(r_pv2p),
              d_margin = d_pv2p - r_pv2p) %>% 
    select(1:3) %>% 
    pivot_longer(d_pv2p:r_pv2p, names_to = "party", values_to = "pred_pv2p") %>% 
    mutate(party = recode(party, d_pv2p = "democrat",
                          r_pv2p = "republican"),
           pred_pv2p = pred_pv2p * 100)
  
  enos_pred_compare <- enos_pv2p %>% 
    inner_join(pred, by = c("state", "party")) %>% 
    mutate(diff = actual_pv2p - pred_pv2p) %>% 
    filter(party == "democrat") 
  }

# writing function to find the predicted pv2p for the given state

state_pred_pv2p <- function(x, candidate) {
  
  pv2ps <- sims %>% 
    drop_na() %>% 
    group_by(state) %>% 
    mutate(d_pv2p = sim_dvotes_2020 / (sim_rvotes_2020 + sim_dvotes_2020),
           r_pv2p = 1 - d_pv2p) %>% 
    summarise(d_pv2p = mean(d_pv2p),
              r_pv2p = mean(r_pv2p)) %>% 
    filter(state == x) %>% 
    select(2:3) %>% 
    pivot_longer(cols = everything(), names_to = "party") %>% 
    pull(value)
    
  if (candidate == "biden") {
    return(pv2ps[1])
  }
  
  if (candidate == "trump") {
    return(pv2ps[2])
  }
    
}


