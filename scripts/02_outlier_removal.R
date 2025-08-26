#----------------------------------------------------------------------------------------
# File: 02_outlier_removal.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-25 (M)
# Description: Removes outliers based on f0, Formants, and Energy
#
# Usage:
#   Rscript 02_outlier_removal.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# Adding function for calculating Mahalanobis distance
source(here::here("scripts", "functions", "vmahalanobis.R"))

# create a new dataframe for the cleaned data
vq_clean <- vq_raw

# flag for f0 outliers
vq_clean <- vq_clean |>
  dplyr::group_by(Talker) |>
  dplyr::mutate(
    F0z = (strF0_mean - mean(strF0_mean, na.rm = T)) / sd(strF0_mean)
  ) |>
  dplyr::ungroup()

vq_clean <- vq_clean |>
  dplyr::mutate(f0_outlier = dplyr::if_else(abs(F0z) > 3, "outlier", "OK"))

# Flag for formant outlier
## set distance cutoff for Mahalanobis distance
distance_cutoff <- 6

## calculate mahalnobis distance on formant
vq_clean <- vq_clean |>
  dplyr::group_by(Vowel) |>
  # dplyr::group_by(Talker) |>
  dplyr::do(vmahalanobis(.)) |>
  dplyr::ungroup() |>
  dplyr::mutate(formant_outlier = NA)

## visualize the formant outliers
vq_clean |>
  dplyr::filter(is.na(formant_outlier)) |>
  ggplot2::ggplot(aes(
    x = sF2_mean,
    y = sF1_mean,
    colour = zF1F2 > distance_cutoff
  )) +
  ggplot2::geom_point(size = 0.6) +
  ggplot2::facet_wrap(. ~ Vowel) +
  ggplot2::scale_x_reverse(limits = c(3500, 0), position = "top") +
  ggplot2::scale_y_reverse(limits = c(2000, 0), position = "right") +
  ggplot2::theme_bw()

for (i in 1:nrow(vq_clean)) {
  if (!is.na(vq_clean$zF1F2[i])) {
    if (vq_clean$zF1F2[i] > 6) {
      vq_clean$formant_outlier[i] <- "outlier"
    }
  }
}

## visualize with formant outliers removed
vq_clean |>
  dplyr::filter(is.na(formant_outlier)) |>
  ggplot2::ggplot(aes(
    x = sF2_mean,
    y = sF1_mean
  )) +
  ggplot2::geom_point(size = 0.6) +
  ggplot2::facet_wrap(. ~ Vowel) +
  ggplot2::scale_x_reverse(limits = c(3500, 0), position = "top") +
  ggplot2::scale_y_reverse(limits = c(2000, 0), position = "right") +
  ggplot2::theme_bw()

# flag energy outliers
## convert 0s to NA
vq_clean$Energy_mean[vq_clean$Energy_mean == 0] <- NA

## log10 transform energy
vq_clean <- vq_clean |>
  dplyr::mutate(log_energy = log10(Energy_mean))

# remove f0, formant, and energy outliers
vq_clean <- vq_clean |>
  dplyr::filter(f0_outlier == "OK") |>
  dplyr::filter(is.na(formant_outlier)) |>
  dplyr::filter(!is.na(log_energy))

# number of rows removed as outliers
nrow(vq_raw) - nrow(vq_clean)

# remove columns that where created
vq_clean <- vq_clean |>
  dplyr::select(-c(f0_outlier, formant_outlier, zF1F2, F0z))
