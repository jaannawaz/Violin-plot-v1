library(shiny)
library(ggplot2)
library(ggpubr)
library(rstatix)

# Define UI
ui <- fluidPage(
    titlePanel("Violin Plot Generator"),
    
    sidebarLayout(
        sidebarPanel(
            # File upload
            fileInput("file", "Upload CSV file", accept = c(".csv")),
            
            # Figure dimensions
            numericInput("figure_width", "Figure width:", 8, min = 1, max = 20),
            numericInput("figure_height", "Figure height:", 6, min = 1, max = 20),
            
            # Axis limits
            numericInput("y_min", "Y-axis minimum:", 0),
            numericInput("y_max", "Y-axis maximum:", 40),
            
            # Font sizes
            numericInput("ticks_fontsize", "Ticks fontsize:", 12),
            numericInput("ticks_rotation", "Ticks rotation:", 0),
            numericInput("label_fontsize", "Label fontsize:", 16),
            numericInput("legend_title_fontsize", "Legend title fontsize:", 12),
            numericInput("legend_size", "Legend size:", 12),
            
            # Colors
            textInput("color_low", "Color (low):", "#E64B35"),
            textInput("color_middle", "Color (middle):", "#4DBBD5"),
            textInput("color_high", "Color (high):", "#00A087"),
            
            # Statistical method
            selectInput("stat_method", "Statistical method:",
                       choices = c(
                           "t.test (two groups)" = "t.test",
                           "Wilcoxon test (two groups)" = "wilcox.test",
                           "ANOVA (multi groups)" = "anova",
                           "Kruskal-Wallis (multi groups)" = "kruskal"
                       )),
            
            # Comparison pairs
            checkboxGroupInput("comparisons", "Select comparisons:",
                             choices = c(
                                 "low vs middle" = "low_middle",
                                 "middle vs high" = "middle_high",
                                 "low vs high" = "low_high"
                             ),
                             selected = c("low_middle", "middle_high", "low_high")),
            
            # Download button
            downloadButton("downloadPlot", "Download Plot (PNG)")
        ),
        
        mainPanel(
            plotOutput("violinPlot", height = "600px"),
            verbatimTextOutput("statTest")
        )
    )
)

# Define server logic
server <- function(input, output) {
    
    # Create the violin plot
    plot_violin <- reactive({
        req(input$file)
        
        data <- read.csv(input$file$datapath)
        
        # Create comparison list
        comparisons <- list()
        if("low_middle" %in% input$comparisons) comparisons[[length(comparisons) + 1]] <- c("low", "middle")
        if("middle_high" %in% input$comparisons) comparisons[[length(comparisons) + 1]] <- c("middle", "high")
        if("low_high" %in% input$comparisons) comparisons[[length(comparisons) + 1]] <- c("low", "high")
        
        # Statistical test method
        test_method <- switch(input$stat_method,
                            "t.test" = "t.test",
                            "wilcox.test" = "wilcox.test",
                            "anova" = "anova",
                            "kruskal" = "kruskal.test")
        
        # Create plot
        p <- ggviolin(data, x = "condition", y = "len", fill = "condition",
                     add = "boxplot", 
                     add.params = list(fill = "white")) +
            scale_fill_manual(values = c(
                "low" = input$color_low,
                "middle" = input$color_middle,
                "high" = input$color_high
            )) +
            theme_minimal() +
            theme(
                axis.text = element_text(size = input$ticks_fontsize,
                                       angle = input$ticks_rotation),
                axis.title = element_text(size = input$label_fontsize),
                legend.title = element_text(size = input$legend_title_fontsize),
                legend.text = element_text(size = input$legend_size)
            ) +
            ylim(input$y_min, input$y_max)
        
        # Add statistical comparisons
        if(length(comparisons) > 0) {
            p <- p + stat_compare_means(
                comparisons = comparisons,
                method = test_method,
                label = "p.format"
            )
        }
        
        # Add overall p-value for ANOVA or Kruskal-Wallis
        if(input$stat_method %in% c("anova", "kruskal")) {
            p <- p + stat_compare_means(method = test_method)
        }
        
        p
    })
    
    # Display plot
    output$violinPlot <- renderPlot({
        print(plot_violin())
    }, height = function() input$figure_height * 100,
       width = function() input$figure_width * 100)
    
    # Download handler
    output$downloadPlot <- downloadHandler(
        filename = function() {
            paste("violin_plot_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png", sep = "")
        },
        content = function(file) {
            ggsave(file, plot = plot_violin(),
                   width = input$figure_width,
                   height = input$figure_height,
                   dpi = 300)
        }
    )
    
    # Display statistical test results
    output$statTest <- renderPrint({
        req(input$file)
        data <- read.csv(input$file$datapath)
        
        cat("Statistical Analysis Results:\n\n")
        
        # Perform statistical test based on selection
        if(input$stat_method == "t.test" || input$stat_method == "wilcox.test") {
            for(comp in input$comparisons) {
                groups <- strsplit(comp, "_")[[1]]
                test_data <- subset(data, condition %in% groups)
                
                if(input$stat_method == "t.test") {
                    result <- t.test(len ~ condition, data = test_data)
                } else {
                    result <- wilcox.test(len ~ condition, data = test_data)
                }
                
                cat("\nComparison:", paste(groups, collapse = " vs "), "\n")
                print(result)
            }
        } else if(input$stat_method == "anova") {
            result <- aov(len ~ condition, data = data)
            print(summary(result))
            # Add Tukey post-hoc test
            cat("\nTukey Post-hoc Test:\n")
            print(TukeyHSD(result))
        } else if(input$stat_method == "kruskal") {
            result <- kruskal.test(len ~ condition, data = data)
            print(result)
            # Add Dunn's test
            cat("\nDunn's Post-hoc Test:\n")
            print(dunn_test(data, len ~ condition, p.adjust.method = "bonferroni"))
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)