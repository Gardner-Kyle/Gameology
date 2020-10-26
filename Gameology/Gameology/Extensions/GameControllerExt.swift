//
//  GameControllerExt.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/24/20.
//

import Foundation
import  UIKit
import AVKit

struct gameDataCell {
    var title: String!
    var releaseDate: String!
    var image: UIImage!
    var favorite = false
    var opened = false
    var sectionData: [String: Any] = [:]
}

extension GameController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.gameTable {
            return self.gameTableData.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameTableData[section].opened ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableSectionViewCell", for: indexPath) as? GameTableSectionViewCell else {
                fatalError("The dequeued cell is not an instance of GameTableSectionViewCell.")
            }
            if !self.gameTableData.isEmpty {
                let object = self.gameTableData[indexPath.section]
                cell.title.text = object.title
                cell.releaseDate.text = object.releaseDate
                
                // set favorites btn image
                if object.favorite {
                    cell.favoritesBtn.setImage(UIImage(named: "favorites"), for: .normal)
                } else {
                    cell.favoritesBtn.setImage(UIImage(named: "favorites_add"), for: .normal)
                }
                cell.favoritesBtn.tag = indexPath.section
                cell.gameImage.image = object.image
                self.loadingIndicator.stopAnimating()

            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableSubViewCell", for: indexPath) as? GameTableSubViewCell else {
                fatalError("The dequeued cell is not an instance of GameTableSubViewCell.")
            }
            // tag will help determine data for collection cells
            cell.collection.tag = indexPath.section
            cell.collection.delegate = self
            cell.collection.dataSource = self
            cell.collection.reloadData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.gameTable {
            if indexPath.row == 0 {
                if self.gameTableData[indexPath.section].opened {
                    self.gameTableData[indexPath.section].opened = false
                    let sections = IndexSet.init(integer: indexPath.section)
                    tableView.reloadSections(sections, with: .fade)
                } else {
                    self.gameTableData[indexPath.section].opened = true
                    let sections = IndexSet.init(integer: indexPath.section)
                    tableView.reloadSections(sections, with: .fade)
                    
                    let game = self.games[indexPath.section]
                    
                    // get reviews for review score
                    self.gameToScore[game.id] = 0
                    self.reviewService.getReviews(params: ["game": String(game.id) as Any]) { (json) in
                        for reviewJson in json {
                            let review = Review(json: reviewJson)
                            self.gameToScore[game.id]! += review.score
                        }
                        
                        // get video for game
                        if self.gameToVideo[game.id] == nil {
                            self.gameService.getGame(id: game.id) { (json) in
                                let fullGame = Game(json: json)
                                if fullGame.videos != nil, !fullGame.videos.isEmpty, let id = fullGame.videos[0].id {
                                    self.videoService.getVideo(id: id) { (json) in
                                        let video = Video(json: json)
                                        self.gameToVideo[fullGame.id] = video
                                        self.createVideoCore(gameId: game.id, video: video)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.gameTable {
            if indexPath.row == 0 {
                return 80
            } else {
                return 316
            }
        } else {
            return 60
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        let id = self.games[sender.tag].id!
        let favorite = self.gameToFavorite[id] ?? false
        if favorite {
            sender.setImage(UIImage(named: "favorites_add"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "favorites"), for: .normal)
        }
        self.gameToFavorite[id] = !favorite
    }
    
}

extension GameController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = collectionView.tag
        
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameSummaryCollectionViewCell", for: indexPath) as? GameSummaryCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of GameSummaryCollectionViewCell.")
            }
            if !self.gameTableData[section].sectionData.isEmpty {
                let object = self.gameTableData[section].sectionData
                cell.summary.text = object["summary"] as? String
            }
            cell.makeFancy()
            return cell
        } else if indexPath.row == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameVideoCollectionViewCell", for: indexPath) as? GameVideoCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of GameVideoCollectionViewCell.")
            }
            if !self.gameTableData[section].sectionData.isEmpty {
                let object = self.gameTableData[section].sectionData
                
                // load image from url
                if let url = URL(string: object["videoImageUrl"] as? String ?? "") {
                    let data = try? Data(contentsOf: url)
                    if let imageData = data {
                        cell.videoImage.image = UIImage(data: imageData)
                    }
                } else {
                    self.animateOut(view: cell.videoImage)
                    self.animateOut(view: cell.btn)
                }
            }
            cell.makeFancy()
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameScoreCollectionViewCell", for: indexPath) as? GameScoreCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of GameScoreCollectionViewCell.")
            }
            if !self.gameTableData[section].sectionData.isEmpty {
                if let score = self.gameTableData[section].sectionData["score"] as? Int, score != 0 {
                    cell.score.text = String(score) + "/5"
                } else {
                    cell.score.text = "N/A"
                }
            }
            cell.makeFancy()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = collectionView.tag
        if indexPath.row == 1 {
            if !self.gameTableData[section].sectionData.isEmpty {
                let object = self.gameTableData[section].sectionData
                
                // play video with AVPlayer
                if let url = URL(string: object["videoUrl"] as? String ?? "") {
                    self.avPlayer = AVPlayer(url: url)
                    let vc = AVPlayerViewController()
                    vc.player = self.avPlayer
                    present(vc, animated: true) {
                        vc.player?.play()
                    }
                }
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if indexPath.row == 0 {
            return CGSize(width: width, height: 128)
        } else if indexPath.row == 1 {
            return CGSize(width: (width * 0.65) - 10, height: 128)
        } else {
            return CGSize(width: (width * 0.35) - 10, height: 128)
        }
        
    }
    
}
