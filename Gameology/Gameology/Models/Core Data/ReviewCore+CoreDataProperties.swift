//
//  ReviewCore+CoreDataProperties.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//
//

import Foundation
import CoreData


extension ReviewCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReviewCore> {
        return NSFetchRequest<ReviewCore>(entityName: "ReviewCore")
    }

    @NSManaged public var id: Int64
    @NSManaged public var publish_date: String?
    @NSManaged public var review_description: String?
    @NSManaged public var reviewer: String?
    @NSManaged public var score: Int16
    @NSManaged public var game: GameCore?

}

extension ReviewCore : Identifiable {

}
