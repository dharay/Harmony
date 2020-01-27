import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class HomeCollectionViewController:UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{

	var titles  = ["Songs","Artists","Albums","Recently Added","Most Played","Favourites"]
    var playLists:[String] = []
    @IBOutlet weak var collectionView: UICollectionView!
    var newPlaylist = ["New Playlist"]
	
	@IBOutlet weak var homeCollection: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        CoreDataManager.fetchPlaylists()
        playLists = storedPlaylists.map({ (playListEntity) -> String in
            return playListEntity.title!
        })
        self.collectionView.reloadData()
	}
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let itemEdge = uiWidth * 0.72 * 1/3
        let spacing = uiWidth * 0.28 * 1/4
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemEdge, height: itemEdge)
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 50, left: spacing, bottom: 10, right: spacing)
        homeCollection.setCollectionViewLayout(layout, animated: true)
        layout.scrollDirection = .vertical
        
        
        
    }
    
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return titles.count + playLists.count + newPlaylist.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = self.homeCollection.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        switch indexPath.row {
        case 0..<titles.count:
            cell.label.text = titles[indexPath.row]
        case titles.count - 1 ..< titles.count + playLists.count:
            cell.label.text = playLists[indexPath.row - titles.count ]
        default:
            cell.label.text = newPlaylist.first
        }
		
        cell.label.adjustsFontSizeToFitWidth = true
		return cell
	}
    
    //var titles  = [0:"Songs",1:"Artists",2:"Albums",3:"Recently Added",4:"Most Played",5:"Favourites"]
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let p = self.storyboard!.instantiateViewController(withIdentifier: "playlist")
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
            
        case 1:
            
            let p = self.storyboard!.instantiateViewController(withIdentifier: "a")
            artistsFlag = true
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
        case 2:
            let p = self.storyboard!.instantiateViewController(withIdentifier: "a")
            artistsFlag = false
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
        case 3:
            let p = self.storyboard!.instantiateViewController(withIdentifier: "simplePlaylist") as! SimplePlaylistViewController
            p.toShowType = .recentlyAdded
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
            
        case 4:
            let p = self.storyboard!.instantiateViewController(withIdentifier: "simplePlaylist") as! SimplePlaylistViewController
            p.toShowType = .mostPlayed
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
            
        case 5:
            let p = self.storyboard!.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
            var favSongItems:[MPMediaItem] = []
            let favSongs = storedSongs.filter({$0.isFavourite})
            for i in favSongs{
                favSongItems.append( allQueue.first(where:{ $0.title! == i.title && $0.artist == i.artist})!)
            }
            p.playListShowQueue = favSongItems
            p.playlistShowType = .favourites
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
            
            
        case titles.count + playLists.count + newPlaylist.count - 1:
            
            self.present(newPlaylistAlert(), animated: true) {
                collectionView.reloadData()
            }
        
        default: // customPlaylist
            
            let p = self.storyboard!.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
            var songItems:[MPMediaItem] = []
            let songs = storedPlaylists[indexPath.row-titles.count].relationship?.allObjects as! [SongEntity]
            for i in songs{
                songItems.append( allQueue.first(where:{ $0.title! == i.title && $0.artist == i.artist})!)
            }
            p.playlistEntity = storedPlaylists[indexPath.row-titles.count]
            p.playListShowQueue = songItems
            p.playlistShowType = .customPlaylist
            p.modalTransitionStyle = .crossDissolve
            self.present(p, animated: true, completion: nil)
            break
           
        }
    }
    
    func newPlaylistAlert(message: String = "enter name") -> UIAlertController{
        let alert = UIAlertController(title: "Create New Playlist", message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {$0.adjustsFontSizeToFitWidth = true})
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if self.playLists.contains((alert.textFields?.first)!.text!){
                let message = "playlist name already exist please enter again"
                self.present(self.newPlaylistAlert(message: message), animated: true, completion: nil)
                return
            }
            if (alert.textFields?.first)!.text!.filter({$0 == " "}).count == (alert.textFields?.first)!.text!.count{
                let message = "name should contain at least one character"
                self.present(self.newPlaylistAlert(message: message), animated: true, completion: nil)
                return
            }
            CoreDataManager.storeNewPlaylist(title: (alert.textFields?.first)!.text!  , songs: [])
            self.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action) in}
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        return alert
        
    }
}
class HomeCollectionViewCell:UICollectionViewCell{
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var label: UILabel!
	
	
}


