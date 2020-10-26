//
//  VideoCore+CoreDataProperties.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/25/20.
//
//

import Foundation
import CoreData


extension VideoCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoCore> {
        return NSFetchRequest<VideoCore>(entityName: "VideoCore")
    }

    @NSManaged public var deck: String?
    @NSManaged public var hd_url: String?
    @NSManaged public var high_url: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var low_url: String?
    @NSManaged public var name: String?
    @NSManaged public var publish_date: String?
    @NSManaged public var user: String?
    @NSManaged public var gameId: Int64

}

extension VideoCore : Identifiable {

}
