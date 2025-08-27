#----------------------------------------------------------------------------------------
# File: 08_randomForest.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-26 (Tu)
# Description: Executes the final random forest model.
#
# Usage:
#   Rscript 08_randomForest.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# final random forest model with impurity
vq_final_impurity <- ranger::ranger(
  formula = Phonation ~ .,
  data = vq_train,
  num.trees = 400,
  mtry = 33,
  min.node.size = 1,
  replace = FALSE,
  sample.fraction = 0.63,
  respect.unordered.factors = "order",
  seed = 123,
  classification = TRUE,
  importance = "impurity",
  probability = TRUE
)

# final model with permutation
vq_final_permutation <- ranger::ranger(
  formula = Phonation ~ .,
  data = vq_train,
  num.trees = 400,
  mtry = 33,
  min.node.size = 1,
  replace = FALSE,
  sample.fraction = 0.63,
  respect.unordered.factors = "order",
  seed = 123,
  classification = TRUE,
  importance = "permutation",
  probability = TRUE
)
