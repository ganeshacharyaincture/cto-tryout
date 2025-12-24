import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MusicPlaylistApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    func saveInBackground(completion: @escaping (Result<Void, Error>) -> Void) {
        let context = container.newBackgroundContext()
        context.perform {
            do {
                if context.hasChanges {
                    try context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        for i in 0..<3 {
            let playlist = PlaylistEntity(context: context)
            playlist.id = UUID()
            playlist.name = "Playlist \(i + 1)"
            playlist.createdDate = Date()
            playlist.modifiedDate = Date()
            playlist.order = Int16(i)
            
            for j in 0..<5 {
                let song = SongEntity(context: context)
                song.id = UUID()
                song.title = "Song \(j + 1) in Playlist \(i + 1)"
                song.youtubeUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
                song.audioUrl = ""
                song.duration = Double.random(in: 180...300)
                song.addedDate = Date()
                song.order = Int16(j)
                song.playlist = playlist
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
