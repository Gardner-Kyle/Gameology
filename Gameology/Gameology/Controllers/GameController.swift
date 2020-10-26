//
//  GameController.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/23/20.
//

import UIKit
import AVKit
import CoreData

class GameController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gameTable: UITableView!
    @IBOutlet weak var menuBtn: UIButton!

    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var favoritesBtn: UIButton!
    @IBOutlet weak var bombBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var gameService = GameService()
    var videoService = VideoService()
    var reviewService = ReviewService()
    
    var params: [String: Any] = [:]
    var games: [Game] = []
    var gameToScore: [Int : Int] = [:]
    var gameToVideo: [Int : Video] = [:]
    var gameToFavorite: [Int : Bool] = [:]
    
    var pageLimit = 25
    var offset = 0
    var nilOffset = 0
    var pageNumber = 1
    
    var gameTableData: [gameDataCell] = []
    var avPlayer: AVPlayer?
    
    var selectedGame: Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.getCoreData()
    }
    
    override func viewDidLayoutSubviews() {
        self.setup()
    }
    
    func setup() {
        self.gameTable.delegate = self
        self.gameTable.dataSource = self
        
    }
    
    @IBAction func pageChange(_ sender: UIButton) {
        switch sender {
        case self.backBtn:
            if self.offset > 0 {
                self.pageNumber -= 1
                self.offset = self.pageLimit * (self.pageNumber - 1)
                self.getCoreData(params: ["&offset=": String(self.offset + self.nilOffset), "limit": String(self.pageLimit)])
                self.pageLabel.text = self.offset == 0 ? "Page 1" : "Page " + String(self.pageNumber)
            }
        case self.forwardBtn:
            if !self.games.isEmpty {
                self.pageNumber += 1
                self.offset = self.pageLimit * (self.pageNumber - 1)
                self.getCoreData(params: ["&offset=": String(self.offset + self.nilOffset), "limit": String(self.pageLimit)])
                self.pageLabel.text = self.offset == 0 ? "Page 1" : "Page " + String(self.pageNumber)
            }
        default:
            break
        }
    }
    
    @IBAction func loadFavorites() {
        // get all games from coreData - filter by 'favorite' = true
    }
    
    @IBAction func bombSite() {
        if let url = URL(string: "https://www.giantbomb.com/api/") {
            UIApplication.shared.open(url)
        }
    }
    
    func fillGameData() {
        self.gameTableData.removeAll()
        for game in self.games {
            var image = UIImage()
            if let url = URL(string: game.image) {
                let data = try? Data(contentsOf: url)
                if let imageData = data {
                    image = UIImage(data: imageData)!
                }
            }
            let videoUrl = self.gameToVideo[game.id]?.hd_url == "N/A" ? self.gameToVideo[game.id]?.high_url == "N/A" ? self.gameToVideo[game.id]?.low_url == "N/A" ? "N/A" : self.gameToVideo[game.id]?.low_url : self.gameToVideo[game.id]?.high_url : self.gameToVideo[game.id]?.hd_url
            self.gameTableData.append(
                gameDataCell(
                    title: game.name,
                    releaseDate: game.original_release_date,
                    image: image,
                    favorite: game.favorite ?? self.gameToFavorite[game.id] ?? false,
                    opened: false,
                    sectionData: [
                        "summary": game.deck as Any,
                        "score": self.gameToScore[game.id] as Any,
                        "videoUrl": videoUrl as Any,
                        "videoImageUrl": self.gameToVideo[game.id]?.image as Any
                    ])
            )
        }
    }
    
    func doubleRequest(game: Game) -> Bool {
        for oldGame in self.games {
            if oldGame.id == game.id {
                return true
            }
        }
        return false
    }
    
    func fillGameTable(params: [String: Any] = [:]) {
        self.loadingIndicator.startAnimating()
        self.gameService.getGames(params: params) { (json) in
            self.gameToFavorite.removeAll()
            self.games.removeAll()
            for gameJson in json {
                let game = Game(json: gameJson)
                if game.original_release_date != "N/A" {
                    
                    // Check for duplicate data
                    if self.doubleRequest(game: game) {
                        DispatchQueue.main.async {
                            self.offset += self.pageLimit
                            self.fillGameTable(params: ["&offset=": String(self.offset), "limit": self.pageLimit])
                        }
                    } else {
                        self.games.append(game)
                        self.gameToFavorite[game.id] = false
                        DispatchQueue.main.async {
                            self.createGameCore(game: game)
                        }
                    }
                } else {
                    self.nilOffset += 1
                }
            }
            
            // Make sure table will fill
            if self.games.count < 25 {
                DispatchQueue.main.async {
                    self.offset += (25 - self.games.count)
                    self.fillGameTable(params: ["&offset=": String(self.offset)])
                }
            } else {
                DispatchQueue.main.async {
                    self.fillGameData()
                    self.gameTable.reloadData()
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    // Core Data
    
    func getCoreData(params: [String: Any] = [:]) {
        self.loadingIndicator.startAnimating()
        self.requestGameData { (gameData) in
            self.games.removeAll()
            self.games = gameData
            self.requestVideoData { (videoData) in
                for video in videoData {
                    self.gameToVideo[video.gameId] = video
                }
                if self.games.isEmpty {
                    self.fillGameTable(params: params)
                } else {
                    self.fillGameData()
                    self.gameTable.reloadData()
                }
            }
        }
    }
    
    func requestGameData(completionHandler: @escaping ([Game]) -> Void) -> Void {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameCore")
        
        fetchRequest.fetchLimit = self.pageLimit
        fetchRequest.fetchOffset = self.offset
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            var fetchedGames: [Game] = []
            for data in result as! [NSManagedObject] {
                let game = Game(
                    id: data.value(forKey: "id") as! Int,
                    name: data.value(forKey: "name") as! String,
                    deck: data.value(forKey: "deck") as! String,
                    original_release_date: data.value(forKey: "original_release_date") as! String,
                    image: data.value(forKey: "image") as! String,
                    favorite: data.value(forKey: "favorite") as! Bool,
                    videos: data.value(forKey: "videos") as? [Video] ?? []
                )
                fetchedGames.append(game)
            }
            completionHandler(fetchedGames)
        } catch {
            print("failed to fetch GameCore")
        }
    }
    
    func requestVideoData(completionHandler: @escaping ([Video]) -> Void) ->  Void {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoCore")
                
        do {
            let result = try managedContext.fetch(fetchRequest)
            var fetchedVideos: [Video] = []
            for data in result as! [NSManagedObject] {
                let video = Video(json: [
                    "id": data.value(forKey: "id") as Any,
                    "name": data.value(forKey: "name") as Any,
                    "deck": data.value(forKey: "deck") as Any,
                    "hd_url": data.value(forKey: "hd_url") as Any,
                    "high_url": data.value(forKey: "high_url") as Any,
                    "low_url": data.value(forKey: "low_url") as Any,
                    "image": data.value(forKey: "image") as Any,
                    "publish_date": data.value(forKey: "publish_date") as Any,
                    "user": data.value(forKey: "user") as Any,
                    "gameId": data.value(forKey: "gameId") as Any
                ])
                fetchedVideos.append(video)
            }
            completionHandler(fetchedVideos)
        } catch {
            print("failed to fetch GameCore")
        }
    }
    
    func exists(id: Int, entity: String) -> Bool {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return true}
        let managedContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)

        do {
            let result = try managedContext.fetch(fetchRequest)
            return result.count > 0 ? true : false
        } catch {
            return true
        }
    }
    
    func createGameCore(game: Game) {
        if !self.exists(id: game.id, entity: "GameCore") {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let gameEntity = NSEntityDescription.insertNewObject(forEntityName: "GameCore", into: managedContext)
            
            gameEntity.setValuesForKeys([
                "id": game.id as Any,
                "name": game.name as Any,
                "deck": game.deck as Any,
                "original_release_date": game.original_release_date as Any,
                "image": game.image as Any,
                "videos": game.videos as Any,
                "favorite": game.favorite as Any
            ])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save GameCore. \(error), \(error.userInfo)")
            }
        }
    }
    
    func createVideoCore(gameId: Int, video: Video) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appdelegate.persistentContainer.viewContext
        
        if !self.exists(id: video.id, entity: "VideoCore") {
            let videoEntity = NSEntityDescription.entity(forEntityName: "VideoCore", in: managedContext)!
            
            let videoCore = NSManagedObject(entity: videoEntity, insertInto: managedContext)
            videoCore.setValuesForKeys([
                "id": video.id as Any,
                "name": video.name as Any,
                "deck": video.deck as Any,
                "hd_url": video.hd_url as Any,
                "high_url": video.high_url as Any,
                "low_url": video.low_url as Any,
                "image": video.image as Any,
                "publish_date": video.publish_date as Any,
                "user": video.user as Any,
                "gameId": gameId as Any
            ])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save VideoCore. \(error), \(error.userInfo)")
            }
        }
    }
    
    // Animate
    
    @IBAction func openNavBar() {
        if self.navBarView.alpha == 0 {
            self.navBarView.frame = CGRect(x: self.navBarView.frame.maxX, y: self.navBarView.frame.minY, width: 0, height: self.navBarView.frame.height)
            self.animateIn(view: self.navBarView)
            UIView.animate(withDuration: 0.2, animations: {
                self.navBarView.frame = CGRect(x: self.view.frame.maxX - 65, y: self.view.frame.minY, width: 65, height: self.navBarView.frame.height)
            })
        } else {
            self.animateOut(view: self.navBarView)
        }
    }

}

