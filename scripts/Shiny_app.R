# Load necessary libraries
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(here)



# Define the UI for the app
ui <- fluidPage(
  titlePanel("Sales Data Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Summary Statistics"),
      p("This app displays the cleaned sales data and generates plots."),
      br(),
      selectInput("plot_type", "Choose a Plot:", choices = c("Sales Distribution", "Quantity Ordered", "Sales vs Quantity Ordered")),
      br(),
      downloadButton("download_data", "Download Cleaned Data")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data", DTOutput("sales_table")),
        tabPanel("Plot", plotlyOutput("plot_output"))
      )
    )
  )
)

# Define the server logic for the app
server <- function(input, output) {
  
  # Load the cleaned dataset
  cleaned_data <- read_csv(here("raw_data", "sales_data_cleaned.csv"))
  
  # Display the cleaned dataset in a table
  output$sales_table <- renderDT({
    datatable(cleaned_data)
  })
  
  # Create the plots based on user input
  output$plot_output <- renderPlotly({
    if (input$plot_type == "Sales Distribution") {
      ggplot_plot <- ggplot(cleaned_data, aes(x = SALES)) +
        geom_histogram(binwidth = 1000, fill = "blue", color = "black", alpha = 0.7) +
        labs(title = "Distribution of Sales", x = "Sales", y = "Frequency")
      ggplotly(ggplot_plot)
      
    } else if (input$plot_type == "Quantity Ordered") {
      ggplot_plot <- ggplot(cleaned_data, aes(x = QUANTITYORDERED)) +
        geom_histogram(binwidth = 1, fill = "green", color = "black", alpha = 0.7) +
        labs(title = "Distribution of Quantity Ordered", x = "Quantity Ordered", y = "Frequency")
      ggplotly(ggplot_plot)
      
    } else if (input$plot_type == "Sales vs Quantity Ordered") {
      ggplot_plot <- ggplot(cleaned_data, aes(x = QUANTITYORDERED, y = SALES)) +
        geom_point(alpha = 0.5, color = "darkblue") +
        labs(title = "Sales vs Quantity Ordered", x = "Quantity Ordered", y = "Sales")
      ggplotly(ggplot_plot)
    }
  })
  
  # Provide a download link for the cleaned data
  output$download_data <- downloadHandler(
    filename = function() {
      paste("sales_data_cleaned.csv")
    },
    content = function(file) {
      write_csv(cleaned_data, file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
