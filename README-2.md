# Data

The dataset contains **18,835 tracks**, each an individual song with a popularity score and a set of audio features aligned to the Spotify Web API developer documentation.

**Note:** The raw dataset is not redistributed in this repository. Spotify's developer terms restrict how their content may be used, and this project was conducted for academic coursework only.

## Fields used

**Response**
- `song_popularity` — popularity score (0–100)

**Continuous predictors**
- `danceability`, `energy`, `loudness`, `tempo`, `audio_valence`
- `acousticness`, `speechiness`, `instrumentalness`, `liveness`, `song_duration_ms`

**Categorical predictors**
- `key` — musical key (integer-encoded pitch class)
- `audio_mode` — major (1) or minor (0)
- `time_signature` — discrete categories

## Reproducing the analysis

Supply your own compatible data export saved as `data/spotify_songs.csv` (or update the path and column names at the top of `analysis.R` to match your file), then run the script.
