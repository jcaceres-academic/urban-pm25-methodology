############################################################
# Script 02 – Exploratory and Correlation Analysis
# Project: Urban PM2.5 Methodology
############################################################

# ----------------------------------------------------------
# 1. Initial setup
# ----------------------------------------------------------

library(dplyr)
library(lubridate)
library(ggplot2)
library(readr)

options(stringsAsFactors = FALSE)

# ----------------------------------------------------------
# 2. Load clean dataset
# ----------------------------------------------------------

pm25_file <- "data/PM25_EscuelasAguirre_Daily_2021_2023_clean.csv"
stopifnot(file.exists(pm25_file))

pm25 <- read_csv(pm25_file)
stopifnot(nrow(pm25) > 0)

# Display column specification in console
spec(pm25)

# ----------------------------------------------------------
# Check monthly data availability
# ----------------------------------------------------------

monthly_counts <- pm25 %>%
  mutate(
    year_month = format(date, "%Y-%m")
  ) %>%
  count(year_month)

print(monthly_counts)

# ----------------------------------------------------------
# Identify missing months explicitly
# ----------------------------------------------------------

all_months <- seq(
  from = as.Date(format(min(pm25$date), "%Y-%m-01")),
  to   = as.Date(format(max(pm25$date), "%Y-%m-01")),
  by   = "month"
)

all_months_df <- data.frame(
  year_month = format(all_months, "%Y-%m")
)

monthly_full <- all_months_df %>%
  left_join(monthly_counts, by = "year_month")

print(monthly_full)

missing_months <- monthly_full %>%
  filter(is.na(n))

if (nrow(missing_months) == 0) {
  message("No missing months detected in the PM2.5 dataset.")
} else {
  message("Missing months detected:")
  print(missing_months)
}

# ----------------------------------------------------------
# 3. Temporal variables
# ----------------------------------------------------------

pm25 <- pm25 %>%
  mutate(
    year  = year(date),
    month = month(date)
  )

# ----------------------------------------------------------
# 4. Figures directory (explicit and verified)
# ----------------------------------------------------------

fig_dir <- "figures_tiff"

if (!dir.exists(fig_dir)) {
  dir.create(fig_dir, recursive = TRUE)
}

stopifnot(dir.exists(fig_dir))

# ----------------------------------------------------------
# 5. Time series plot (minimal and explicit)
# ----------------------------------------------------------

p_time <- ggplot(pm25, aes(x = date, y = pm25_ug_m3)) +
  geom_line(linewidth = 0.4) +
  labs(
    title = "Daily PM2.5 concentration",
    x = "Date",
    y = expression(PM[2.5]~(mu*g/m^3))
  ) +
  theme_minimal()

# Save figure
output_plot <- file.path(fig_dir, "PM25_daily_time_series.tiff")

ggsave(
  filename = output_plot,
  plot = p_time,
  width = 18,
  height = 6,
  units = "cm",
  dpi = 300
)

# Explicit verification
stopifnot(file.exists(output_plot))


# ----------------------------------------------------------
# Monthly variability (boxplot)
# ----------------------------------------------------------

pm25 <- pm25 %>%
  mutate(
    month_label = factor(
      month,
      levels = 1:12,
      labels = c("Jan","Feb","Mar","Apr","May","Jun",
                 "Jul","Aug","Sep","Oct","Nov","Dec")
    )
  )

p_monthly_box <- ggplot(pm25, aes(x = month_label, y = pm25_ug_m3)) +
  geom_boxplot(fill = "lightblue") +
  labs(
    title = "Monthly variability of PM2.5 concentrations",
    x = "Month",
    y = expression(PM[2.5]~(mu*g/m^3))
  ) +
  theme_minimal()

ggsave(
  filename = file.path(fig_dir, "PM25_monthly_boxplot.tiff"),
  plot = p_monthly_box,
  width = 14,
  height = 10,
  units = "cm",
  dpi = 300
)

stopifnot(file.exists(file.path(fig_dir, "PM25_monthly_boxplot.tiff")))

# ----------------------------------------------------------
# Monthly climatology (mean annual cycle)
# ----------------------------------------------------------

pm25_monthly_mean <- pm25 %>%
  group_by(month_label) %>%
  summarise(
    mean_pm25 = mean(pm25_ug_m3),
    .groups = "drop"
  )

p_monthly_cycle <- ggplot(pm25_monthly_mean,
                          aes(x = month_label, y = mean_pm25, group = 1)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Average annual cycle of PM2.5",
    x = "Month",
    y = expression(PM[2.5]~(mu*g/m^3))
  ) +
  theme_minimal()

ggsave(
  filename = file.path(fig_dir, "PM25_monthly_climatology.tiff"),
  plot = p_monthly_cycle,
  width = 14,
  height = 10,
  units = "cm",
  dpi = 300
)

stopifnot(file.exists(file.path(fig_dir, "PM25_monthly_climatology.tiff")))

# ----------------------------------------------------------
# End of Script 02
# ----------------------------------------------------------
