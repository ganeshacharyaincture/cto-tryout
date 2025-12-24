import Foundation
import CoreData

extension PlaylistEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistEntity> {
        return NSFetchRequest<PlaylistEntity>(entityName: "PlaylistEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdDate: Date
    @NSManaged public var modifiedDate: Date
    @NSManaged public var order: Int16
    @NSManaged public var songs: NSSet?
    
    public var songsArray: [SongEntity] {
        let set = songs as? Set<SongEntity> ?? []
        return set.sorted { $0.order < $1.order }
    }
}

extension PlaylistEntity: Identifiable {
    
}

extension PlaylistEntity {
    
    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: SongEntity)
    
    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: SongEntity)
    
    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)
    
    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)
}
