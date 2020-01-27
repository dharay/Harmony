//
//  SimplePlaylistViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 26/06/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

enum ToShowType {
    case recentlyAdded
    case mostPlayed
    
}

class SimplePlaylistViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var orderedQueue: [MPMediaItem] = []
    
    var toShowType = ToShowType.recentlyAdded
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "playlistCellView", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "playlistCellView")
        
        if toShowType == .recentlyAdded{
            showQueue = allQueue
            showQueue.sort(by: {$0.dateAdded>$1.dateAdded})
        }else if toShowType == .mostPlayed {
            showQueue = CoreDataManager.getMostPlayedMediaItemsArray()
            
        }
      
        tableView.reloadData()
        
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showQueue.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCellView")! as! PlaylistCell
        let songTitle = showQueue[indexPath.row].title
        let songArtist = showQueue[indexPath.row].artist
        
        cell.parent = self
        cell.song = CoreDataManager.fetchStoredSong(title: songTitle!, artist: songArtist)
        cell.songLabel?.text = songTitle
        cell.awake()
        return cell
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        print("zzz")
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let collection = MPMediaItemCollection(items: showQueue)
        currentQueue = showQueue
        player.setQueue(with: collection)
        let nowPlayingSongItem = showQueue[indexPath.row]
        player.nowPlayingItem = nowPlayingSongItem
        PlayManager.setShuffleModeTo(state: false)
        player.play()
        
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playFromStartAction(_ sender: UIButton) {
        let temp = MPMediaItemCollection(items: showQueue)
        player.setQueue(with: temp)
        currentQueue = showQueue
        PlayManager.setShuffleModeTo(state: false)
        player.play()
    }
    
    @IBAction func shuffleAllAction(_ sender: UIButton) {
        let temp = MPMediaItemCollection(items: showQueue)
        player.setQueue(with: temp)
        currentQueue = showQueue
        PlayManager.setShuffleModeTo(state: true)
        player.play()
        
    }
    
}
extension SimplePlaylistViewController:ParentOfPlaylistCell {
    func optionAction(song: SongEntity) {
        let alert = UIAlertController(title: "song Options", message: song.title, preferredStyle: .actionSheet)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action) in}
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
