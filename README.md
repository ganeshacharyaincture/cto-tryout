# MusicPlaylistApp

A modern SwiftUI iOS music playlist app with complete foundation for YouTube audio extraction and background playback.

## Features

- ✅ SwiftUI-based iOS app with MVVM architecture
- ✅ Core Data persistence for playlists and songs
- ✅ Background audio playback support
- ✅ AVPlayer-based audio engine with full controls
- ✅ Remote command center integration (lock screen controls)
- ✅ YouTube URL validation and extraction foundation
- ✅ Playlist management (create, delete, rename, reorder)
- ✅ Song management (add, remove, reorder within playlists)
- ✅ Now Playing view with full playback controls
- ✅ Mini player for quick access
- ✅ Variable playback speed (0.5x to 2.0x)
- ✅ Volume control
- ✅ Skip forward/backward (15 seconds)
- ✅ Next/Previous track navigation

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- iPhone only (Portrait orientation)

## Architecture

### MVVM Pattern

The app follows the Model-View-ViewModel pattern with strict separation of concerns:

- **Models**: Core Data entities and Swift structs for data representation
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management using Combine

### Project Structure

```
MusicPlaylistApp/
├── MusicPlaylistApp.swift          # App entry point
├── Info.plist                      # App configuration
├── Models/                         # Data models
│   ├── Playlist.swift
│   ├── Song.swift
│   ├── PlaylistEntity+CoreDataClass.swift
│   ├── PlaylistEntity+CoreDataProperties.swift
│   ├── SongEntity+CoreDataClass.swift
│   └── SongEntity+CoreDataProperties.swift
├── ViewModels/                     # Business logic
│   ├── PlaylistsViewModel.swift
│   ├── PlaylistDetailViewModel.swift
│   └── AudioPlayerViewModel.swift
├── Views/                          # UI components
│   ├── ContentView.swift
│   ├── PlaylistsListView.swift
│   ├── PlaylistDetailView.swift
│   ├── NowPlayingView.swift
│   └── MiniPlayerView.swift
├── Services/                       # Core services
│   ├── AudioPlayer.swift
│   ├── AudioSessionManager.swift
│   ├── RemoteCommandManager.swift
│   └── YouTubeService.swift
├── CoreData/                       # Core Data stack
│   ├── PersistenceController.swift
│   └── MusicPlaylistApp.xcdatamodeld/
└── Utilities/                      # Helper utilities
    └── TimeFormatter.swift

MusicPlaylistAppTests/              # Unit tests
├── CoreDataTests.swift
├── YouTubeServiceTests.swift
└── ViewModelTests.swift
```

## Core Components

### 1. Audio Engine (AVFoundation)

The `AudioPlayer` class provides a comprehensive audio playback engine:

- **Playback Controls**: Play, pause, stop, seek
- **Volume Control**: 0.0 to 1.0
- **Playback Rate**: 0.5x to 2.0x speed
- **Time Tracking**: Current time and duration monitoring
- **Error Handling**: Comprehensive error handling for audio failures

### 2. Background Audio Support

Configured for background playback with:

- Audio session category: `.playback`
- Background modes: `audio`
- Interruption handling (phone calls, Siri)
- Route change handling (headphones disconnect)

### 3. Remote Command Center

Supports lock screen and CarPlay controls:

- Play/Pause/Toggle
- Skip forward/backward (15 seconds)
- Next/Previous track
- Seek to position
- Now Playing info display

### 4. Core Data Models

#### PlaylistEntity
- `id`: UUID (primary key)
- `name`: String
- `createdDate`: Date
- `modifiedDate`: Date
- `order`: Int16 (for sorting)
- `songs`: Relationship to SongEntity (cascade delete)

#### SongEntity
- `id`: UUID (primary key)
- `title`: String
- `youtubeUrl`: String
- `audioUrl`: String? (extracted audio URL)
- `duration`: TimeInterval
- `addedDate`: Date
- `order`: Int16 (playlist ordering)
- `playlist`: Relationship to PlaylistEntity

### 5. YouTube Service

Foundation for YouTube audio extraction:

- URL validation (youtube.com and youtu.be)
- Video ID extraction
- Placeholder for audio URL extraction
- URL caching for performance

**Note**: Audio extraction is a placeholder. You'll need to implement or integrate a third-party library for actual YouTube audio extraction.

### 6. ViewModels

#### PlaylistsViewModel
- Fetch all playlists
- Create new playlist
- Delete playlist
- Update playlist name
- Reorder playlists

#### PlaylistDetailViewModel
- Load songs in playlist
- Add song to playlist
- Remove song
- Reorder songs

#### AudioPlayerViewModel
- Singleton instance for app-wide audio control
- Manage playback state
- Track current song and playlist
- Handle playback progress
- Remote command integration

## Usage

### Creating a Playlist

```swift
let viewModel = PlaylistsViewModel(context: viewContext)
viewModel.createPlaylist(name: "My Playlist")
```

### Adding a Song

```swift
let viewModel = PlaylistDetailViewModel(context: viewContext, playlist: playlist)
await viewModel.addSong(title: "Song Title", youtubeUrl: "https://www.youtube.com/watch?v=...")
```

### Playing Audio

```swift
let audioPlayerViewModel = AudioPlayerViewModel.shared
audioPlayerViewModel.loadPlaylist(songs, startIndex: 0)
audioPlayerViewModel.play()
```

## Background Playback

The app is configured for background audio playback:

1. **Info.plist**: Contains `UIBackgroundModes` with `audio`
2. **Audio Session**: Configured with `.playback` category
3. **Remote Commands**: Integrated for lock screen controls
4. **Now Playing Info**: Updates automatically with current song

To test background playback:
1. Build and run the app
2. Play a song
3. Press the home button or lock the device
4. Audio continues playing
5. Use lock screen controls to control playback

## Testing

The project includes comprehensive unit tests:

### CoreDataTests
- Test playlist and song creation
- Test cascade delete behavior
- Test relationships between entities

### YouTubeServiceTests
- Test URL validation
- Test video ID extraction
- Test various YouTube URL formats

### ViewModelTests
- Test playlist CRUD operations
- Test audio player state management
- Test volume and playback rate controls

Run tests:
```bash
xcodebuild test -scheme MusicPlaylistApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Known Limitations

1. **YouTube Audio Extraction**: The `YouTubeService.extractAudioURL()` method is a placeholder. You need to implement actual audio extraction using:
   - Third-party libraries (youtube-dl, yt-dlp)
   - Backend API service
   - YouTube API with proper authentication

2. **No Authentication**: The app doesn't include user authentication or cloud sync

3. **No Album Art**: Songs don't display artwork (can be added via YouTube thumbnails)

4. **iPhone Only**: iPad support is not included (can be added)

## Future Enhancements

- [ ] Implement actual YouTube audio extraction
- [ ] Add album artwork support
- [ ] Implement queue management
- [ ] Add shuffle and repeat modes
- [ ] Support for other video platforms (Vimeo, Soundcloud)
- [ ] Cloud sync with iCloud
- [ ] Export/import playlists
- [ ] Sleep timer
- [ ] Equalizer
- [ ] Lyrics support

## License

This is a demonstration project. Use at your own discretion.

## Contributing

This is a foundation project. Feel free to extend it with:
- Additional audio sources
- Enhanced UI/UX
- Advanced playback features
- Cloud integration

## Support

For issues or questions, please open an issue in the repository.
