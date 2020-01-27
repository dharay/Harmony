//
//  InitialLoadingViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 29/07/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import MediaPlayer
import Foundation

class InitialLoadingViewController: UIViewController {
    
    @IBOutlet weak var titleView: UIView!
    var iTunesAccessFlag = false
    var songsCountFlag = false
    var charLayers = [CAShapeLayer]()
    var isAnimationComplete = false
    var characterAnimationDuration:Double = 0.4
    

    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadIndicator.isHidden = false
        self.animateTitle()
        loadIndicator.startAnimating()
        loadIndicator.hidesWhenStopped = true
        onUserInitiatedQ {
            
            self.recursiveCheckiTunesAccess()
            self.recursiveCheckSongsCount()
            
            CoreDataManager.fetchPlaylists()
            CoreDataManager.fetchSongs()
            CoreDataManager.setUpMostPlayedItems()
            ThemeManager.setup()
            
            PlayManager.handleAppBecameForeGround()
            
            
        }
        self.flagWaiter()
    }

    @objc func flagWaiter(){
        if !songsCountFlag || !iTunesAccessFlag || storedSongs.count != allQueue.count || !isAnimationComplete{
            self.perform(#selector(flagWaiter), with: nil, afterDelay: 1)
        }else{
            let toShow = self.storyboard?.instantiateViewController(withIdentifier: "base")
            onMainQ {
                self.loadIndicator.stopAnimating()
            }
            self.present(toShow!, animated: true, completion: nil)
        }
        
        //stop load indicator
        if !songsCountFlag || !iTunesAccessFlag || storedSongs.count != allQueue.count {}
        else{self.loadIndicator.stopAnimating()}
    }
    @objc func recursiveCheckiTunesAccess(){
        guard PlayManager.checkiTunesAccess() else {

            let alert = UIAlertController(title: "iTunes Access", message: "please allow access to your library", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                //UIApplicationOpenSettingsURLString
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.perform(#selector(recursiveCheckiTunesAccess), with: nil, afterDelay: 2)
            return
        }
        iTunesAccessFlag = true
    }
    
    @objc func recursiveCheckSongsCount(){
        guard PlayManager.iTunesSongsSync() else {
            self.perform(#selector(recursiveCheckSongsCount), with: nil, afterDelay: 2)
            let alert = UIAlertController(title: "No Music Found", message: "please add music to your iTunes library to continue", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
                return
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        songsCountFlag = true
    }
}

//MARK: Animate Harmony
extension InitialLoadingViewController {

    func animateTitle() {
     
        for layer in self.charLayers {
            layer.removeFromSuperlayer()
            print("layer removed")
        }
        
        let font = CGFloat(70)
        
        let stringAttributes = [ NSAttributedString.Key.font: UIFont(name: "SignPainter-HouseScript", size: font)! ]
        let attributedString = NSMutableAttributedString(string: "Harmony", attributes: stringAttributes )
        print(attributedString.size().width)
        titleView.frame.size = attributedString.size()
        titleView.center = self.view.center
 
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(4), range: NSRange(location: 1, length: 6))
        
        let charPaths = self.characterPaths(attributedString: attributedString, position: CGPoint(x: 0, y: 0))
        
        self.charLayers = charPaths.map { path -> CAShapeLayer in
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 2
            shapeLayer.path = path
            return shapeLayer
        }
        self.recursiveAnimate(layers: self.charLayers)
        
        titleView.setNeedsLayout()
        titleView.setNeedsDisplay()
    }
    
    func characterPaths(attributedString: NSAttributedString, position: CGPoint) -> [CGPath] {
        
        let line = CTLineCreateWithAttributedString(attributedString)
        
        guard let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun] else { return []}
        
        var characterPaths = [CGPath]()
        
        for glyphRun in glyphRuns {
            guard let attributes = CTRunGetAttributes(glyphRun) as? [String:AnyObject] else { continue }
            let font = attributes[kCTFontAttributeName as String] as! CTFont
            
            for index in 0..<CTRunGetGlyphCount(glyphRun) {
                let glyphRange = CFRangeMake(index, 1)
                
                var glyph = CGGlyph()
                CTRunGetGlyphs(glyphRun, glyphRange, &glyph)
                
                var characterPosition = CGPoint()
                CTRunGetPositions(glyphRun, glyphRange, &characterPosition)
                characterPosition.x += position.x
                characterPosition.y += position.y
                
                if let glyphPath = CTFontCreatePathForGlyph(font, glyph, nil) {
                    var transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: characterPosition.x, ty: characterPosition.y)
                    if let charPath = glyphPath.copy(using: &transform) {
                        characterPaths.append(charPath)
                    }
                }
            }
        }
        return characterPaths
    }

    func recursiveAnimate(index:Int = 0, layers:[CAShapeLayer]){

        if index == layers.count{
            self.isAnimationComplete = true
            return
        }
        let layer = layers[index]
        titleView.layer.addSublayer(layer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = characterAnimationDuration
        layer.add(animation, forKey: "charAnimation")
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + characterAnimationDuration) {
            DispatchQueue.main.async {
                self.recursiveAnimate(index: index + 1, layers: self.charLayers)
            }
        }
    }
    
    
}
