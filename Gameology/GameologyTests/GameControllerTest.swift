//
//  GameControllerTest.swift
//  GameologyTests
//
//  Created by Kyle Gardner on 10/25/20.
//

import XCTest
import Gameology

class GameControllerTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testApiKey() throws {
        let apiKey = Gameology.Global.apiKey
        XCTAssertEqual(apiKey.isEmpty, false)
    }
    
    func testGameClass() throws {
        var gameJson: [String: Any] = [:]
        gameJson["id"] = 1
        gameJson["name"] = "string"
        gameJson["deck"] = "string"
        gameJson["original_release_date"] = "string"
        gameJson["image"] = "string"
        gameJson["favorite"] = true
        gameJson["videos"] = [Video()]
        
        let _ = Game(json: gameJson)
        
    }
    
    func testVideoClass() throws {
        var videoJson: [String: Any] = [:]
        videoJson["id"] = 1
        videoJson["gameId"] = "string"
        videoJson["name"] = "string"
        videoJson["deck"] = "string"
        videoJson["hd_url"] = "string"
        videoJson["high_url"] = "string"
        videoJson["low_url"] = "string"
        videoJson["image"] = "string"
        videoJson["publish_date"] = "string"
        videoJson["user"] = "string"
        
        let _ = Video(json: videoJson)
    }
    
    func testGameCodable() throws {
        let game = Game()
        let encoded = try JSONEncoder().encode(game)
        let decoded = try JSONDecoder().decode(Game.self, from: encoded)
        
        XCTAssertEqual(game, decoded)
    }
    
    func testVideoCodable() throws {
        let video = Video()
        let encoded = try JSONEncoder().encode(video)
        let decoded = try JSONDecoder().decode(Video.self, from: encoded)
        
        XCTAssertEqual(video, decoded)
    }

}
