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

# Factorizing the phonation variable
vq_clean$Phonation <- factor(vq_clean$Phonation)

# remove all columns except Phonation and the standardized data
vq_clean <- vq_clean |>
  dplyr::select(
    Phonation,
    dplyr::ends_with("_z"),
    soe_norm,
    resid_H1c
  ) |>
  dplyr::rename_with(~ stringr::str_remove_all(., "_mean_z$|_z$|_norm$")) |>
  dplyr::select(-dplyr::matches("u$"))

# stratified sampling with the rsample package with respect to phonation
set.seed(123) # needed for reproducibility
vq_split <- rsample::initial_split(vq_clean, prop = 0.7, strata = "Phonation")
vq_train <- rsample::training(vq_split)
vq_test <- rsample::testing(vq_split)

# do the test and traing sets have consistant ratios
table(vq_train$Phonation) |> prop.table()
table(vq_test$Phonation) |> prop.table()
