#----------------------------------------------------------------------------------------
# File: 07_treeNumber.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: YYYY-MM-DD (M-Su)
# Description: What does this script do?
#
# Usage:
#   Rscript 07_treeNumber.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# create a hypergrid for number of trees
hypergrid_trees <- expand.grid(
  num.trees = seq(50, 2000, 50),
  mtry = floor(n_features * c(.05, .15, .2, .25, .333, .4, 1)),
  accuracy = NA
)

# perform grid search for correct number of trees
for (i in seq_len(nrow(hypergrid_trees))) {
  # fit the model with i-th hyperparameter combination
  fit_trees <- ranger::ranger(
    formula = Phonation ~ .,
    data = vq_train,
    num.trees = hypergrid_trees$num.trees[i],
    mtry = hypergrid_trees$mtry[i],
    min.node.size = 1,
    replace = FALSE,
    sample.fraction = 0.63,
    respect.unordered.factors = "order",
    seed = 123
  )

  # export OOB RMSE
  hypergrid_trees$accuracy[i] <- fit_trees$prediction.error
}

# determine what the best number of trees
hypergrid_trees %>%
  dplyr::arrange(accuracy) %>%
  mutate(perc_gain = (default_error - accuracy) / default_error * 100) %>%
  head(10)

# plotting the results
hypergrid_trees %>%
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
