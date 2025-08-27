#----------------------------------------------------------------------------------------
# File: 04_residH1.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-26 (M-Su)
# Description: Calculates and adds residual H1* measure to the dataframe
#
# Usage:
#   Rscript 04_residH1.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# Adding function for calculating residual H1*
source(here::here("scripts", "functions", "calc_residH1.R"))

# Applying the function to the dataframe
vq_clean <- vq_clean |>
  calc_residH1(
    h1cz_col = "H1c_mean_z",
    energyz_col = "log_energy_z",
    speaker_col = "Talker"
  )
