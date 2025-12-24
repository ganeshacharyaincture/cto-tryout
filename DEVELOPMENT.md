# Development Guide

## Setup

### Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- iOS 15.0+ device or simulator

### Installation

1. Clone the repository
2. Open `MusicPlaylistApp.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘R)

## Architecture Overview

### MVVM with Combine

The app follows a strict MVVM architecture:

```
View ←→ ViewModel ←→ Model
  ↓         ↓          ↓
SwiftUI  Combine   CoreData/Services
```

### Key Principles

1. **Separation of Concerns**: Views only handle UI, ViewModels handle business logic
2. **Reactive Programming**: Use Combine publishers for state changes
3. **Dependency Injection**: Pass dependencies through initializers or environment
4. **Single Responsibility**: Each class has one clear purpose

## Core Components

### Audio Player

The audio player is built on AVFoundation:

```swift
// Initialize
let player = AudioPlayer()

// Load audio
try await player.loadAudio(url: audioURL)

// Control playback
player.play()
player.pause()
player.seek(to: 30.0)
```

#### Audio Session Configuration

The audio session is configured in `AudioSessionManager`:

- **Category**: `.playback` - for background audio
- **Mode**: `.default`
- **Options**: `.mixWithOthers` - allow other apps to play audio

#### Handling Interruptions

The app handles audio interruptions automatically:

1. **Phone calls**: Pause playback
2. **Siri**: Pause playback
3. **Headphones disconnect**: Pause playback
4. **Resume**: Continue if appropriate

### Remote Command Center

Lock screen and CarPlay controls are managed by `RemoteCommandManager`:

```swift
// Setup (done automatically in app initialization)
RemoteCommandManager.shared.setup(with: audioPlayerViewModel)

// Update now playing info
RemoteCommandManager.shared.updateNowPlayingInfo(
    song: currentSong,
    currentTime: 30.0,
    duration: 180.0,
    isPlaying: true
)
```

### Core Data

#### Entity Relationships

```
PlaylistEntity (1) ←→ (Many) SongEntity
```

- Deletion rule: Cascade (deleting playlist deletes songs)
- Inverse relationship maintained automatically

#### CRUD Operations

**Create Playlist:**
```swift
let playlist = PlaylistEntity(context: context)
playlist.id = UUID()
playlist.name = "My Playlist"
playlist.createdDate = Date()
playlist.modifiedDate = Date()
playlist.order = 0
try context.save()
```

**Add Song:**
```swift
let song = SongEntity(context: context)
song.id = UUID()
song.title = "Song Title"
song.youtubeUrl = "https://youtube.com/..."
song.playlist = playlistEntity
try context.save()
```

**Fetch Playlists:**
```swift
let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
let playlists = try context.fetch(request)
```

### ViewModels

#### State Management

ViewModels use `@Published` properties for reactive updates:

```swift
class PlaylistsViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var isLoading = false
    @Published var error: PlaylistError?
}
```

#### Async Operations

Use async/await for asynchronous operations:

```swift
func addSong(title: String, youtubeUrl: String) async {
    await MainActor.run {
        isLoading = true
    }
    
    // Perform async work
    
    await MainActor.run {
        isLoading = false
    }
}
```

### YouTube Integration

#### URL Validation

The `YouTubeService` validates YouTube URLs:

```swift
let isValid = YouTubeService.shared.validateYouTubeURL(urlString)
```

Supported formats:
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtube.com/watch?v=VIDEO_ID`
- `https://m.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`

#### Audio Extraction (To Be Implemented)

The audio extraction is a placeholder. To implement:

1. **Option 1: Backend Service**
   - Create a server endpoint that extracts audio
   - Use URLSession to fetch from your API
   - Cache URLs locally

2. **Option 2: Third-party Library**
   - Use youtube-dl or yt-dlp (requires backend)
   - Use YouTube API (requires API key)

3. **Option 3: Streaming Service**
   - Integrate with a music streaming API
   - Use OAuth for authentication

Example implementation:

```swift
private func performAudioExtraction(videoID: String) async throws -> String {
    // Call your backend API
    let url = URL(string: "https://your-api.com/extract/\(videoID)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(AudioResponse.self, from: data)
    return response.audioURL
}
```

## UI Development

### SwiftUI Best Practices

1. **Extract Subviews**: Keep views small and focused
2. **Use PreviewProvider**: Test UI in canvas
3. **Environment Objects**: Share state across views
4. **State Management**: Use appropriate property wrappers

