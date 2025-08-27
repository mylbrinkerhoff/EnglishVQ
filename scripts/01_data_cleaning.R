#----------------------------------------------------------------------------------------
# File: 01_data_cleaning.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-26 (Tu)
# Description: Removes the columns that were based on Praat and other for f0, forants,
#              and bandwidths
#
# Usage:
#   Rscript 01_data_cleaning.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

vq_raw <- vq_raw |>
  dplyr::select(
    -c(
      sF0_mean,
      pF0_mean,
      shrF0_mean,
      oF0_mean,
      pF1_mean,
      pF2_mean,
      pF3_mean,
      pF4_mean,
      oF1_mean,
      oF2_mean,
      oF3_mean,
      oF4_mean,
      pB1_mean,
      pB2_mean,
      pB3_mean,
      pB4_mean,
      oB1_mean,
      oB2_mean,
      oB3_mean,
      oB4_mean
    )
  )

# left_join vq_raw with vq_classification by Gender and where Voice = Talker
vq_raw <- vq_raw |>
  dplyr::inner_join(vq_classification, by = c("Talker" = "Voice", "Gender")) |>
  dplyr::rename_at("ClusterCoding", ~"Phonation") |>
  dplyr::relocate(Phonation, .after = Label) |>
  dplyr::select(-c(median_stan_xmouse, cluster_id))
