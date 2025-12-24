import XCTest
import CoreData
@testable import MusicPlaylistApp

final class CoreDataTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
    }
    
    func testCreatePlaylist() throws {
        let playlist = PlaylistEntity(context: context)
        playlist.id = UUID()
        playlist.name = "Test Playlist"
        playlist.createdDate = Date()
        playlist.modifiedDate = Date()
        playlist.order = 0
        
        try context.save()
        
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        let playlists = try context.fetch(request)
        
        XCTAssertEqual(playlists.count, 1)
        XCTAssertEqual(playlists.first?.name, "Test Playlist")
    }
    
    func testCreateSong() throws {
        let playlist = PlaylistEntity(context: context)
        playlist.id = UUID()
        playlist.name = "Test Playlist"
        playlist.createdDate = Date()
        playlist.modifiedDate = Date()
        playlist.order = 0
        
        let song = SongEntity(context: context)
        song.id = UUID()
        song.title = "Test Song"
        song.youtubeUrl = "https://www.youtube.com/watch?v=test"
        song.duration = 180
        song.addedDate = Date()
        song.order = 0
        song.playlist = playlist
        
        try context.save()
        
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        let songs = try context.fetch(request)
        
        XCTAssertEqual(songs.count, 1)
        XCTAssertEqual(songs.first?.title, "Test Song")
        XCTAssertEqual(songs.first?.playlist?.name, "Test Playlist")
    }
    
    func testDeletePlaylistCascadesSongs() throws {
        let playlist = PlaylistEntity(context: context)
        playlist.id = UUID()
        playlist.name = "Test Playlist"
        playlist.createdDate = Date()
        playlist.modifiedDate = Date()
        playlist.order = 0
        
        let song = SongEntity(context: context)
        song.id = UUID()
        song.title = "Test Song"
        song.youtubeUrl = "https://www.youtube.com/watch?v=test"
        song.duration = 180
        song.addedDate = Date()
        song.order = 0
        song.playlist = playlist
        
        try context.save()
        
        context.delete(playlist)
        try context.save()
        
        let songRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        let songs = try context.fetch(songRequest)
        
        XCTAssertEqual(songs.count, 0)
    }
    
    func testPlaylistSongsArray() throws {
        let playlist = PlaylistEntity(context: context)
        playlist.id = UUID()
        playlist.name = "Test Playlist"
        playlist.createdDate = Date()
        playlist.modifiedDate = Date()
        playlist.order = 0
        
        for i in 0..<5 {
            let song = SongEntity(context: context)
            song.id = UUID()
            song.title = "Song \(i)"
            song.youtubeUrl = "https://www.youtube.com/watch?v=test\(i)"
            song.duration = 180
            song.addedDate = Date()
            song.order = Int16(i)
            song.playlist = playlist
        }
        
        try context.save()
        
        XCTAssertEqual(playlist.songsArray.count, 5)
        XCTAssertEqual(playlist.songsArray[0].title, "Song 0")
        XCTAssertEqual(playlist.songsArray[4].title, "Song 4")
    }
}
