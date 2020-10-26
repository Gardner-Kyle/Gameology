//
//  GameCore+CoreDataProperties.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/25/20.
//
//

import Foundation
import CoreData


extension GameCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameCore> {
        return NSFetchRequest<GameCore>(entityName: "GameCore")
    }

    @NSManaged public var deck: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var original_release_date: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension GameCore {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: VideoCore)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: VideoCore)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}

extension GameCore : Identifiable {

}
