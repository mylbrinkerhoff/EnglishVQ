#----------------------------------------------------------------------------------------
# File: 01_data_shaping.R
# Project: EnglishVQPerception
# Author: Mykel Brinkerhoff
# Date: 2025-08-25 (M)
# Description: Manipulates the data for analysis
#
# Usage:
#   Rscript 01_data_shaping.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

write.csv(
  slz_trans,
  file = "data/interim/slz_transformed.csv",
  row.names = F,
  fileEncoding = "UTF-8"
)
