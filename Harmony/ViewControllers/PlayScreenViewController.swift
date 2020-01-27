//
//  PlayScreenViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 3/2/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayScreenViewController: UIViewController {
    @IBOutlet weak var songTitleView: UITextField!
    @IBOutlet weak var songArtistTextView: UITextField!
    @IBOutlet weak var songAlbumTextView: UITextField!
    @IBOutlet weak var albumArtView: UIImageView!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var currentSongTimeLabel: UILabel!
    @IBOutlet weak var totalSongTimeLabel: UILabel!
    @IBOutlet weak var songSlider: UISlider!
    
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentSongTimeLabel.adjustsFontSizeToFitWidth = true
        totalSongTimeLabel.adjustsFontSizeToFitWidth = true
        
        //for slider
        let songTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handleSongTime), userInfo: nil, repeats: true)
        songTimer.fire()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.repeatButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //set button states
        if player.shuffleMode == .off{
            shuffleButton.alpha = 0.5
        }else{
            shuffleButton.alpha = 1
        }
        
        switch player.repeatMode {
            
        case .all:
            player.repeatMode = .all
            self.repeatButton.setTitle("🔁", for: .normal)
            self.repeatButton.alpha = 1
        case .none:
            player.repeatMode = .none
            self.repeatButton.setTitle("🔁", for: .normal)
            self.repeatButton.alpha = 0.5
        case .one:
            player.repeatMode = .one
            self.repeatButton.setTitle("🔂", for: .normal)
            self.repeatButton.alpha = 1
        case .default:
            player.repeatMode = .all
            self.repeatButton.setTitle("🔁", for: .normal)
            self.repeatButton.alpha = 1
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //PlayManager.currentSongChanged(notifn: Notification.init(name: Notification.Name("asd")))
        self.songTitleView.text = player.nowPlayingItem?.title ?? ""
        self.songArtistTextView.text = "👩‍🎨" + ((player.nowPlayingItem?.artist) ?? "")
        self.songAlbumTextView.text = "💽" + ((player.nowPlayingItem?.albumTitle) ?? "")
        self.albumArtView.image = player.nowPlayingItem?.artwork?.image(at: CGSize(width: 200, height: 200)) ?? #imageLiteral(resourceName: "default-albumart")
        if !songReqFlag{
            return
        }
        if player.nowPlayingItem == nil {return}
        self.heartButton.backgroundColor = CoreDataManager.fetchStoredSong(title: (player.nowPlayingItem?.title) ?? "", artist: player.nowPlayingItem?.artist).isFavourite ? UIColor.red : UIColor.clear
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @objc func handleSongTime(t : Timer) {
        if player.nowPlayingItem == nil {
            return
        }
        self.currentSongTimeLabel.text = Int(player.currentPlaybackTime).toTime()
        self.totalSongTimeLabel.text = Int((player.nowPlayingItem?.playbackDuration)!).toTime()
        self.songSlider.maximumValue = Float((player.nowPlayingItem?.playbackDuration)!)
        self.songSlider.minimumValue = 0
        self.songSlider.value = Float(player.currentPlaybackTime)
    }

    
    @IBAction func previousAction(_ sender: Any) {
        if player.currentPlaybackTime < 5{
            player.skipToPreviousItem()
        }else{
            player.skipToBeginning()
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        player.skipToNextItem()
       // NotificationCenter.default.post(name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)

    }
    @IBAction func playlistAction(_ sender: UIButton) {
    }
    

    @IBAction func play(_ sender: Any) {
        if player.playbackState == .playing{
            player.pause()
        }else if player.playbackState == .paused || player.playbackState == .stopped{
            player.play()
            
        }else{
            print("fuck play")
        }
        
        
    }
    
    @IBAction func repeatButtonAction(_ sender: Any) {
        switch player.repeatMode {
        case .all:
            PlayManager.setRepeatModeTo(state: .one)
        case .one:
            PlayManager.setRepeatModeTo(state: .none)
        case .none:
            PlayManager.setRepeatModeTo(state: .all)
        case .default:
            PlayManager.setRepeatModeTo(state: .all)
        }
    }
    @IBAction func shuffleButtonAction(_ sender: Any) {
        if player.shuffleMode == .off{
            PlayManager.setShuffleModeTo(state: true)
        }else{
            PlayManager.setShuffleModeTo(state: false)
        }
    }
    
    @IBAction func showPlaylist(_ sender: Any) {
		
        let p = self.storyboard!.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
        p.modalTransitionStyle = .crossDissolve
        if currentQueue.contains(player.nowPlayingItem!){
            p.playlistShowType = .nowPlayingQueue
            showQueue = currentQueue
            
        }else{
            p.playlistShowType = .allSongs
        }
        self.present(p, animated: true, completion: nil)
	}
    
}
