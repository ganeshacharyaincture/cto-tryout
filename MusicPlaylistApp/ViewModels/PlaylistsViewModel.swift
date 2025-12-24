import CoreData
import Combine
import Foundation

class PlaylistsViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var isLoading = false
    @Published var error: PlaylistError?
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchPlaylists()
    }
    
    func fetchPlaylists() {
        isLoading = true
        
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            playlists = entities.map { Playlist(from: $0) }
            isLoading = false
        } catch {
            self.error = .fetchFailed(error)
            isLoading = false
        }
    }
    
    func createPlaylist(name: String) {
        guard !name.isEmpty else {
            error = .invalidName
            return
        }
        
        let entity = PlaylistEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.createdDate = Date()
        entity.modifiedDate = Date()
        entity.order = Int16(playlists.count)
        
        do {
            try context.save()
            fetchPlaylists()
        } catch {
            self.error = .saveFailed(error)
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", playlist.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                context.delete(entity)
                try context.save()
                fetchPlaylists()
            }
        } catch {
            self.error = .deleteFailed(error)
        }
    }
    
    func updatePlaylistName(_ playlist: Playlist, newName: String) {
        guard !newName.isEmpty else {
            error = .invalidName
            return
        }
        
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", playlist.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.name = newName
                entity.modifiedDate = Date()
                try context.save()
                fetchPlaylists()
            }
        } catch {
            self.error = .updateFailed(error)
        }
    }
    
    func reorderPlaylists(from source: IndexSet, to destination: Int) {
        var updatedPlaylists = playlists
        updatedPlaylists.move(fromOffsets: source, toOffset: destination)
        
        for (index, playlist) in updatedPlaylists.enumerated() {
            let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", playlist.id as CVarArg)
            
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
            fetchPlaylists()
        } catch {
            self.error = .saveFailed(error)
        }
    }
}

enum PlaylistError: Error, LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case updateFailed(Error)
    case invalidName
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch playlists: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save playlist: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete playlist: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update playlist: \(error.localizedDescription)"
        case .invalidName:
            return "Playlist name cannot be empty"
        }
    }
}
