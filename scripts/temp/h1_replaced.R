#----------------------------------------------------------------------------------------
# File: h1_replaced.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-27 (W)
# Description: This takes a stab at the analysis with replacing H1* with residual H1*.
#
# Usage:
#   Rscript h1_replaced.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# uses the dataframe where residual H1* was added.

vq_resid <- vq_clean |>
  select(-H1c_mean_z)

# Factorizing the phonation variable
vq_resid$Phonation <- factor(vq_resid$Phonation)

# remove all columns except Phonation and the standardized data
vq_resid <- vq_resid |>
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
resid_split <- rsample::initial_split(
  vq_resid,
  prop = 0.7,
  strata = "Phonation"
)
resid_train <- rsample::training(resid_split)
resid_test <- rsample::testing(resid_split)

# do the test and traing sets have consistant ratios
table(resid_train$Phonation) |> prop.table()
table(resid_test$Phonation) |> prop.table()

# determine the number of features
resid_features <- length(setdiff(names(vq_resid), "Phonation"))

# Train a default Random Forest model for comparison
resid_default <- ranger::ranger(
  formula = Phonation ~ .,
  data = resid_train,
  num.trees = resid_features * 100,
  mtry = floor(sqrt(resid_features)),
  respect.unordered.factors = "order",
  seed = 123
)

# default prediction error for comparison
resid_error <- resid_default$prediction.error

# generate hypergrid paramaters
hypergrid_resid <- expand.grid(
  mtry = floor(resid_features * c(.05, .15, .2, .25, .333, .4, 1)),
  min.node.size = c(1, 3, 5, 10),
  replace = c(TRUE, FALSE),
  sample.fraction = c(.5, .63, .8),
  error = NA
)

# execute full grid search
for (i in seq_len(nrow(hypergrid_resid))) {
  # fit the model with the i-th hyperparameter combonation
  fit_resid <- ranger::ranger(
    formula = Phonation ~ .,
    data = resid_train,
    num.trees = resid_features * 100,
    mtry = hypergrid_resid$mtry[i],
    min.node.size = hypergrid_resid$min.node.size[i],
    replace = hypergrid_resid$replace[i],
    sample.fraction = hypergrid_resid$sample.fraction[i],
    respect.unordered.factors = "order",
    seed = 123
  )

  # export OOB RMSE
  hypergrid_resid$error[i] <- fit_resid$prediction.error
}

# assessing the model parameters
hypergrid_resid %>%
  dplyr::arrange(error) %>%
  dplyr::mutate(perc_gain = (resid_error - error) / resid_error * 100) %>%
  head(10)

# create a hypergrid for number of trees
hypergrid_resid_trees <- expand.grid(
  num.trees = seq(50, 2000, 50),
  mtry = floor(resid_features * c(.05, .15, .2, .25, .333, .4, 1)),
  accuracy = NA
)

# perform grid search for correct number of trees
for (i in seq_len(nrow(hypergrid_resid_trees))) {
  # fit the model with i-th hyperparameter combination
  fit_resid_trees <- ranger::ranger(
    formula = Phonation ~ .,
    data = resid_train,
    num.trees = hypergrid_resid_trees$num.trees[i],
    mtry = hypergrid_resid_trees$mtry[i],
    min.node.size = 5,
    replace = FALSE,
    sample.fraction = 0.8,
    respect.unordered.factors = "order",
    seed = 123
  )

  # export OOB RMSE
  hypergrid_resid_trees$accuracy[i] <- fit_resid_trees$prediction.error
}

# determine what the best number of trees
hypergrid_resid_trees %>%
  dplyr::arrange(accuracy) %>%
  mutate(perc_gain = (resid_error - accuracy) / resid_error * 100) %>%
  head(10)

# plotting the results
hypergrid_resid_trees %>%
  ggplot(aes(x = num.trees, y = accuracy, color = factor(mtry))) +
  geom_line(linewidth = 1) +
  # geom_line(aes(linetype = factor(mtry)), linewidth = 1) +
  labs(
    title = "Prediction error for Random Forest Hyperparameter Tuning",
    x = "number of trees",
    y = "% incorrect",
    color = "mtry"
  ) +
  scale_color_manual(values = colorblind) +
  theme_bw()

# final random forest model with impurity
resid_final_impurity <- ranger::ranger(
  formula = Phonation ~ .,
  data = resid_train,
  num.trees = 650,
  mtry = 12,
  min.node.size = 5,
  replace = FALSE,
  sample.fraction = 0.8,
  respect.unordered.factors = "order",
  seed = 123,
  classification = TRUE,
  importance = "impurity",
  probability = TRUE
)

# final model with permutation
resid_final_permutation <- ranger::ranger(
  formula = Phonation ~ .,
  data = resid_train,
  num.trees = 650,
  mtry = 12,
  min.node.size = 5,
  replace = FALSE,
  sample.fraction = 0.8,
  respect.unordered.factors = "order",
  seed = 123,
  classification = TRUE,
  importance = "permutation",
  probability = TRUE
)

# Extract variable importance scores for impurity-based importance
resid_impurity_scores <- vip::vi(resid_final_impurity)

# Extract variable importance scores for permutation-based importance
resid_permutation_scores <- vip::vi(resid_final_permutation)

# Create a Lollipop chart of variable importance scores
resid_impurity_plot <- resid_impurity_scores |>
  dplyr::rename_with(~ stringr::str_remove_all(., "_mean_z$|_z$|_norm$")) |>
  ggplot2::ggplot(
    aes(x = reorder(Variable, Importance), y = Importance)
  ) +
  geom_segment(aes(xend = Variable, yend = 0)) +
  geom_point(size = 2) +
  coord_flip() +
  labs(
    title = "Impurity Importance",
    x = "Variable",
    y = "Importance (Impurity)"
  ) +
  theme_bw()
resid_impurity_plot

resid_permutation_plot <- resid_permutation_scores |>
  ggplot2::ggplot(
    aes(x = reorder(Variable, Importance), y = Importance)
  ) +
  geom_segment(aes(xend = Variable, yend = 0)) +
  geom_point(size = 2) +
  coord_flip() +
  labs(
    title = "Permutation Importance",
    x = "Variable",
    y = "Importance (Permutation)"
  ) +
  theme_bw()
resid_permutation_plot

resid_variable_importance_plot <- cowplot::plot_grid(
  resid_impurity_plot,
  resid_permutation_plot,
  nrow = 1
)
resid_variable_importance_plot
