//
//  CoreDataManger.swift
//
//
//  Created by Dharay Mistry on 09/04/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MediaPlayer

class CoreDataManager{
   
    static let appDel = UIApplication.shared.delegate as! AppDelegate
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    static func context -> NSManagedObjectContext {
//        var temp : NSManagedObjectContext!
//        onMainQ {
//            temp = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        }
//        return temp
//    }
    static func fetchSongs(){
        let fetchReq = NSFetchRequest<SongEntity>(entityName: "SongEntity")
        
        do{storedSongs = try context.fetch(fetchReq)}
        // TODO: handle
        catch{print("fuck. unable to fetch core data songs")}
        
        if storedSongs.count == 0 {
            let allSongsQuery = MPMediaQuery.songs()
            if allSongsQuery.items == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {fetchSongs()})
                songReqFlag = false
                return
            }
            songReqFlag = true
            allQueue = allSongsQuery.items!.sorted(by: {$0.title! < $1.title!} )
            storeAllSongsFromAllQAndReset()
        }else{
            var storedSongsToDelete: [SongEntity] = []
            
            //check storedSong exists in allQueue, if not, delete in storedSongs
            for i in storedSongs{
                if allQueue.filter({$0.title == i.title && $0.artist == i.artist}).count == 0{
                    storedSongsToDelete.append(i)
                }
            }
            if storedSongsToDelete.count > 0{
                for i in storedSongsToDelete{
                    storedSongs.remove(object: i)
                }
            }
            
            // if new song added iin allQueue, add to storedSongs
            for i in allQueue{
                if storedSongs.filter({$0.title == i.title && $0.artist == i.artist}).count == 0{
                    let entity = NSEntityDescription.entity(forEntityName: "SongEntity", in: context)
                    let song = NSManagedObject(entity: entity!, insertInto: context)
                    song.setValue(i.title, forKey: "title")
                    song.setValue(i.albumTitle, forKey: "album")
                    song.setValue(i.artist, forKey: "artist")
                    song.setValue(false, forKey: "isFavourite")
                    song.setValue("", forKey: "lyrics")
                    song.setValue(0, forKey: "playCount")
                    do{try context.save()}
                    catch{print("fuck")}
                }
            }
            
            do{try context.save()}
            catch{print("fuck")}
        }
    }
    static func fetchPlaylists(){
        let fetchReq = NSFetchRequest<PlaylistEntity>(entityName: "PlaylistEntity")
        
        do{storedPlaylists = try context.fetch(fetchReq)}
        // TODO: handle
        catch{print("fuck")}
    }
    
    static func storeAllSongsFromAllQAndReset(){
        let entity = NSEntityDescription.entity(forEntityName: "SongEntity", in: context)
        for i in allQueue{
            let song = NSManagedObject(entity: entity!, insertInto: context)
            song.setValue(i.title, forKey: "title")
            song.setValue(i.albumTitle, forKey: "album")
            song.setValue(i.artist, forKey: "artist")
            song.setValue(false, forKey: "isFavourite")
            song.setValue("", forKey: "lyrics")
            song.setValue(0, forKey: "playCount")
        }
        do{try context.save()}
        catch{print("fuck")}
        if allQueue.count != 0{
            fetchSongs()
            print("check infinite recursive call except for once")
        }
    }
    
    static func storeNewPlaylist(title:String, songs: [SongEntity]){
        let entity = NSEntityDescription.entity(forEntityName: "PlaylistEntity", in: context)
        let playlist = NSManagedObject(entity: entity!, insertInto: context)
        playlist.setValue(title, forKey: "title")
        playlist.setValue(storedPlaylists.count, forKey: "order")
        let rel = playlist.mutableSetValue(forKey: "relationship")
        rel.addObjects(from: songs)
        do{try context.save()}
        catch{print("fuck")}
    }
    
    static func editPlaylist(playlist: PlaylistEntity, newSongs: [SongEntity],toDeleteSongs: [SongEntity]){
        let rel = playlist.mutableSetValue(forKey: "relationship")
        if newSongs.count>0{
            rel.addObjects(from: newSongs)
        }
        if toDeleteSongs.count>0{
            for i in toDeleteSongs{
                rel.remove(i)
            }
        }
        do{try context.save()}
        catch{print("fuck")}
    }
    
    static func increasePlayCount(item:MPMediaItem?){
        guard let item  = item else {
            print("nowPlaying item nil")
            return
        }
        let song = storedSongs.filter { (song) -> Bool in
            song.title == item.title && song.artist == item.artist
        }.first
        for i in 0..<mostPlayedQueue.count {
            if mostPlayedQueue[i][0] as! MPMediaItem == item {
                let count = (mostPlayedQueue[i][1] as! Int)
                mostPlayedQueue[i][1]  = count + 1
            }
        }
        mostPlayedQueue = mostPlayedQueue.sorted(by: { $0[1] as! Int > $1[1] as! Int})
        
        let count = song?.playCount
        song?.setValue((count ?? 0) + 1, forKey: "playCount")
        do{try context.save()}
        catch{print("fuck")}
    }
    static func getMostPlayedMediaItemsArray() -> [MPMediaItem]{
        let orderedItems = mostPlayedQueue.map({$0[0] as! MPMediaItem})
        return orderedItems
    }
    static func setUpMostPlayedItems() {
        let orderedEntities = storedSongs.sorted(by: {$0.playCount>$1.playCount})
        
        let orderedItems = orderedEntities.map { (songEntity) -> MPMediaItem in
            let item = allQueue.filter({$0.title == songEntity.title && $0.artist == songEntity.artist}).first
            return item!
        }
        for i in 0..<orderedItems.count {
            mostPlayedQueue.append([orderedItems[i],  Int(orderedEntities[i].playCount)])
        }
        
    }
    
    static func deletePlaylist(playlist: PlaylistEntity){
        context.delete(playlist)
        do{try context.save()}
        catch{print("fuck")}
        
    }
    
    static func toggleFav(song:SongEntity){
        song.setValue(!song.isFavourite, forKey: "isFavourite")
        do{try context.save()}
        catch{print("fuck")}
        
    }
    
    static func fetchStoredSong(title:String, artist:String?) -> SongEntity{
        return storedSongs.first(where:{ $0.title == title &&  $0.artist == artist})!
    }
    
    static func setLyricsUrl(title:String, artist:String?, lyricsUrl:String){
        fetchStoredSong(title: title, artist: artist).setValue(lyricsUrl, forKey: "lyrics")
        do{try context.save()}
        catch{print("fuck")}
    }
    
}
