
# Load necessary libraries
library(shiny)
library(quantmod)

# Define UI
ui <- fluidPage(
  titlePanel("Resumen Proyecto Grupo 13"),
  h2("Note:"),
  p("This is a simple Shiny app for plotting stock prices. Please enter a valid stock symbol and click 'Plot'."),
  sidebarLayout(
    sidebarPanel(
      textInput("symbol", "Enter Stock Symbol:", value = "AAPL"),
      actionButton("plot", "Plot")
    ),
    mainPanel(
      plotOutput("pricePlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  observeEvent(input$plot, {
    symbol <- input$symbol
    data <- getSymbols(symbol, src = "yahoo", auto.assign = FALSE)
    output$pricePlot <- renderPlot({
      chartSeries(data, theme = chartTheme("white"), name = paste("Stock Prices for", symbol))
      title(ylab = "Price (in market currency)")
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
