//
//  PlayManager.swift
//  Harmony
//
//  Created by Dharay Mistry on 03/04/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

enum ShuffleMode{
    case none
    case all
    case one
}


class PlayManager{
    
    static func checkiTunesAccess() -> Bool{
        if MPMediaLibrary.authorizationStatus() == .authorized {
            return true
        }
        var returnValue:Bool? = nil
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized{
                returnValue = true
            }else{
                returnValue = false
                
            }
        }
        
        while returnValue == nil {
            sleep(1)
        }
        return returnValue!
        
    }
    
    static func iTunesSongsSync() -> Bool{

        let allSongsQuery = MPMediaQuery.songs()
        if allSongsQuery.items == nil || allSongsQuery.items?.count == 0{
            
            return false
        }
        allQueue = allSongsQuery.items!.sorted(by: {$0.title! < $1.title!} )

        return true
    }
    
    static func setShuffleModeTo(state:Bool){
        if state == true {
            playVCGlobal.playMainVC.shuffleButton.alpha = 1
            player.shuffleMode = .songs
        }else{
            playVCGlobal.playMainVC.shuffleButton.alpha = 0.5
            player.shuffleMode = .off
        }
    }
    
    static func setRepeatModeTo(state:ShuffleMode){
        playVCGlobal.playMainVC.repeatButton.titleLabel?.font = UIFont(descriptor: UIFontDescriptor(), size: 28)
        switch state {
        case .all:
            player.repeatMode = .all
            playVCGlobal.playMainVC.repeatButton.setTitle("🔁", for: .normal)
            playVCGlobal.playMainVC.repeatButton.alpha = 1
        case .none:
            player.repeatMode = .none
            playVCGlobal.playMainVC.repeatButton.setTitle("🔁", for: .normal)
            playVCGlobal.playMainVC.repeatButton.alpha = 0.5
        case .one:
            player.repeatMode = .one
            playVCGlobal.playMainVC.repeatButton.setTitle("🔂", for: .normal)
            playVCGlobal.playMainVC.repeatButton.alpha = 1
        }
        
    }

    static func handleAppBecameForeGround (){ // handle current song playing
        if homeVCGlobal == nil{
            print("fuck")
        }
        if playVCGlobal == nil{
            print("fuck2")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player, queue: .main , using: {(n) in self.currentSongChanged(notifn: n)})
        currentSongChanged(notifn: Notification(name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange))
        
        /*if crashes :
        let t = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            if homeVCGlobal != nil{
                currentSongChanged(notifn: Notification(name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange))
                
            }else{
                print("refresh delayed")
                timer.fire()
            }
        }
        t.fire()*/
        
    }
    
    static func handleAppBecameBackGround(){
       // NotificationCenter.default.removeObserver(Any)
    }
    static func currentSongChanged(notifn: Notification){
        guard playVCGlobal != nil else {
            return
        }
        playVCGlobal.currentSongChanged(n: notifn)
        homeVCGlobal.currentSongChanged()
        CoreDataManager.increasePlayCount(item: player.nowPlayingItem)
        
    }
    
    
}
