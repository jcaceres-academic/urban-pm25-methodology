############################################################
# Script 03 – Modelling and Evaluation
# Project: Urban PM2.5 Methodology
#
# Purpose:
# - Define a reproducible forecasting task
# - Apply time-aware validation
# - Compare baseline and statistical models
# - Evaluate performance using robust metrics
############################################################

# ----------------------------------------------------------
# 1. Libraries
# ----------------------------------------------------------

library(dplyr)
library(lubridate)
library(readr)
library(tidyr)
library(ggplot2)

# ----------------------------------------------------------
# 2. Load clean dataset
# ----------------------------------------------------------

data_file <- "data/PM25_EscuelasAguirre_Daily_2021_2023_clean.csv"
stopifnot(file.exists(data_file))

pm25 <- read_csv(data_file)
print(spec(pm25))

pm25 <- pm25 %>% arrange(date)

# ----------------------------------------------------------
# 3. Feature engineering
# ----------------------------------------------------------

pm25_model <- pm25 %>%
  mutate(
    month = month(date),
    doy   = yday(date),
    lag_1 = lag(pm25_ug_m3, 1),
    lag_7 = lag(pm25_ug_m3, 7)
  ) %>%
  filter(!is.na(lag_1), !is.na(lag_7))

# ----------------------------------------------------------
# 4. Time-based train–test split
# ----------------------------------------------------------

train <- pm25_model %>% filter(date < as.Date("2023-01-01"))
test  <- pm25_model %>% filter(date >= as.Date("2023-01-01"))

cat(
  "Train period:",
  format(min(train$date), "%Y-%m-%d"),
  "-",
  format(max(train$date), "%Y-%m-%d"),
  "\n"
)

cat(
  "Test period :",
  format(min(test$date), "%Y-%m-%d"),
  "-",
  format(max(test$date), "%Y-%m-%d"),
  "\n"
)

# ----------------------------------------------------------
# 4. Figures directory (explicit and verified)
# ----------------------------------------------------------

fig_dir <- "figures_tiff"


# ----------------------------------------------------------
# 5. Baseline model (persistence)
# ----------------------------------------------------------

test <- test %>%
  mutate(
    pred_baseline = lag_1
  )

# ----------------------------------------------------------
# 6. Linear regression model
# ----------------------------------------------------------

lm_model <- lm(
  pm25_ug_m3 ~ lag_1 + lag_7 + month + doy,
  data = train
)

test <- test %>%
  mutate(
    pred_lm = predict(lm_model, newdata = test)
  )

# ----------------------------------------------------------
# 7. Evaluation metrics
# ----------------------------------------------------------

mae <- function(obs, pred) mean(abs(obs - pred))
rmse <- function(obs, pred) sqrt(mean((obs - pred)^2))

cat("\nModel performance:\n")

cat("Baseline (lag-1):\n")
cat("  MAE :", mae(test$pm25_ug_m3, test$pred_baseline), "\n")
cat("  RMSE:", rmse(test$pm25_ug_m3, test$pred_baseline), "\n\n")

cat("Linear model:\n")
cat("  MAE :", mae(test$pm25_ug_m3, test$pred_lm), "\n")
cat("  RMSE:", rmse(test$pm25_ug_m3, test$pred_lm), "\n")


# ----------------------------------------------------------
# 8. Visual comparison (smoothed for readability)
# ----------------------------------------------------------

library(zoo)

plot_data <- test %>%
  mutate(
    obs_smooth      = rollmean(pm25_ug_m3, 7, fill = NA, align = "right"),
    baseline_smooth = rollmean(pred_baseline, 7, fill = NA, align = "right"),
    linear_smooth   = rollmean(pred_lm, 7, fill = NA, align = "right")
  )

p_model <- ggplot(plot_data, aes(x = date)) +
  geom_line(aes(y = obs_smooth, colour = "Observed"), linewidth = 0.5) +
  geom_line(aes(y = linear_smooth, colour = "Linear model"), linewidth = 0.5) +
  # geom_line(
  #   aes(y = baseline_smooth, colour = "Baseline"),
  #   linewidth = 0.4,
  #   linetype = "dashed",
  #   alpha = 0.4
  # ) +
  scale_colour_manual(
    values = c(
      "Observed" = "steelblue",
      "Linear model" = "darkgreen",
      "Baseline" = "#7A1F2B"
    )
  ) +
  labs(
    title = "Observed vs predicted PM2.5 (2023, 7-day moving average)",
    x = "Date",
    y = expression(PM[2.5]~(mu*g/m^3)),
    colour = ""
  ) +
  theme_minimal()

print(p_model)


ggsave(
  filename = file.path(fig_dir, "PM25_observed_vs_predicted_2023.tiff"),
  plot = p_model,
  width = 18,
  height = 8,
  units = "cm",
  dpi = 300
)


# ----------------------------------------------------------
# End of Script 03
# ----------------------------------------------------------
