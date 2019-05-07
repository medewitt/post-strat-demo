#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(survey)
library(cowplot)
library(gridExtra)
library(gridGraphics)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

population_data <- reactive({
    white_probs <- 1- input$pop_non_white_perc/100
    nonwhite_probs <- input$pop_non_white_perc/100
    
    male_probs <- 1- input$pop_female_perc/100
    female_probs <- input$pop_female_perc/100
    
    # Generates Race Data
    race_data <- sample(x = c("White", "Non-White"), 
                        size = input$pop_n, replace = TRUE, 
                        prob = c(white_probs, nonwhite_probs))
    
    # Generates Race Data
    gender_data <- sample(x = c("Female", "Male"), 
                        size = input$pop_n, replace = TRUE, 
                        prob = c(female_probs, male_probs))
    combined_data <- data.frame(race = race_data,
                                gender = gender_data,
                                score = rnorm(input$pop_n, 50, 10), 
                                stringsAsFactors = FALSE) %>% 
        # Male Impact
        mutate(score = ifelse(gender == "Male", score - rnorm(1, 5, 1), score)) %>% 
        # Non-White Impact
        mutate(score = ifelse(race == "Non-White", score - rnorm(1, 7, 1), score)) %>% 
        mutate(my_fpc = input$pop_n)
    
    combined_data
    
})

# Generate the Sample Data
sample_data <- reactive({
    dat <- population_data()
    
    sampling_rate <- tidyr::crossing(gender = c("Male", "Female"), 
                                     race = c("Non-White", "White")) %>% 
        mutate(race_weight = ifelse(race == "White", 
                                    100-input$samp_non_white_perc, 
                                    input$samp_non_white_perc),
               gender_weight = ifelse(gender == "Female",
                                      input$samp_female_perc, 
                                      100 -input$samp_female_perc)) %>% 
        mutate(sample_wt = gender_weight*race_weight)
    
    sample_data <- dat %>% 
        left_join(sampling_rate, by = c("race", "gender")) %>% 
        sample_frac(size = input$response_rate/100, weight = sample_wt)%>% 
        mutate(my_fpc = input$pop_n)
    
    sample_data
})

# Post-Stratified Sample

ps_sample_data <- reactive({
    svy_unweighted <- svydesign(ids = ~1, fpc = ~my_fpc, data =sample_data())
    
    
    num_samples <- input$pop_n
    
    # Create the Rakes
    
    pop_gender <- data.frame(gender = c("Female", "Male"),
                             Freq = c(input$pop_female_perc/100*num_samples, 
                                      (1- input$pop_female_perc/100)*num_samples), 
                             stringsAsFactors = FALSE)
    
    pop_race <- data.frame(race = c("Non-White", "White"),
                             Freq = c(input$pop_non_white_perc/100*num_samples, 
                                      (1- input$pop_non_white_perc/100)*num_samples), 
                           stringsAsFactors = FALSE)
    
    svy_weighted <- rake(svy_unweighted, sample.margins = list(~gender, ~race),
                         population.margins = list(pop_gender, pop_race))
    
    svy_weighted
    
})


# Make Charts

# Chart Ranges

make_population_chart <- function(){
    population_data() %>% 
        ggplot(aes(score))+
        geom_histogram(bins = 30, color = "gray35")+
        geom_vline(xintercept = mean(population_data()$score), color = "orange")+
        scale_x_continuous(limits = c(0, 80))+
        theme_minimal()+
        labs(
            title = "True Population Score"
        )
}

make_sample_chart <- function(){
    sample_data() %>% 
        ggplot(aes(score))+
        geom_histogram(bins = 30, color = "gray35")+
        geom_vline(xintercept = mean(sample_data()$score), color = "orange")+
        scale_x_continuous(limits = c(0, 80))+
    theme_minimal()+
        labs(
            title = "Sample Score"
        )
}

make_ps_chart <- function(){
    my_mean <- svymean(~score, ps_sample_data())
    svyhist(~score, ps_sample_data(), breaks = 30, 
            main = "Post-Stratified Score", xlim = c(0,80), col = "gray35", lty=0,
            adj = 0)
    abline(v = my_mean[[1]], lwd = 2, col = "orange")
        
}

make_metrics <- function(){
    true_values <- population_data() %>% 
        summarise(mean = mean(score),
                  SE = sd(score)) %>% 
        mutate(id = "Population") 
    
    sample_values <- sample_data() %>% 
        summarise(mean = mean(score),
                  SE = sd(score)) %>% 
            mutate(id = "Unweighted Sample")
    
    ps_values <- svymean(~score, ps_sample_data()) %>% 
        as_tibble() %>% 
        setNames(c("mean", "SE")) %>% 
        mutate(id = "Post-Stratified Sample")
    
    output <- true_values %>% 
        bind_rows(sample_values) %>% 
        bind_rows(ps_values) %>% 
        dplyr::select(id, mean, SE) %>% 
        rename(`Method` = id) %>% 
        mutate_if(is.numeric, round, digits = 1)
    
    output
}

# Combined chart

make_all_chart <- function(){
    ps_version <- sample_data() %>% 
        tibble::add_column(wts = weights(ps_sample_data()))
    
    ps_values <- svymean(~score, ps_sample_data())
    
    svyhist(~score, ps_sample_data(), breaks = 30, main = "Combined Results", xlim = c(0,80), freq = FALSE)
    lines(density(population_data()$score, col=rgb(0,0,1,1/4)), col = "blue")
    lines(density(sample_data()$score, col=rgb(1,0,0,1/4)), col = "red")
    abline(v = mean(population_data()$score), lwd = 3, col = "blue")
    abline(v = mean(sample_data()$score), lwd = 3, lty = 2, col = "red")
    abline(v = ps_values[1], lwd = 3, lty = 3, col = "goldenrod")
    legend("topleft", 
           legend = c("Population", "Unweighted Sample", "Post-Stratified"),
           lty=c(1,2,3),
           col = c("blue", "red", "goldenrod"),  box.lty=0, text.font=2)
}

# Render Chart Outputs

output$population_chart <- renderPlot({
    make_population_chart()
})

output$sample_chart <- renderPlot({
    make_sample_chart()
})

output$ps_chart <- renderPlot({
    make_ps_chart()
})

output$all_charts <- renderPlot({
    make_all_chart()
})

output$result_table <- renderTable(
    make_metrics()
)

output$alt_output <- renderPlot(

    plot_grid(make_population_chart(), tableGrob(make_metrics(), rows = NULL), 
              make_sample_chart(), make_ps_chart() %>% recordPlot(), nrow = 2)
)

})
