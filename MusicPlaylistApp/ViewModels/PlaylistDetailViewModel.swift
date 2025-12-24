import CoreData
import Combine
import Foundation

class PlaylistDetailViewModel: ObservableObject {
    @Published var playlist: Playlist?
    @Published var songs: [Song] = []
    @Published var isLoading = false
    @Published var error: SongError?
    
    private let context: NSManagedObjectContext
    private let youtubeService = YouTubeService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext, playlist: Playlist) {
        self.context = context
        self.playlist = playlist
        loadSongs()
    }
    
    func loadSongs() {
        guard let playlist = playlist else { return }
        
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", playlist.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                songs = entity.songsArray.map { Song(from: $0) }
            }
        } catch {
            self.error = .fetchFailed(error)
        }
    }
    
    func addSong(title: String, youtubeUrl: String) async {
        guard let playlist = playlist else { return }
        
        guard youtubeService.validateYouTubeURL(youtubeUrl) else {
            await MainActor.run {
                self.error = .invalidURL
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", playlist.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            guard let playlistEntity = entities.first else {
                await MainActor.run {
                    self.error = .playlistNotFound
                    isLoading = false
                }
                return
            }
            
            let songEntity = SongEntity(context: context)
            songEntity.id = UUID()
            songEntity.title = title
            songEntity.youtubeUrl = youtubeUrl
            songEntity.duration = 0
            songEntity.addedDate = Date()
            songEntity.order = Int16(playlistEntity.songsArray.count)
            songEntity.playlist = playlistEntity
            
            try context.save()
            
            await MainActor.run {
                loadSongs()
                isLoading = false
            }
            
            Task {
                await extractAudioURL(for: songEntity.id)
            }
            
        } catch {
            await MainActor.run {
                self.error = .saveFailed(error)
                isLoading = false
            }
        }
    }
    
    func removeSong(_ song: Song) {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", song.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                context.delete(entity)
                try context.save()
                loadSongs()
            }
        } catch {
            self.error = .deleteFailed(error)
        }
    }
    
    func reorderSongs(from source: IndexSet, to destination: Int) {
        var updatedSongs = songs
        updatedSongs.move(fromOffsets: source, toOffset: destination)
        
        for (index, song) in updatedSongs.enumerated() {
            let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", song.id as CVarArg)
            
            do {
                let entities = try context.fetch(request)
                if let entity = entities.first {
                    entity.order = Int16(index)
                }
            } catch {
                self.error = .updateFailed(error)
                return
            }
        }
        
        do {
            try context.save()
            loadSongs()
        } catch {
            self.error = .saveFailed(error)
        }
    }
    
    private func extractAudioURL(for songId: UUID) async {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", songId as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            guard let songEntity = entities.first else { return }
            
            do {
                let audioURL = try await youtubeService.extractAudioURL(from: songEntity.youtubeUrl)
                songEntity.audioUrl = audioURL
                try context.save()
                
                await MainActor.run {
                    loadSongs()
                }
            } catch {
                print("Failed to extract audio URL: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to fetch song entity: \(error.localizedDescription)")
        }
    }
}

enum SongError: Error, LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case updateFailed(Error)
    case invalidURL
    case playlistNotFound
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch songs: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save song: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete song: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update song: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid YouTube URL"
        case .playlistNotFound:
            return "Playlist not found"
        }
    }
}