### View Hierarchy

```
ContentView (Root)
├── PlaylistsListView
│   └── NavigationLink → PlaylistDetailView
│       └── NavigationLink → NowPlayingView
└── MiniPlayerView (Overlay)
```

### Custom Modifiers

Create reusable view modifiers:

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}
```

## Testing

### Unit Tests

Run all tests:
```bash
xcodebuild test -scheme MusicPlaylistApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

#### Core Data Tests

Test Core Data operations in isolation:

```swift
override func setUpWithError() throws {
    persistenceController = PersistenceController(inMemory: true)
    context = persistenceController.container.viewContext
}
```

#### ViewModel Tests

Test business logic with Combine:

```swift
func testCreatePlaylist() {
    let expectation = XCTestExpectation(description: "Playlist created")
    
    viewModel.$playlists
        .dropFirst()
        .sink { playlists in
            if playlists.count == 1 {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
    
    viewModel.createPlaylist(name: "Test")
    wait(for: [expectation], timeout: 1.0)
}
```

### UI Tests

Create UI tests in Xcode:

```swift
func testCreatePlaylistFlow() {
    let app = XCUIApplication()
    app.launch()
    
    app.buttons["plus"].tap()
    app.textFields["Playlist Name"].tap()
    app.textFields["Playlist Name"].typeText("My Playlist")
    app.buttons["Create"].tap()
    
    XCTAssertTrue(app.staticTexts["My Playlist"].exists)
}
```

## Debugging

### Audio Issues

Enable audio session debugging:

```swift
// In AudioSessionManager
do {
    try audioSession.setActive(true)
    print("✅ Audio session activated")
} catch {
    print("❌ Audio session failed: \(error)")
}
```

### Core Data Issues

Enable Core Data debug output:

```bash
# Add to scheme arguments
-com.apple.CoreData.SQLDebug 1
```

### Memory Leaks

Use Instruments to detect memory leaks:
1. Product → Profile (⌘I)
2. Select "Leaks" template
3. Record and test your app

## Performance Optimization

### Core Data

1. **Batch Updates**: Use batch operations for large datasets
2. **Faulting**: Don't load relationships unnecessarily
3. **Background Context**: Use background contexts for heavy operations

```swift
persistenceController.saveInBackground { result in
    switch result {
    case .success:
        print("Saved successfully")
    case .failure(let error):
        print("Save failed: \(error)")
    }
}
```

### UI

1. **LazyVStack**: Use for long lists
2. **Identity**: Provide stable IDs for ForEach
3. **Minimize Redrawing**: Use equatable structs

### Audio

1. **Preloading**: Preload next track in playlist
2. **Caching**: Cache extracted audio URLs
3. **Buffer Size**: Optimize buffer for network conditions

## Deployment

### App Store Submission

1. **Info.plist**: Ensure all required keys are present
2. **Privacy**: Add privacy descriptions if needed
3. **Icons**: Add app icons in Assets catalog
4. **Screenshots**: Prepare for all required sizes

### TestFlight

1. Archive the app (Product → Archive)
2. Upload to App Store Connect
3. Add internal/external testers
4. Collect feedback

## Common Issues

### Background Audio Not Working

1. Check Info.plist has `UIBackgroundModes` with `audio`
2. Verify audio session category is `.playback`
3. Ensure audio session is activated before playback

### Core Data Migration

When changing the data model:

1. Create new model version
2. Set as current version
3. Core Data handles lightweight migration automatically

### Remote Commands Not Responding

1. Verify RemoteCommandManager is set up
2. Check now playing info is updated
3. Test on physical device (simulator has limitations)

## Resources

### Apple Documentation

- [AVFoundation Programming Guide](https://developer.apple.com/av-foundation/)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Third-party Libraries

Consider these for extended functionality:
- [YouTubeDL](https://github.com/ytdl-org/youtube-dl)
- [Kingfisher](https://github.com/onevcat/Kingfisher) - Image loading
- [SwiftLint](https://github.com/realm/SwiftLint) - Code style

## Contributing

1. Create a feature branch
2. Make changes following style guide
3. Add tests for new functionality
4. Submit pull request

### Code Style

- Use 4 spaces for indentation
- Follow Swift API Design Guidelines
- Add documentation for public APIs
- Keep functions under 50 lines when possible

## Support

For questions or issues:
- Open an issue on GitHub
- Check existing documentation
- Review Apple's sample code
