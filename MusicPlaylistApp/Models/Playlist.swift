import Foundation
import CoreData

struct Playlist: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdDate: Date
    var modifiedDate: Date
    var order: Int16
    var songs: [Song]
    
    init(id: UUID = UUID(), 
         name: String, 
         createdDate: Date = Date(), 
         modifiedDate: Date = Date(), 
         order: Int16 = 0, 
         songs: [Song] = []) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.order = order
        self.songs = songs
    }
    
    init(from entity: PlaylistEntity) {
        self.id = entity.id
        self.name = entity.name
        self.createdDate = entity.createdDate
        self.modifiedDate = entity.modifiedDate
        self.order = entity.order
        self.songs = entity.songsArray.map { Song(from: $0) }
    }
    
    func toEntity(context: NSManagedObjectContext) -> PlaylistEntity {
        let entity = PlaylistEntity(context: context)
        entity.id = id
        entity.name = name
        entity.createdDate = createdDate
        entity.modifiedDate = modifiedDate
        entity.order = order
        return entity
    }
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}
