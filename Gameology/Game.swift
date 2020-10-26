//
//  Game.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/23/20.
//

import Foundation

public class Game: Codable, Equatable {
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    public var id: Int!
    public var name: String!
    public var deck: String!
    public var original_release_date: String!
    public var image: String!
    public var favorite: Bool! = false
    
    public var videos: [Video]! = []
    
    public init() {}
    
    public init(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let favorite = json["favorite"] as? Bool ?? false,
            let name = json["name"] as? String ?? "N/A",
            let deck = json["deck"] as? String ?? "This title has no summary",
            let original_release_date = json["original_release_date"] as? String ?? "N/A",
            let image = (json["image"] as? Dictionary<String, Any>)?["super_url"] as? String,
            let videoJson = (json["videos"] as? [[String: Any]]) ?? []
        else {return}
        
        self.id = id
        self.favorite = favorite
        self.name = name
        self.deck = deck as String
        self.original_release_date = original_release_date
        self.image = image
        
        for json in videoJson {
            self.videos?.append(Video(json: json))
        }
        
    }
    
    public init(id: Int, name: String, deck: String, original_release_date: String, image: String, favorite: Bool, videos: [Video]) {
        self.id = id
        self.favorite = favorite
        self.name = name
        self.deck = deck as String
        self.original_release_date = original_release_date
        self.image = image
        
        self.videos = videos
    }
}
