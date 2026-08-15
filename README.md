# Movie App

A simple iOS app built with SwiftUI that uses the TMDb API to browse movies.

Users can:

- Browse popular movies
- Search for movies
- View movie details
- Watch trailers
- Mark movies as favorites

Favorites are stored locally and restored when the app is reopened.

Supports iOS 15+.

---

## Features

- Popular movies
- Search movies by title
- Movie details (overview, runtime, genres, cast)
- Trailer playback (YouTube)
- Favorite / Unfavorite movies
- Favorites persisted using UserDefaults
- Infinite scrolling
- Loading, empty and error states

---

## Tech Stack

- Swift
- SwiftUI
- MVVM
- URLSession
- async/await
- Codable
- WKWebView
- UserDefaults

No third-party libraries were used.

---

## Setup

### Prerequisites

- Xcode 15 or later
- iOS 15+
- TMDb API Key

### Configure API Key

Clone the repository.

Copy the example configuration file:

```bash
cp Secrets.example.xcconfig Secrets.xcconfig
```

Add your TMDb API key:

```text
TMDB_API_KEY = YOUR_API_KEY
```

Open `MovieApp.xcodeproj` and run the project.

---

## Project Structure

```
MovieApp
├── Configuration
├── Managers
├── Models
├── Services
├── ViewModels
├── Views
└── MovieAppApp.swift
```

---

## Architecture

The app follows a simple MVVM architecture.

- **Views** display data.
- **ViewModels** handle presentation logic.
- **MovieService** communicates with TMDb.
- **APIClient** performs network requests.
- **FavoritesManager** manages favorite movies.

Networking is abstracted behind protocols so the view models can be tested independently.

---

## API Endpoints

```
GET /movie/popular
GET /search/movie
GET /movie/{id}
GET /movie/{id}/videos
GET /movie/{id}/credits
```

Images are loaded from:

```
https://image.tmdb.org/t/p/w500
```

---

## Design Decisions

### Runtime on Home Screen

The TMDb popular movies endpoint doesn't return the movie runtime.

Instead of making an additional request for every movie on the home screen, the app shows **N/A**. The actual runtime is displayed on the detail screen.

### Search

Search requests are debounced so the API isn't called for every keystroke. Previous requests are cancelled whenever the user continues typing.

### Pagination

Popular movies are loaded page by page as the user scrolls. Existing content stays visible if loading another page fails.

### Favorites

Favorites are stored locally using `UserDefaults` as movie IDs.

Keeping only the IDs avoids storing outdated movie information.

### Trailer

Trailers are displayed using YouTube embeds inside a `WKWebView`.

Some YouTube videos don't allow embedding or are age restricted. When that happens, the app shows a button that opens the trailer directly in YouTube.

---

## Known Limitations

- Runtime is unavailable on the home screen because the TMDb popular endpoint doesn't include it.
- Favorites are stored only on the device.
- No offline caching.
- Cast list is limited to the first 10 members.
- No dedicated Favorites screen.

---

## Tests

The project includes unit tests for:

- ViewModels
- FavoritesManager
- Trailer selection
- Codable models
- API error handling

Network requests are mocked during testing.

---

## Future Improvements

Some features that could be added later:

- Offline caching
- Dedicated Favorites screen
- Better image caching
- UI tests
- Trailer thumbnail previews
- Pull to refresh

