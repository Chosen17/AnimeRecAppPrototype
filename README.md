# Anime Recommendation App (iOS)

A "Tinder-style" anime recommendation app for iPhone, built with SwiftUI.
It tackles **choice overload**: instead of scrolling endless lists, you answer a short questionnaire and then swipe through personalised anime cards — swipe right to save, swipe left to skip.

Anime data comes from the [Jikan API](https://jikan.moe/) (an unofficial MyAnimeList API). User accounts, preferences and watchlists are stored on a companion Rails backend.

## Features

- **Accounts** — sign up and log in; the auth token is kept on the device so you stay logged in.
- **Onboarding questionnaire** — three steps:
  1. Favourite genres (Action, Adventure, Comedy, Drama, Fantasy, Horror, Romance, Supernatural, Mystery, Slice of Life)
  2. Experience level (brand new / some / experienced)
  3. Preferred episode length (short / medium / long / any)
- **Discover (swipe)** — a card stack built from your top genres:
  - Swipe right or tap ♥ to save, swipe left or tap ✕ to skip
  - Synopsis opens as a bottom sheet over the card
  - Results are de-duplicated, already-saved anime are hidden, and the stack refills itself when it gets low
  - Falls back to Jikan's top anime if no genres were picked
- **Home** — trending/top anime plus a debounced search bar
- **Anime detail** — large cover, English and Japanese titles, score, episodes, status, year, rating, synopsis, genres and a save button
- **Saved (watchlist)** — everything you've saved; swipe to delete; synced to the backend
- **Settings** — safe content filter (on by default; only shows G, PG and PG-13 titles), reset preferences, sign out
- Dark mode with a purple accent throughout

## Tech stack

| Area | Choice |
| --- | --- |
| Language / UI | Swift 5, SwiftUI |
| Architecture | MVVM (Views → ViewModels → Services / Storage) |
| Concurrency | `async`/`await`, `TaskGroup` for parallel genre requests |
| Anime data | Jikan REST API v4 (no API key required) |
| Backend | Rails API (separate project), token auth |
| Local storage | `UserDefaults` / `@AppStorage` |
| Minimum iOS | 17.6 |

## Project structure

```
AnimeRecommendationTinder-Mobile project/
├── AnimeRecommendationTinder_Mobile_projectApp.swift   # App entry point (dark mode + accent tint)
├── ContentView.swift          # Root: Login → Questionnaire → TabView
├── Models/
│   └── AnimeItem.swift        # Codable models matching Jikan's JSON
├── Services/
│   ├── JikanService.swift     # Top anime, search, by-genre, detail
│   └── APIService.swift       # Rails backend: auth, preferences, saved anime
├── Storage/
│   ├── SavedAnimeStorage.swift       # Local watchlist, synced to the backend
│   └── UserPreferencesStorage.swift  # Questionnaire answers
├── ViewModels/                # One ViewModel per screen
└── Views/                     # Home, Discover, SwipeCard, Detail, Saved, Settings, Login, SignUp, Questionnaire
AnimeRecommendationTinder-Mobile projectTests/     # Unit tests
AnimeRecommendationTinder-Mobile projectUITests/   # UI tests
```

## How recommendations work

1. Load the genre IDs saved from the questionnaire.
2. Fetch the highest-scored anime for up to three of those genres from Jikan, in parallel.
3. Merge the results and remove duplicates (an anime can belong to several genres).
4. If the safe content filter is on, keep only G, PG and PG-13 titles.
5. Remove anime already in the watchlist.
6. Shuffle and show them as the swipe stack.

## Getting started

### Requirements

- macOS with Xcode (with an iOS 17.6+ simulator or device)
- The companion Rails backend running locally on port 3000

### Run the app

1. Clone the repo:
   ```bash
   git clone https://github.com/Chosen17/AnimeRecAppPrototype.git
   ```
2. Open `AnimeRecommendationTinder-Mobile project.xcodeproj` in Xcode.
3. Start the Rails backend so it's reachable at `http://127.0.0.1:3000`.
4. Pick an iPhone simulator and press **Run** (⌘R).

> The backend URL is set in `Services/APIService.swift` (`baseURL`). `127.0.0.1` only works on the simulator — to run on a physical device, change it to your Mac's local IP address.

### Backend endpoints used

All under `/api`:

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/signup` | Create an account (email, password, username) |
| POST | `/login` | Log in, returns a token |
| GET / PUT | `/preferences` | Load / save questionnaire answers |
| GET / POST | `/saved_animes` | Load / add watchlist items |
| DELETE | `/saved_animes/:mal_id` | Remove a watchlist item |

Authenticated requests send `Authorization: Bearer <token>`.

## Known limitations / future work

- The Saved screen shows the local watchlist; the server copy is fetched but not yet merged back in (that needs extra Jikan calls to rebuild the full anime data).
- The experience level and episode length answers are stored but not yet used to filter recommendations.
- Jikan's free tier is rate-limited (about 3 requests per second), so fast searching or swiping can sometimes fail to load.

## Credits

- Anime data and images: [Jikan](https://jikan.moe/) / [MyAnimeList](https://myanimelist.net/)
- Built by Earle Rose
