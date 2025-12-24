import XCTest
import CoreData
import Combine
@testable import MusicPlaylistApp

final class PlaylistsViewModelTests: XCTestCase {
    var viewModel: PlaylistsViewModel!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        viewModel = PlaylistsViewModel(context: context)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        persistenceController = nil
        context = nil
        cancellables = nil
    }
    
    func testFetchEmptyPlaylists() {
        viewModel.fetchPlaylists()
        XCTAssertEqual(viewModel.playlists.count, 0)
    }
    
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
        
        viewModel.createPlaylist(name: "Test Playlist")
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.playlists.count, 1)
        XCTAssertEqual(viewModel.playlists.first?.name, "Test Playlist")
    }
    
    func testCreatePlaylistWithEmptyName() {
        viewModel.createPlaylist(name: "")
        XCTAssertNotNil(viewModel.error)
    }
    
    func testDeletePlaylist() {
        viewModel.createPlaylist(name: "Test Playlist")
        XCTAssertEqual(viewModel.playlists.count, 1)
        
        let playlist = viewModel.playlists.first!
        viewModel.deletePlaylist(playlist)
        
        XCTAssertEqual(viewModel.playlists.count, 0)
    }
    
    func testUpdatePlaylistName() {
        viewModel.createPlaylist(name: "Old Name")
        let playlist = viewModel.playlists.first!
        
        viewModel.updatePlaylistName(playlist, newName: "New Name")
        
        XCTAssertEqual(viewModel.playlists.first?.name, "New Name")
    }
}

final class AudioPlayerViewModelTests: XCTestCase {
    var viewModel: AudioPlayerViewModel!
    
    override func setUpWithError() throws {
        viewModel = AudioPlayerViewModel.shared
    }
    
    override func tearDownWithError() throws {
        viewModel.stop()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.currentSong)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertEqual(viewModel.duration, 0)
        XCTAssertEqual(viewModel.volume, 1.0)
        XCTAssertEqual(viewModel.playbackRate, 1.0)
    }
    
    func testLoadPlaylist() {
        let songs = [
            Song(title: "Song 1", youtubeUrl: "https://youtube.com/watch?v=1", duration: 180),
            Song(title: "Song 2", youtubeUrl: "https://youtube.com/watch?v=2", duration: 200),
            Song(title: "Song 3", youtubeUrl: "https://youtube.com/watch?v=3", duration: 220)
        ]
        
        viewModel.loadPlaylist(songs, startIndex: 1)
        
        XCTAssertEqual(viewModel.playlist.count, 3)
        XCTAssertEqual(viewModel.currentIndex, 1)
    }
    
    func testSetVolume() {
        viewModel.setVolume(0.5)
        XCTAssertEqual(viewModel.volume, 0.5, accuracy: 0.01)
        
        viewModel.setVolume(1.5)
        XCTAssertEqual(viewModel.volume, 1.0, accuracy: 0.01)
        
        viewModel.setVolume(-0.5)
        XCTAssertEqual(viewModel.volume, 0.0, accuracy: 0.01)
    }
    
    func testSetPlaybackRate() {
        viewModel.setPlaybackRate(1.5)
        XCTAssertEqual(viewModel.playbackRate, 1.5, accuracy: 0.01)
        
        viewModel.setPlaybackRate(3.0)
        XCTAssertEqual(viewModel.playbackRate, 2.0, accuracy: 0.01)
        
        viewModel.setPlaybackRate(0.25)
        XCTAssertEqual(viewModel.playbackRate, 0.5, accuracy: 0.01)
    }
}
