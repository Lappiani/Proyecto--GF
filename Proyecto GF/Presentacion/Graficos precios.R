
library(quantmod)

symbol <- 'PARAUCO.SN'
start_date <- '2023-01-03'
end_date <- '2023-11-10'

# Fetch the data
data <- getSymbols(symbol, src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)

setwd("C:/Users/USER/OneDrive/Escritorio/Gestión Financiera/Proyecto--GF")

#Plot the data
chartSeries(data, theme = chartTheme("white"), name = paste("Precio de", symbol))
title(ylab = "Precio en CLP")