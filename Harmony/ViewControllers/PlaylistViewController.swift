//
//  PlayalistViewController.swift
//  Harmony
//
//  Created by dharay mistry on 03/03/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlaylistViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    var arrIndexSection = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    var sectionDict: [String:[MPMediaItem]] = [:]
    
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    var sectionDictKeys : [String] = []
    var sectionDictValues : [[MPMediaItem]] = []
    var orderedQueue: [MPMediaItem] = []
    
    var playlistShowType: PlaylistShowType = .allSongs
    var playlistEntity : PlaylistEntity!
  
    var playListShowQueue:[MPMediaItem] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var playListName = ""
        
        if playlistEntity != nil {
            playListName = playlistEntity.title!
        }
        
        let nib = UINib.init(nibName: "playlistCellView", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "playlistCellView")
        
        switch playlistShowType {
        case .allSongs:
            showQueue = allQueue
            hideHeader()
        case .customPlaylist:
            showQueue = playListShowQueue
            showHeader(title: playListName)
        case .album , .artist:
            hideHeader()
            break
        case .favourites:
            showQueue = playListShowQueue
            hideHeader()
            break
        case .nowPlayingQueue:
            showHeader(title: "Now Playing")
            self.deleteButton.isHidden = true
            break
        }
        
        for i in 0..<showQueue.count{
            
            if arrIndexSection.contains( String((showQueue[i].title?.uppercased().first)!)) {
                let index = arrIndexSection.index(of:  String((showQueue[i].title?.uppercased().first)!))
                
                if !sectionDict.keys.contains(arrIndexSection[index!]){
                    sectionDict[arrIndexSection[index!]] = []
                }
                sectionDict[String((showQueue[i].title?.uppercased().first)!)]? += [showQueue[i]]
                
            }else{
                if !sectionDict.keys.contains("#"){
                    sectionDict["#"] = []
                }
                sectionDict["#"]? += [showQueue[i]]
            }
            
        }
        sectionDictKeys = sectionDict.keys.sorted()
        for i in sectionDict{
            sectionDictValues.append(sectionDict[i.key]!)
        }
        print(showQueue.count)
        
        showQueue.sort(by: {$0.title!<$1.title!})
        tableView.reloadData()
        
		
	}
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDict.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDictKeys[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDict[sectionDictKeys[section]]!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCellView")! as! PlaylistCell
        let songTitle = sectionDict[sectionDictKeys[indexPath.section]]?[indexPath.row].title
        let songArtist = sectionDict[sectionDictKeys[indexPath.section]]?[indexPath.row].artist
        
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
        let nowPlayingSongItem = sectionDict[sectionDictKeys[indexPath.section]]![indexPath.row]
        player.nowPlayingItem = nowPlayingSongItem
        PlayManager.setShuffleModeTo(state: false)
        player.play()
        
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionDictKeys
    }

    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playFromStartAction(_ sender: UIButton) {
        let temp = MPMediaItemCollection(items: showQueue)
        player.setQueue(with: temp)
        player.value(forKey: "queue")
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
    func showHeader(title : String) {
        headerHeight.constant = 50
        headerTitle.text = title
        deleteButton.setTitle( "🗑",for: .normal)
        self.view.setNeedsLayout()
    }
    func hideHeader(){
        headerHeight.constant = 0
        headerTitle.text = ""
        deleteButton.setTitle("", for: .normal)
        self.view.setNeedsLayout()
    }

}

extension PlaylistViewController:ParentOfPlaylistCell {
    func optionAction(song: SongEntity) {
        let alert = UIAlertController(title: "song Options", message: song.title, preferredStyle: .actionSheet)
        
        switch self.playlistShowType {
        case .customPlaylist:
             let removeAction = UIAlertAction(title: "remove from playlist", style: .default) { (action) in
                CoreDataManager.editPlaylist(playlist: self.playlistEntity, newSongs: [], toDeleteSongs: [song])
                CoreDataManager.fetchPlaylists()
                var songItems:[MPMediaItem] = []
                let songs = self.playlistEntity.relationship?.allObjects as! [SongEntity]
                for i in songs{
                    songItems.append( allQueue.first(where:{ $0.title! == i.title && $0.artist == i.artist})!)
                }
                self.playListShowQueue = songItems
                self.sectionDictKeys = []
                self.sectionDictValues = []
                self.sectionDict = [:]
                self.viewDidLoad()
                self.tableView.reloadData()
             }
            alert.addAction(removeAction)
            for i in storedPlaylists{
                if i != playlistEntity {
                    let addAction = UIAlertAction(title: "Add to " + i.title!, style: .default) { (action) in
                        CoreDataManager.editPlaylist(playlist: i, newSongs: [song], toDeleteSongs: [])
                    }
                    alert.addAction(addAction)
                }
            }
            
        default:
            for i in storedPlaylists {
                if i != playlistEntity {
                    let addAction = UIAlertAction(title: "Add to " + i.title!, style: .default) { (action) in
                        CoreDataManager.editPlaylist(playlist: i, newSongs: [song], toDeleteSongs: [])
                    }
                    alert.addAction(addAction)
                }
            }
        }

        
        let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action) in}

        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func deleteButtonAction(_ sender: Any) {
        guard playlistEntity != nil else {
            print("playlist nil , cant delete")
            return
        }
        CoreDataManager.deletePlaylist(playlist: playlistEntity)
        self.dismiss(animated: true, completion: {homeVCGlobal.homeVC.viewDidLoad()})
    }
   
}

enum PlaylistShowType {
    case allSongs
    case customPlaylist
    case artist
    case album
    case nowPlayingQueue
    case favourites
}
