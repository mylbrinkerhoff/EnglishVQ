#----------------------------------------------------------------------------------------
# File: 05_splitTest.R
# Project:
# Author: Mykel Brinkerhoff
# Date: 2025-08-26 (Tu)
# Description: What does this script do?
#
# Usage:
#   Rscript 05_splitTest.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# stratified sampling with the rsample package
set.seed(123) # needed for reproducibility
vq_split <- rsample::initial_split(vq_clean, prop = 0.7)
vq_train <- rsample::training(vq_split)
vq_test <- rsample::testing(vq_split)
