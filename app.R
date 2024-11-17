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
            
            # Dynamic comparison pairs
            uiOutput("comparison_ui"),
            
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
server <- function(input, output, session) {
    
    # Reactive expression to read data and identify columns
    data_reactive <- reactive({
        req(input$file)
        data <- read.csv(input$file$datapath)
        list(data = data, condition_col = names(data)[1], value_col = names(data)[2])
    })
    
    # Update comparison pairs based on the uploaded data
    output$comparison_ui <- renderUI({
        req(data_reactive())
        data <- data_reactive()$data
        condition_col <- data_reactive()$condition_col
        
        # Get unique groups
        unique_groups <- unique(data[[condition_col]])
        
        # Create comparison pairs
        comparisons <- combn(unique_groups, 2, simplify = FALSE)
        comparison_choices <- sapply(comparisons, function(x) paste(x, collapse = " vs "))
        
        checkboxGroupInput("comparisons", "Select comparisons:", choices = comparison_choices)
    })
    
    # Create the violin plot
    plot_violin <- reactive({
        req(data_reactive())
        
        data <- data_reactive()$data
        condition_col <- data_reactive()$condition_col
        value_col <- data_reactive()$value_col
        
        # Create plot
        p <- ggviolin(data, x = condition_col, y = value_col, fill = condition_col,
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
        if(length(input$comparisons) > 0) {
            comparisons <- strsplit(input$comparisons, " vs ")
            comparisons <- lapply(comparisons, function(x) x)
            p <- p + stat_compare_means(
                comparisons = comparisons,
                method = input$stat_method,
                label = "p.format"
            )
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
        req(data_reactive())
        data <- data_reactive()$data
        condition_col <- data_reactive()$condition_col
        value_col <- data_reactive()$value_col
        
        cat("Statistical Analysis Results:\n\n")
        
        # Perform statistical test based on selection
        if(input$stat_method == "t.test" || input$stat_method == "wilcox.test") {
            for(comp in input$comparisons) {
                groups <- strsplit(comp, " vs ")[[1]]
                
                # Check if both groups exist in the data
                if (all(groups %in% unique(data[[condition_col]])) && length(groups) == 2) {
                    test_data <- subset(data, data[[condition_col]] %in% groups)
                    
                    if(input$stat_method == "t.test") {
                        result <- t.test(data[[value_col]] ~ data[[condition_col]], data = test_data)
                    } else {
                        result <- wilcox.test(data[[value_col]] ~ data[[condition_col]], data = test_data)
                    }
                    
                    cat("\nComparison:", paste(groups, collapse = " vs "), "\n")
                    print(result)
                } else {
                    cat("\nComparison:", paste(groups, collapse = " vs "), " - Not enough data\n")
                }
            }
        } else if(input$stat_method == "anova") {
            result <- aov(data[[value_col]] ~ data[[condition_col]], data = data)
            print(summary(result))
            # Add Tukey post-hoc test
            cat("\nTukey Post-hoc Test:\n")
            print(TukeyHSD(result))
        } else if(input$stat_method == "kruskal") {
            result <- kruskal.test(data[[value_col]] ~ data[[condition_col]], data = data)
            print(result)
            # Add Dunn's test
            cat("\nDunn's Post-hoc Test:\n")
            print(dunn_test(data, data[[value_col]] ~ data[[condition_col]], p.adjust.method = "bonferroni"))
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)