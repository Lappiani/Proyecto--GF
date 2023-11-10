library(shiny)
library(quantmod)
library(plotly)

shinyUI(fluidPage(
  titlePanel("Stock Price Viewer"),
  sidebarLayout(
    sidebarPanel(
      textInput("ticker", "Enter Stock Ticker (e.g., AAPL):"),
      dateRangeInput("dateRange", "Date Range:", start = "2020-01-01", end = "2022-12-31"),
      actionButton("plotButton", "Plot Stock Price")
    ),
    mainPanel(
      plotlyOutput("stockPlot")
    )
  )
))

shinyServer(function(input, output) {
  observeEvent(input$plotButton, {
    tryCatch({
      # Get the stock price data
      stock_data <- getSymbols(input$ticker, from = input$dateRange[1], to = input$dateRange[2], auto.assign = FALSE)
      
      # Create a plot using Plotly
      output$stockPlot <- renderPlotly({
        plot_ly(data = stock_data, x = index(stock_data), y = stock_data[, "Close"], type = 'scatter', mode = 'lines', name = 'Stock Price')
      })
    }, error = function(e) {
      showNotification("Error: Unable to fetch stock data. Please check the stock ticker symbol.", type = "error")
    })
  })
})
