#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

# Define UI for application that draws a histogram
shinydashboard::dashboardPage(skin = "yellow",
                              
                              #add title
                              dashboardHeader(title = "Survey Post-Stratification Simulation Tool", titleWidth = 800),
                              
                              #Add sidebar elements
                              dashboardSidebar(sidebarMenu(
                                  menuItem("About", tabName = "about", icon = icon("archive")),
                                  menuItem("Data Dictionary", tabName = "simulator", icon = icon("paper-plane")))),
                              
                                  
                                  # Add Body Elements----
                              
                              dashboardBody(
                                  tabItems(
                                      # First Tab
                                      tabItem(tabName = "about",
                                              fluidRow(
                                                  withMathJax(),
                                                  h1("What this Application Does"),
                                                  "The purpose of this applications is to demonstrate how survey post-stratification works.
                                                  This is a tool that is used in survey design to often correct for on-response bias by re-weighting
                                                  the survey data by known information about the population (e.g. re-weighting by gender/ race)",
                                                  h2("Method"),
                                                  "Random data are generated given the population information from user inputs",
                                                  h2("For More Information"),
                                                  a("Wake Forest University Office of Institutional Research Survey Methodology", 
                                                    target = "_blank", 
                                                    href = paste0("https://ir.wfu.edu/assessment-survey-results/oir-survey-analysis-methodology/")),
                                                  h2("Thanks!")
                                              )),
                                      
                                      # Simulator----
                                      tabItem(tabName = "simulator",
                                              fluidRow(
                                                  column(h2("Population Statistics"),
                                                       box(sliderInput("pop_female_perc", label = "% Female",
                                                                       value = 50,
                                                                       min = 0,
                                                                       max = 100,
                                                                       step = 1),
                                                  sliderInput("pop_non_white_perc", label = "% Non White",
                                                              value = 50,
                                                              min = 0,
                                                              max = 100,
                                                              step = 1),
                                              numericInput("pop_n", label = "Number In Population",
                                                              value = 2500,
                                                              min = 100,
                                                              max = 1000), width =12),
                                              br(),
                                                           h2("Survey Response Statistics"),
                                                           box(sliderInput("samp_female_perc", label = "% Female",
                                                              value = 50,
                                                              min = 0,
                                                              max = 100,
                                                              step = 1),
                                              sliderInput("samp_non_white_perc", label = "% Non White",
                                                              value = 50,
                                                              min = 1,
                                                              max = 100,
                                                              step = 1),
                                              sliderInput("response_rate", label = "% Response",
                                                              value = 10,
                                                              min = 1,
                                                              max = 100,
                                                              step = 1), width =12), width = 4),
                                              #column(
                                                  tabBox( title = tagList(shiny::icon("gear"), "Results"),
                                                      tabPanel(title = "Individual",
                                                          plotOutput("population_chart"),
                                                          plotOutput("sample_chart"),
                                                          plotOutput("ps_chart"))
                                                      ,
                                                      tabPanel(title = "Combined",
                                                               plotOutput("all_charts")),
                                                      tabPanel(title = "Table",
                                                               tableOutput("result_table"))
                                               #   )
                                              ,
                                              
                                              width = 8)
                                  ))
                                  )
                                  
)
)