#----------------------------------------------------------------------------------------
# File: 00_startHere.R
# Project: EnglishVQ
# Author: Mykel Brinkerhoff
# Date: 2025-08-25 (M)
# Description: This script loads in the the VoicesVQ_data.csv file and required packages
#
# Usage:
#   Rscript 00_startHere.R
#
# Notes:
#   - Ensure all required packages are installed.
#   - Modify the script as needed for your specific dataset and analysis requirements.
#----------------------------------------------------------------------------------------

### install packages if not yet installed
renv::restore()

# Modeling process packages
library(lme4) # for creating residual H1*
library(rsample) # for resampling procedures
library(caret) # for resampling and model training
library(randomForest) # for tree generation
library(vip) # for feature interpretation
library(ranger) # for performing Random Forest CART analysis

# Helper packages
library(tidyverse) # for data manipulation, graphic, and data wrangling
library(viridis) # for colorblind friendly colors in ggplot
library(here) # for creating pathways relative to the top-level directory
library(reshape2) # for data manipulation
library(Cairo) # for saving the plots as .eps files
library(cowplot) # For creating complex plots


# Load in the raw vq data at data/raw/VoicesVQ_data.csv
vq_raw <- readr::read_csv(here::here("data", "raw", "VoicesVQ_data.csv"))

# load in the classification data at data/raw/b-c_voice_cluster_labels.csv
vq_classification <- readr::read_csv(here::here(
  "data",
  "raw",
  "b-c_voice_cluster_labels.csv"
))

# Create a variable for colorblind palette
colorblind <- grDevices::palette.colors(palette = "Okabe-Ito")
