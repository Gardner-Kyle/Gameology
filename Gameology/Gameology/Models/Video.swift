//
//  Video.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/23/20.
//

import Foundation

public class Video: Codable, Equatable {
    public static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    public var id: Int!
    public var name: String!
    public var deck: String!
    public var hd_url: String!
    public var high_url: String!
    public var low_url: String!
    public var image: String!
    public var publish_date: String!
    public var user: String!
    public var gameId: Int!
    
    public init() {}
        
    public init(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let gameId = json["gameId"] as? Int ?? -1,
            let name = json["name"] as? String ?? "N/A",
            let deck = json["deck"] as? String ?? "N/A",
            let hd_url = json["hd_url"] as? String ?? "N/A",
            let high_url = json["high_url"] as? String ?? "N/A",
            let low_url = json["low_url"] as? String ?? "N/A",
            let image = (json["image"] as? Dictionary<String, Any>)?["super_url"] as? String ?? "N/A",
            let publish_date = json["publish_date"] as? String ?? "N/A",
            let user = json["user"] as? String ?? "N/A"
        else {return}
        
        self.id = id
        self.gameId = gameId
        self.name = name
        self.deck = deck
        self.hd_url = hd_url
        self.high_url = high_url
        self.low_url = low_url
        self.image = image
        self.publish_date = publish_date
        self.user = user
        
    }
}
