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
                                                  "Random data are generated given the population information from user inputs. In this simulation the average score for all is 50 with a standard deviation of 10. 
                                                  Additionaly, males'scores are lower by an average of 5 with a standard deviation of 1 added to their score. Non-Whites' scores are lower by an average of 7 with a standard deviation of 1.
                                                  This allows you the opportunity to see how different response rates given a population can alter the overall inferences.",
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
                                                         p("Enter demographic information about your population and associated population size (e.g. 50% Non-White, 50% Female, a total of 5,000 students"),
                                                       box(sliderInput("pop_female_perc", label = "% Female",
                                                                       value = 50,
                                                                       min = 1,
                                                                       max = 100,
                                                                       step = 1),
                                                  sliderInput("pop_non_white_perc", label = "% Non White",
                                                              value = 50,
                                                              min = 1,
                                                              max = 100,
                                                              step = 1),
                                              numericInput("pop_n", label = "Number In Population",
                                                              value = 5000,
                                                              min = 100,
                                                              max = 10000), width =12),
                                              br(),
                                                           h2("Survey Response Statistics"),
                                              p("Enter your the characteristics of your returned suverys and response rate (e.g. 30% Non-White and 50% Female responded with a 10% response rate)"),
                                                           box(sliderInput("samp_female_perc", label = "% Female",
                                                              value = 50,
                                                              min = 1,
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
                                                          tabPanel(title = "Combined",
                                                                   plotOutput("all_charts")),
                                                      tabPanel(title = "Individual",
                                                          plotOutput("population_chart"),
                                                          plotOutput("sample_chart"),
                                                          plotOutput("ps_chart")),
                                                      tabPanel(title = "Table",
                                                               tableOutput("result_table")),
                                                      tabPanel(title = "Grid",
                                                               plotOutput("alt_output"))
                                               #   )
                                              ,
                                              
                                              width = 8)
                                  ))
                                  )
                                  
)
)