library(lme4)

# Calculates residuals of H1c after accounting for energyz and speaker effects
calc_residH1 <- function(
  df,
  h1cz_col = "h1cz", # Column name for H1c values (default: "h1cz")
  energyz_col = "energyz", # Column name for energy values (default: "energyz")
  speaker_col = "Speaker" # Column name for speaker IDs (default: "Speaker")
) {
  # Build the formula for the linear mixed-effects model
  formula <- as.formula(paste(
    h1cz_col, # Dependent variable
    "~",
    energyz_col, # Fixed effect: energyz
    "+ (",
    energyz_col,
    "||", # Random slope for energyz
    speaker_col, # Grouping factor: Speaker
    ")"
  ))

  # Fit the linear mixed-effects model using lmer
  model <- lmer(formula, data = df, REML = FALSE)

  # Extract the fixed effect coefficient for energyz
  energy_factor <- fixef(model)[2]

  # Calculate residuals: observed H1c minus predicted effect of energyz
  df$resid_H1c <- df[[h1cz_col]] - df[[energyz_col]] * energy_factor

  # Return the dataframe with the new residuals column
  return(df)
}
