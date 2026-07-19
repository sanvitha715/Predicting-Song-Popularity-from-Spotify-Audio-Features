# ============================================================================
# Predicting Song Popularity from Spotify Audio Features
# ============================================================================
# Multiple linear regression analysis of ~18,835 songs pulled from the Spotify
# Web API. Models song popularity (0-100) as a function of audio features,
# using forward stepwise selection and 5-fold cross-validation.
#
# NOTE ON DATA: The dataset was collected from the Spotify Web API for academic
# use and is not redistributed here. This script expects a data frame `songs`
# with one row per track and the audio-feature columns referenced below. See
# data/README.md for the fields used. Results depend on the specific data pull;
# the values reported in the poster correspond to the original dataset.
# ============================================================================

# ---- Packages --------------------------------------------------------------
library(tidyverse)   # data manipulation and plotting
library(caret)       # cross-validation utilities

set.seed(42)         # reproducibility


# ---- 1. Load data ----------------------------------------------------------
# Replace the path below with your local data file (CSV export of the API pull).
# The Spotify Web API returns audio features per track; here we assume they have
# been collected into a single CSV.
songs <- read_csv("data/spotify_songs.csv")

# Expected columns (rename here if yours differ):
#   song_popularity, danceability, energy, loudness, tempo, audio_valence,
#   acousticness, speechiness, instrumentalness, liveness, song_duration_ms,
#   key, audio_mode, time_signature


# ---- 2. Clean and prepare --------------------------------------------------

# Keep the response and the predictors used in the analysis
songs <- songs %>%
  select(
    song_popularity,
    danceability, energy, loudness, tempo, audio_valence,
    acousticness, speechiness, instrumentalness, liveness, song_duration_ms,
    key, audio_mode, time_signature
  ) %>%
  drop_na()

# Remove extreme outliers using the IQR method on the numeric predictors
numeric_vars <- c("danceability", "energy", "loudness", "tempo", "audio_valence",
                  "acousticness", "speechiness", "instrumentalness",
                  "liveness", "song_duration_ms")

remove_outliers <- function(df, cols) {
  for (col in cols) {
    q1  <- quantile(df[[col]], 0.25, na.rm = TRUE)
    q3  <- quantile(df[[col]], 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    lower <- q1 - 1.5 * iqr
    upper <- q3 + 1.5 * iqr
    df <- df[df[[col]] >= lower & df[[col]] <= upper, ]
  }
  df
}

songs <- remove_outliers(songs, numeric_vars)

# Convert categorical variables (key, mode, time signature) to factors
# so they enter the model as dummy variables
songs <- songs %>%
  mutate(
    key            = factor(key),
    audio_mode     = factor(audio_mode),
    time_signature = factor(time_signature)
  )


# ---- 3. Train / test split (75% / 25%) -------------------------------------
train_index <- createDataPartition(songs$song_popularity, p = 0.75, list = FALSE)
train <- songs[train_index, ]
test  <- songs[-train_index, ]


# ---- 4. Forward stepwise selection -----------------------------------------
# Start from an intercept-only model and add predictors that improve fit,
# scoping to the full model with all audio features.
null_model <- lm(song_popularity ~ 1, data = train)
full_model <- lm(song_popularity ~ ., data = train)

fitted_model <- step(
  null_model,
  scope     = list(lower = null_model, upper = full_model),
  direction = "forward",
  trace     = FALSE
)

summary(fitted_model)


# ---- 5. Evaluate on the test set -------------------------------------------
rmse <- function(actual, predicted) sqrt(mean((actual - predicted)^2))

null_pred   <- predict(null_model,   newdata = test)
fitted_pred <- predict(fitted_model, newdata = test)

null_rmse   <- rmse(test$song_popularity, null_pred)
fitted_rmse <- rmse(test$song_popularity, fitted_pred)

cat("Test RMSE - null model:  ", round(null_rmse, 2), "\n")
cat("Test RMSE - fitted model:", round(fitted_rmse, 2), "\n")

# ANOVA comparing null vs. fitted
anova(null_model, fitted_model)


# ---- 6. 5-fold cross-validation --------------------------------------------
cv_control <- trainControl(method = "cv", number = 5)

cv_model <- train(
  formula(fitted_model),
  data      = train,
  method    = "lm",
  trControl = cv_control
)

print(cv_model)


# ---- 7. Diagnostic plots ---------------------------------------------------
# Residuals vs. fitted (checks linearity and constant variance) and
# Q-Q plot (checks normality of residuals).
par(mfrow = c(1, 2))
plot(fitted_model, which = 1)   # residuals vs fitted
plot(fitted_model, which = 2)   # normal Q-Q
par(mfrow = c(1, 1))

# ---- Notes -----------------------------------------------------------------
# The poster reports: adjusted R-squared ~ 0.047, test RMSE ~ 21.73 (fitted)
# vs 22.17 (null), ANOVA p < 0.001. Exact figures depend on the data pull,
# the random seed, and the train/test split.
