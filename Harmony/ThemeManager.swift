//
//  ThemeManager.swift
//  Harmony
//
//  Created by Dharay Mistry on 10/04/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import Foundation
import UIKit

class ThemeManager{
    
    static var vcs:[ThemeAdapatable] = []
    
    static func setTheme(themeID:String){
       // let theme = themeArray.first(where: {$0.id == themeID})
        UserDefaults.standard.set(themeID, forKey: "theme")
        currentTheme = getThemeFromString(UserDefaults.standard.string(forKey: "theme")!)
        for i in vcs{
            i.setTheme()
        }
    }
    
    static func register(vc:ThemeAdapatable){
      
        vcs.append(vc)
        
    }
    
    static func setup(){
        // cool,warm,dark,light
        if UserDefaults.standard.string(forKey: "theme") == nil{
            UserDefaults.standard.set("cool", forKey: "theme")
        }
        let light = Theme(
            c1: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1),
            c2: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1),
            c3: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            textColour: .white, id: "light")
        let dark = Theme(
            c1: UIColor(red: 0.0, green: 0, blue: 0, alpha: 1),
            c2: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1),
            c3: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),
            textColour: .black, id: "dark")
        let cool = Theme(
            c1: UIColor(red: 0.0, green: 0, blue: 0.6, alpha: 1),
            c2: UIColor(red: 0.1, green: 0.1, blue: 0.7, alpha: 1),
            c3: UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1),
            textColour: .black, id: "cool")
        let warm = Theme(
            c1: UIColor(red: 0.8, green: 0.8, blue: 0, alpha: 1),
            c2: UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1),
            c3: UIColor(red: 1, green: 0.0, blue: 0, alpha: 1),
            textColour: .black, id: "warm")
        themeArray = [cool,warm,light,dark]
        currentTheme = getThemeFromString(UserDefaults.standard.string(forKey: "theme")! )
        
    }
    
    static func getThemeFromString(_ str:String) -> Theme{
        return themeArray.first(where: {$0.id == str})!
    }
}

class Theme {
    var c1:UIColor,c2:UIColor,c3:UIColor,textColour:UIColor,id :String
    init(c1:UIColor,c2:UIColor,c3:UIColor,textColour:UIColor,id :String) {
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.textColour = textColour
        self.id = id
        
    }
}

protocol ThemeAdapatable{
    func setTheme() -> Void
}
