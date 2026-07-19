# Predicting Song Popularity from Spotify Audio Features

A statistical modeling project investigating whether measurable audio features — danceability, energy, loudness, tempo, valence, and others — can explain and predict a song's popularity. Built in **R** using multiple linear regression with forward stepwise selection and cross-validation, on a dataset of **18,835 tracks**.

**Language:** R · **Methods:** Multiple linear regression, forward stepwise selection, 5-fold cross-validation, residual diagnostics

---

## Motivation

Music streaming platforms rely on quantifiable song characteristics — energy, acousticness, danceability, and more — to organize their catalogues and recommend tracks. This raises a natural question: **can a song's measurable audio features explain how popular it becomes?** Beyond its practical relevance to recommendation systems, the question is a clean example of connecting properties of sound to human preference.

The project treats song popularity (a 0–100 score) as a continuous response and models it against a set of audio features, using forward stepwise selection to identify informative predictors and cross-validation to assess predictive performance.

## Key Finding

Audio features carry a **statistically significant but practically limited** signal. The fitted model outperforms a null model (test RMSE 21.73 vs. 22.17; adjusted R² 0.047 vs. 0.000; ANOVA p < 0.001), but its low R² shows that audio features alone explain only a small share of popularity variation — most of what makes a song popular lies outside these measurable attributes (e.g., artist recognition, promotion, cultural timing). Identifying that limitation clearly is itself a meaningful result.

## Results

| Metric | Null model | Fitted model |
|---|---|---|
| Adjusted R² | 0.000 | 0.047 |
| Residual standard error | 21.82 | 21.30 |
| ANOVA p-value | — | < 0.001 |
| Cross-validated error | 22.17 | 21.73 |

Final model predictors: instrumentalness, danceability, audio valence, loudness, energy, acousticness, liveness, and tempo.

## Data

The dataset contains **18,835 tracks**, each with a popularity score and a set of audio features aligned to the definitions in the Spotify Web API developer documentation:

- **Continuous predictors:** `song_duration_ms`, `acousticness`, `danceability`, `energy`, `instrumentalness`, `liveness`, `loudness`, `speechiness`, `tempo`, `audio_valence`
- **Categorical predictors:** `audio_mode` (major/minor), `key`, `time_signature`
- **Response:** `song_popularity` (0–100)

**Sampling note.** The data is a convenience sample rather than a random sample of all recorded music, so conclusions apply most directly to tracks similar to those in the dataset; broad claims about "all songs" are avoided.

**Usage note.** Spotify's developer terms place restrictions on how their content may be used. This project was conducted for academic coursework; the raw dataset is **not redistributed** in this repository. To reproduce the analysis, supply your own compatible data export (see `data/README.md`).

## Methods

- **Preprocessing.** Outliers detected and removed via the IQR method; categorical variables (`key`, `audio_mode`, `time_signature`) dummy-coded; data split 75% training / 25% testing.
- **Modeling.** Multiple linear regression with forward stepwise selection based on adjusted R².
- **Validation.** 5-fold cross-validation (mean squared error); performance evaluated with test-set RMSE.
- **Diagnostics.** Residuals-vs-fitted and Q–Q plots to check regression assumptions; the analysis notes mild heteroscedasticity and non-normal tails, and interprets results with corresponding caution.

## Key Insights

- Audio features are **statistically significant but weak** predictors of popularity — a substantive methodological finding.
- **Instrumentalness** shows a slight negative relationship with popularity: highly popular songs tend to feature vocals.
- **Musical mode** (major vs. minor) has little effect; median popularity is ~57 for both.
- Adding predictors yields quickly diminishing returns, and assumption violations counsel caution in interpretation.

## Repository Contents

```
├── analysis.R         # Data cleaning, modeling, cross-validation, diagnostics
├── poster.pdf         # Research poster summarizing the project
├── data/README.md     # Data fields and how to supply your own export
├── .gitignore
└── README.md
```

## Poster

The full project poster — introduction, methods, exploratory and predictive results, and discussion — is available in **[poster.pdf](poster.pdf)**.

## Contributors

Completed for Applied Regression (STAT 3100) at the University of Colorado Boulder by Sanjitha Chakka, Sanvitha Vallem, and Varun Cheela. All contributors participated in data preparation, modeling, analysis, and writing.

## Reference

Audio-feature definitions follow the Spotify Web API developer documentation.
