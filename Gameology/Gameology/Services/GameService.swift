//
//  GameService.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//

import Foundation

class GameService {
    func getGames(params: [String: Any], completionHandler: @escaping ([[String: Any]]) -> Void) -> Void  {
        var filter = ""
        for param in params {
            filter += (param.key + (param.value as! String))
        }
        let url = URL(string: "https://www.giantbomb.com/api/games/?api_key=" + Global.apiKey + "&format=json&sort=original_release_date:desc" + filter)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("error")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let gamesJson = json["results"] as? [[String: Any]] {
                        completionHandler(gamesJson)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
    
    func getGame(id: Int, completionHandler: @escaping ([String: Any]) -> Void) -> Void  {
        let url = URL(string: "https://www.giantbomb.com/api/game/" + String(id) + "/?api_key=" + Global.apiKey + "&format=json")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("error")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let gameJson = json["results"] as? [String: Any] {
                        completionHandler(gameJson)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}
