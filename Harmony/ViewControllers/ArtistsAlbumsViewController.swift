//
//  ArtistsAlbumsViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 01/05/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import MediaPlayer


class ArtistsAlbumsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var toShow = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aaCell")
        cell?.textLabel?.text = toShow[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlsitVC = self.storyboard!.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
        
        if artistsFlag{
            playlsitVC.playlistShowType = .artist
            showQueue = allQueue.filter({ (mediaItem) -> Bool in
                return mediaItem.artist == toShow[indexPath.row]
            })
        }else{
            playlsitVC.playlistShowType = .album
            showQueue = allQueue.filter({ (mediaItem) -> Bool in
                return mediaItem.albumTitle == toShow[indexPath.row]
                
            })
        }
        self.navigationController?.pushViewController(playlsitVC, animated: true)
    }
    
    @IBOutlet weak var table: UITableView!
    //var toShow
    
    @IBAction func dismissButton(_ sender: Any) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        self.navigationItem.titleView?.backgroundColor = .cyan
        if artistsFlag{
            toShow = (MPMediaQuery.artists().items?.map({ (mediaItem) -> String in
                return mediaItem.artist ?? ""
            }))!
            self.navigationItem.title = "Artists"
            toShow = Array(Set(toShow)).sorted(by:{ $0<$1 })
            
        }else{
            self.navigationItem.title = "Albums"
            toShow = (MPMediaQuery.albums().items?.map({ (mediaItem) -> String in
                return mediaItem.albumTitle ?? ""
            }))!
            
            toShow = Array(Set(toShow)).sorted(by:{ $0<$1 })
            
        }
        
        table.reloadData()
        
        // Do any additional setup after loading the view.
    }


}
