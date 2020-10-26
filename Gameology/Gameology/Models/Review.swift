//
//  Review.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/23/20.
//

import Foundation

struct Review: Codable {
    var id: Int!
    var description: String!
    var publish_date: String!
    var reviewer: String!
    var score: Int!
    
    var game: Game!
    
        
    init(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let description = json["description"] as? String,
            let publish_date = json["publish_date"] as? String,
            let reviewer = json["reviewer"] as? String,
            let score = json["score"] as? Int,
            
            let gameJson = json["game"] as? [String: Any]
        else {return}
                
        self.id = id
        self.description = description
        self.publish_date = publish_date
        self.reviewer = reviewer
        self.score = score
        
        self.game = Game(json: gameJson)
        
    }
}
