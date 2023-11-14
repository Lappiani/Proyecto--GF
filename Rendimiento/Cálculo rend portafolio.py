import yfinance as yf
import pandas as pd

def calcular_retorno_portafolio(tickers, pesos, fecha_inicio):
    # Descargar datos de precios
    data = yf.download(tickers, start=fecha_inicio)['Adj Close']
    
    # Verificar si la fecha de inicio está en el DataFrame
    if fecha_inicio not in data.index:
        return "No se encontraron datos para la fecha de inicio especificada."
    
    # Calcular retornos para la fecha de inicio y la fecha más reciente
    precio_inicio = data.loc[fecha_inicio]
    precio_fin = data.iloc[-1]  # Última fila del DataFrame
    retornos = (precio_fin - precio_inicio) / precio_inicio
    
    # Calcular retorno del portafolio
    retorno_portafolio = retornos.dot(pesos)
    
    return retorno_portafolio

# Ejemplo de uso
tickers = ['CHILE.SN', 'PARAUCO.SN', 'COPEC.SN']  # Lista de tickers
pesos = [0.683, 0.103, 0.214]  # Pesos de los activos en el portafolio
fecha_inicio = '2023-08-08'

retorno_portafolio = calcular_retorno_portafolio(tickers, pesos, fecha_inicio)
print(f"El retorno del portafolio desde {fecha_inicio} hasta la fecha más reciente es: {retorno_portafolio}")


