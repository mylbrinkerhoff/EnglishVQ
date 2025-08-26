#----------------------------------------------------------------------------------------
# File: 02_standardization.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-25 (M)
# Description: Transforms all the variables into z-scores to make it easier to compare
#              across speakers. SOE_mean transformed according to Garellek et al. (2020).
#
# Usage:
#   Rscript 02_standardization.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# Standardization across all pertinate columns. Variables are speaker normalized.

vq_clean <- vq_clean |>
  dplyr::group_by(Talker) |>
  dplyr::mutate(
    dplyr::across(
      .cols = -c(1:8),
      .fns = ~ (. - mean(., na.rm = TRUE) / sd(., na.rm = TRUE)),
      .names = "{.col}_z"
    )
  )

# normalize soe
vq_clean <- vq_clean |>
  dplyr::group_by(Talker) |>
  dplyr::mutate(
    log_soe = log10(soe_mean + 0.001),
    m_log_soe = mean(log_soe, na.rm = T),
    sd_log_soe = sd(log_soe, na.rm = T),
    z_log_soe = (log_soe - m_log_soe) / sd_log_soe,
    max_soe = max(log_soe),
    min_soe = min(log_soe),
    soe_norm = (log_soe - min_soe) / (max_soe - min_soe)
  ) |>
  dplyr::select(
    -c(log_soe, m_log_soe, sd_log_soe, z_log_soe, max_soe, min_soe)
  ) |>
  dplyr::ungroup()
