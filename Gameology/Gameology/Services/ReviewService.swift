//
//  ReviewService.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//

import Foundation

class ReviewService {
    func getReviews(params: [String: Any], completionHandler: @escaping ([[String: Any]]) -> Void) -> Void  {
        var filter = params.isEmpty ? "" : "&filter="
        for param in params {
            filter += (param.key + ":" + (param.value as! String))
        }
        let url = URL(string: "https://www.giantbomb.com/api/reviews/?api_key=" + Global.apiKey + "&format=json" + filter)!
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
                    if let reviewsJson = json["results"] as? [[String: Any]] {
                        completionHandler(reviewsJson)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}
