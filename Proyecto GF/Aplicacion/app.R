# Load necessary libraries
library(shiny)
library(quantmod)
library(ggplot2)
library(rsconnect)
library(PerformanceAnalytics)
library(dplyr)

# Define UI
ui <- fluidPage(
  titlePanel("Aplicación Grupo 13 Proyecto"),
  h3("Nota:"),
  p("Esta aplicación es un dashboard que entrega los principales gráficos que fueron añadidos en el proyecto del ramo. Es importante que el ticker ingresado sea valido."),
  p("Los ticker en este caso particular eran: [Bolsa de Santiago] CHILE.SN, PARAUCO.SN y COPEC.SN"),
  p("Un último aspecto que es importante destacar es que dependiendo del ticker, la moneda en la cual se representa el precio cambia."),
  sidebarLayout(
    sidebarPanel(
      textInput("symbol", "Ingrese un ticker:", value = "AAPL"),
      dateRangeInput("dates", "Rango de fechas:", start = Sys.Date() - 30, end = Sys.Date()),
      actionButton("plot", "Plot")
    ),
    mainPanel(
      navlistPanel(
        # Added the "Returns" tab
        tabPanel("Precio y volumen", plotOutput("pricePlot")),
        tabPanel("Opciones", plotOutput("optionsPlot"))
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
    
    
    # Render the plots
    output$pricePlot <- renderPlot({
      chartSeries(data, theme = chartTheme("white"), name = paste("Precios para", symbol))
      title(ylab = "Precio (en la moneda del mercado respectivo)")
    })
    output$volumePlot <- renderPlot({
      barChart(data, theme = chartTheme("white"), name = paste("Volumen para", symbol))
      title(ylab = "Volumen")
    })
    output$optionsPlot <- renderPlot({
      options_data <- getOptionChain(symbol)
      calls <- options_data$calls
      puts <- options_data$puts
      options_df <- rbind(calls, puts)
      options_df %>%
        ggplot(aes(x = Strike, y = Last)) +
        geom_point() +
        labs(title = paste("Precios del ejercicio para", symbol), x = "Precio del ejercicio", y = "Último precio")
    })
    
  })
}

# Run the application
shinyApp(ui = ui, server = server)
