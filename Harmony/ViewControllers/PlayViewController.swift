//
//  PlayViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 2/27/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayViewController: UIViewController {

    var leftVC = UIViewController()
    var playMainVC = PlayScreenViewController()
    @IBOutlet weak var customBaseView: BmoViewPager!
    var rightVC = LyricsViewController()
    
    func currentSongChanged(n:Notification){
        print("songChanged")
        //TODO: fix multiple calls of this function on app entering foreground
        playMainVC.songTitleView.text = player.nowPlayingItem?.title ?? ""
        playMainVC.songArtistTextView.text = "👩‍🎨" + ((player.nowPlayingItem?.artist) ?? "")
        playMainVC.songAlbumTextView.text = "💽" + ((player.nowPlayingItem?.albumTitle) ?? "")
        playMainVC.albumArtView.image = player.nowPlayingItem?.artwork?.image(at: CGSize(width: 200, height: 200)) ?? #imageLiteral(resourceName: "default-albumart")
        if !songReqFlag{
            return
        }
        if player.nowPlayingItem == nil {return}
        playMainVC.heartButton.backgroundColor = CoreDataManager.fetchStoredSong(title: (player.nowPlayingItem?.title) ?? "", artist: player.nowPlayingItem?.artist).isFavourite ? UIColor.red : UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftVC = (self.storyboard?.instantiateViewController(withIdentifier: "0"))!
        playMainVC = (self.storyboard?.instantiateViewController(withIdentifier: "1"))! as! PlayScreenViewController
        rightVC = (self.storyboard?.instantiateViewController(withIdentifier: "2"))! as! LyricsViewController
        customBaseView.dataSource = self
        customBaseView.delegate =  self
		customBaseView.presentedPageIndex = 0
        
        if player.nowPlayingItem == nil {
            player.setQueue(with: MPMediaItemCollection(items: allQueue))
            player.nowPlayingItem = allQueue.first
            currentQueue = allQueue
            player.prepareToPlay()
            player.pause()
        }
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVCGlobal = self
    }
    
    


}

extension PlayViewController:BmoViewPagerDataSource,BmoViewPagerDelegate{
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return 2
    }
    
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        
        switch page {
        case 0:
            return playMainVC
        case 1:
            return rightVC
//        case 2:
//            return rightVC
        default:
            return playMainVC
        }
        
        
    }
    
    func bmoViewPagerDelegate(_ viewPager: BmoViewPager, didAppear viewController: UIViewController, page: Int) {
        if page == 1 {
            rightVC.startLoadForSong()
        }
       
        
    }
    
    
    
    
}

