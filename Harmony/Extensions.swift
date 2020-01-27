//
//  Extension.swift
//  Harmony
//
//  Created by Dharay Mistry on 23/04/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import Foundation

extension Int{
    func toTime() -> String {
        if self < 3600 {
            return "\(String(format: "%.2d",(self % 3600) / 60)):\((String(format: "%.2d",(self % 3600) % 60)))"
        }else{
            return "\(self/3600):\(String(format: "%.2d",(self % 3600) / 60)):\((String(format: "%.2d",(self % 3600) % 60)))"
        }
    }
}

func waitFor<T>(item:T?, andPass:@escaping () -> Void){
    let waitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
        if item == nil {
            waitFor(item: item, andPass: andPass)
        }else{
            andPass()
        }
        
    }
    waitTimer.fire()
}

func searchStringToHTTpQuery (string: String) -> String {
    

    return  ""
}
func onMainQ(code:@escaping ()->()) {
    DispatchQueue.main.async {
        code()
    }
}
func onUserInitiatedQ(code:@escaping ()->()) {
    DispatchQueue.global(qos: .userInitiated).async {
        code()
    }
}



