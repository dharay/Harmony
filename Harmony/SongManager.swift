//
//  SongManager.swift
//  Harmony
//
//  Created by Dharay Mistry on 08/04/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation

class SongManager {
    
    static func checkIfFavourite(song:String, album:String?, artist:String?) -> Bool{
        let song = findStoredSong(song: song, album: album, artist: artist)
        if song == nil {
            return false
        }
        return song!.isFavourite
    }
    
    static func markFavourite(song:String, album:String?, artist:String?){
        let song = findStoredSong(song: song, album: album, artist: artist)
        guard song != nil else {
            //TODO: show alert
            print("song not found in core data, external song playing")
            return
        }
        song?.isFavourite = true
        try! CoreDataManager.context.save()
        
        
    }
    
    static func findStoredSong (song:String, album:String?, artist:String?) -> SongEntity?{
        let song = storedSongs.filter { (songEnt) -> Bool in
            if songEnt.title == song && songEnt.album == album && songEnt.artist == artist{
                return true
            }
            return false
        }
        if song.count == 0{
            print("---------WARNING NO SONG FOUND IN CORE DATA--------")
            return nil
        }
        //TODO: multiple songs fetched case
        return song[0]
    }
    
}
