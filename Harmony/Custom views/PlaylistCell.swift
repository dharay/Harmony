//
//  PlaylistCell.swift
//  Harmony
//
//  Created by Dharay Mistry on 04/07/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import Foundation
import UIKit

class PlaylistCell: UITableViewCell{
    
    var song:SongEntity!
    weak var parent : ParentOfPlaylistCell?
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var songLabel: UILabel?
    @IBAction func optionAction(_ sender: UIButton) {
        print("option")
        parent?.optionAction(song: song)
    }
    @IBAction func favAction(_ sender: UIButton) {
        print("fav")
        
        favButton.imageView?.contentMode = .scaleAspectFit
        if song.isFavourite{
            favButton.setImage(#imageLiteral(resourceName: "heartEmpty"), for: .normal) //favButton.image = #imageLiteral(resourceName: "heartEmpty")
        }else{
            favButton.setImage(#imageLiteral(resourceName: "heartFilled"), for: .normal)//favButton.image = #imageLiteral(resourceName: "heartFilled")
        }
        favButton.reloadInputViews()
        CoreDataManager.toggleFav(song: song)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func awake(){
        favButton.imageView?.contentMode = .scaleAspectFit
        if song.isFavourite{
            print([song.title,String(song.isFavourite)])
            favButton.setImage(#imageLiteral(resourceName: "heartFilled"), for: .normal)
        }else{
            favButton.setImage(#imageLiteral(resourceName: "heartEmpty"), for: .normal)
        }
        favButton.setNeedsDisplay()
        self.backgroundColor = .cyan
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

protocol ParentOfPlaylistCell:class {
    func optionAction(song:SongEntity)
}
