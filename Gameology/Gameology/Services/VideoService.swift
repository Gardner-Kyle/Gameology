//
//  VideoService.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//

import Foundation

class VideoService {
    func getVideos(params: [String: Any], completionHandler: @escaping ([[String: Any]]) -> Void) -> Void  {
        var filter = params.isEmpty ? "" : "&filter="
        for param in params {
            filter += (param.key + ":" + (param.value as! String))
        }
        let url = URL(string: "https://www.giantbomb.com/api/videos/?api_key=" + Global.apiKey + "&format=json" + filter)!
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
                    if let videosJson = json["results"] as? [[String: Any]] {
                        completionHandler(videosJson)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
    
    func getVideo(id: Int, completionHandler: @escaping ([String: Any]) -> Void) -> Void  {
        let url = URL(string: "https://www.giantbomb.com/api/video/" + String(id) + "/?api_key=" + Global.apiKey + "&format=json")!
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
                    if let videoJson = json["results"] as? [String: Any] {
                        completionHandler(videoJson)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
    
}
