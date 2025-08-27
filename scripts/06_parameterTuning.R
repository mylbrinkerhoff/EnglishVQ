#----------------------------------------------------------------------------------------
# File: 06_parameterTuning.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-26 (Tu)
# Description: Performs a hypergrid parameter tuning to determine the best parameters for
#              Random Forest analysis.
#
# Usage:
#   Rscript 06_parameterTuning.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# determine the number of features
n_features <- length(setdiff(names(vq_clean), "Phonation"))

# Train a default Random Forest model for comparison
vq_default <- ranger::ranger(
  formula = Phonation ~ .,
  data = vq_train,
  num.trees = n_features * 100,
  mtry = floor(sqrt(n_features)),
  respect.unordered.factors = "order",
  seed = 123
)

# default prediction error for comparison
default_error <- vq_default$prediction.error

# generate hypergrid paramaters
hypergrid <- expand.grid(
  mtry = floor(n_features * c(.05, .15, .2, .25, .333, .4, 1)),
  min.node.size = c(1, 3, 5, 10),
  replace = c(TRUE, FALSE),
  sample.fraction = c(.5, .63, .8),
  error = NA
)

# execute full grid search
for (i in seq_len(nrow(hypergrid))) {
  # fit the model with the i-th hyperparameter combonation
  fit <- ranger::ranger(
    formula = Phonation ~ .,
    data = vq_train,
    num.trees = n_features * 100,
    mtry = hypergrid$mtry[i],
    min.node.size = hypergrid$min.node.size[i],
    replace = hypergrid$replace[i],
    sample.fraction = hypergrid$sample.fraction[i],
    respect.unordered.factors = "order",
    seed = 123
  )

  # export OOB RMSE
  hypergrid$error[i] <- fit$prediction.error
}

# assessing the model parameters
hypergrid %>%
  dplyr::arrange(error) %>%
  dplyr::mutate(perc_gain = (default_error - error) / default_error * 100) %>%
  head(10)
