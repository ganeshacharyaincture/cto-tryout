import Foundation
import CoreData

extension SongEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SongEntity> {
        return NSFetchRequest<SongEntity>(entityName: "SongEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var youtubeUrl: String
    @NSManaged public var audioUrl: String?
    @NSManaged public var duration: Double
    @NSManaged public var addedDate: Date
    @NSManaged public var order: Int16
    @NSManaged public var playlist: PlaylistEntity?
}

extension SongEntity: Identifiable {
    
}
