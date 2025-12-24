import Foundation
import CoreData

struct Song: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var youtubeUrl: String
    var audioUrl: String?
    var duration: TimeInterval
    var addedDate: Date
    var order: Int16
    
    init(id: UUID = UUID(), 
         title: String, 
         youtubeUrl: String, 
         audioUrl: String? = nil, 
         duration: TimeInterval = 0, 
         addedDate: Date = Date(), 
         order: Int16 = 0) {
        self.id = id
        self.title = title
        self.youtubeUrl = youtubeUrl
        self.audioUrl = audioUrl
        self.duration = duration
        self.addedDate = addedDate
        self.order = order
    }
    
    init(from entity: SongEntity) {
        self.id = entity.id
        self.title = entity.title
        self.youtubeUrl = entity.youtubeUrl
        self.audioUrl = entity.audioUrl
        self.duration = entity.duration
        self.addedDate = entity.addedDate
        self.order = entity.order
    }
    
    func toEntity(context: NSManagedObjectContext) -> SongEntity {
        let entity = SongEntity(context: context)
        entity.id = id
        entity.title = title
        entity.youtubeUrl = youtubeUrl
        entity.audioUrl = audioUrl
        entity.duration = duration
        entity.addedDate = addedDate
        entity.order = order
        return entity
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}
