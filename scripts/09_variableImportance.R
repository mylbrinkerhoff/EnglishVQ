#----------------------------------------------------------------------------------------
# File: 09_variableImportance.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-26 (Tu)
# Description: Plots the variable importance.
#
# Usage:
#   Rscript .R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

# Extract variable importance scores for impurity-based importance
impurity_scores <- vip::vi(vq_final_impurity)

# Extract variable importance scores for permutation-based importance
permutation_scores <- vip::vi(vq_final_permutation)

# Create a Lollipop chart of variable importance scores
impurity_plot <- impurity_scores |>
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
impurity_plot

permutation_plot <- permutation_scores |>
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
permutation_plot

variable_importance_plot <- cowplot::plot_grid(
  impurity_plot,
  permutation_plot,
  nrow = 1
)
variable_importance_plot
