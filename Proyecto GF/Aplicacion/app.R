# Load necessary libraries
library(shiny)
library(quantmod)
library(ggplot2)
library(dplyr)
library(rsconnect)
library(PerformanceAnalytics)
library(DT)

# Define UI
ui <- fluidPage(
  titlePanel("Stock Price App"),
  h3("Note:"),
  p("This is a simple Shiny app for plotting stock prices and options strike prices. Please enter a valid stock symbol and click 'Plot'."),
  sidebarLayout(
    sidebarPanel(
      textInput("symbol", "Enter Stock Symbol:", value = "AAPL"),
      dateRangeInput("dates", "Date range:", start = Sys.Date() - 30, end = Sys.Date()),
      actionButton("plot", "Plot")
    ),
    mainPanel(
      navlistPanel(
        # Added the "Returns" tab
        tabPanel("Price", plotOutput("pricePlot")),
        tabPanel("Volume", plotOutput("volumePlot")),
        tabPanel("Options", plotOutput("optionsPlot")),
        tabPanel("Returns", DT::dataTableOutput("returnsTable"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  observeEvent(input$plot, {
    symbol <- input$symbol
    start_date <- input$dates[1]
    end_date <- input$dates[2]
    data <- getSymbols(symbol, src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)
    
    # Calculate the returns
    returns <- dailyReturn(data)
    monthly_return <- tail(monthlyReturn(data), 1)
    ytd_return <- Return.cumulative(returns[index(returns) >= as.Date(paste0(format(Sys.Date(), "%Y"), "-01-01"))])
    
    # Create a datatable object
    returns_table <- DT::datatable(
      data.frame(
        "Monthly Return" = monthly_return*100,
        "YTD Return" = ytd_return*100
      ),
      rownames = FALSE,
      colnames = c("Monthly Return (%)", "YTD Return (%)")
    )
    
    
    # Set the page layout option
    returns_table <- returns_table
    
    # Render the datatable object
    output$returnsTable <- renderDT(returns_table)
    
    # Render the plots
    output$pricePlot <- renderPlot({
      chartSeries(data, theme = chartTheme("white"), name = paste("Stock Prices for", symbol))
      title(ylab = "Price (in market currency)")
    })
    output$volumePlot <- renderPlot({
      barChart(data, theme = chartTheme("white"), name = paste("Trading Volume for", symbol))
      title(ylab = "Volume")
    })
    output$optionsPlot <- renderPlot({
      options_data <- getOptionChain(symbol)
      calls <- options_data$calls
      puts <- options_data$puts
      options_df <- rbind(calls, puts)
      options_df %>%
        ggplot(aes(x = Strike, y = Last)) +
        geom_point() +
        labs(title = paste("Options Strike Prices for", symbol), x = "Strike Price", y = "Last Price")
    })
    
  })
}

# Run the application
shinyApp(ui = ui, server = server)
