############################################################
# Script 01 – Data and Preprocessing
# Project: Urban PM2.5 Methodology
#
# Objetivo:
# - Cargar los datos diarios de PM2.5
# - Documentar su origen y estructura
# - Verificar integridad temporal y valores
# - Dejar un dataset analítico limpio y reproducible
#
# Este script implementa la primera fase del pipeline
# metodológico del proyecto: datos y preprocesamiento.
############################################################

# ----------------------------------------------------------
# 1. Configuración inicial
# ----------------------------------------------------------

# Cargar librerías necesarias
library(dplyr)
library(lubridate)
library(readr)

# Opcional: establecer opciones generales
options(stringsAsFactors = FALSE)

# ----------------------------------------------------------
# 2. Carga de datos PM2.5
# ----------------------------------------------------------

# Definir rutas del proyecto (relativas al script)
data_dir <- "data"

pm25_file <- file.path(
  data_dir,
  "PM25_EscuelasAguirre_Daily_2021_2023.csv"
)

# Comprobar que el fichero existe
stopifnot(file.exists(pm25_file))

# Lectura del CSV
pm25_raw <- read_csv(pm25_file)

glimpse(pm25_raw)

# ----------------------------------------------------------
# 3. Documentación del dataset
# ----------------------------------------------------------

# El dataset contiene:
# - date: fecha del dato diario (YYYY-MM-DD)
# - pm25_ug_m3: concentración diaria de PM2.5 en µg/m³
#
# Fuente:
# Red oficial de vigilancia de la calidad del aire
# Estación: Escuelas Aguirre (28079008)
# Tipo de dato: diario validado
# Periodo: 2021–2023

# ----------------------------------------------------------
# 4. Preprocesamiento básico
# ----------------------------------------------------------

pm25_clean <- pm25_raw %>%
  mutate(
    date = as.Date(date)
  ) %>%
  arrange(date)

# Comprobación de duplicados
stopifnot(nrow(pm25_clean) == n_distinct(pm25_clean$date))

# Comprobación de valores negativos
stopifnot(all(pm25_clean$pm25_ug_m3 >= 0))

# ----------------------------------------------------------
# 5. Verificación temporal
# ----------------------------------------------------------

# Rango temporal
range(pm25_clean$date)

# Comprobación de continuidad diaria
expected_dates <- seq(
  from = min(pm25_clean$date),
  to   = max(pm25_clean$date),
  by   = "day"
)

missing_dates <- setdiff(expected_dates, pm25_clean$date)

length(missing_dates)
# Si este valor es 0, la serie es temporalmente completa

# ----------------------------------------------------------
# 6. Estadísticos descriptivos básicos
# ----------------------------------------------------------

summary(pm25_clean$pm25_ug_m3)

# ----------------------------------------------------------
# 7. Dataset final
# ----------------------------------------------------------

# Este dataset se utilizará en las siguientes fases:
# - análisis exploratorio
# - correlaciones
# - modelización

pm25_final <- pm25_clean

# Guardar dataset procesado (opcional pero recomendable)
write_csv(
  pm25_final,
  "data/PM25_EscuelasAguirre_Daily_2021_2023_clean.csv"
)

# ----------------------------------------------------------
# Fin del Script 01
# ----------------------------------------------------------
