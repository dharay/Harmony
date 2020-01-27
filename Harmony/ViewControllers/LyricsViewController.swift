//
//  LyricsViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 03/04/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import WebKit
import MediaPlayer
import AVFoundation

class LyricsViewController: UIViewController,WKNavigationDelegate{
    @IBOutlet weak var urlSavedLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noInternetLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var webLoadingFlag = false
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlSavedLabel.isHidden = true
        webView.navigationDelegate = self
        noInternetLabel.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }
    @IBAction func googleSearchAction(_ sender: Any) {
        searchAction(type: .google)
    }
    @IBAction func geniusSearchAction(_ sender: Any) {
        searchAction(type: .genius)
    }
    @IBAction func metroSearchAction(_ sender: Any) {
        searchAction(type: .metro)
    }
    
    @IBAction func saveUrlAction(_ sender: Any) {
        let songOpt = player.nowPlayingItem
        
        guard songOpt != nil else {
            return
        }
        CoreDataManager.setLyricsUrl(title: (player.nowPlayingItem?.title)!, artist: player.nowPlayingItem?.artist, lyricsUrl: (webView.url?.absoluteString) ?? "https://www.google.com")
        urlSavedAnimation()
    }
    
    func searchAction (type: SearchActionType){
        
        var urlString = ""
        switch type {
        case .genius:
            urlString = "https://genius.com/search?q=" + (player.nowPlayingItem?.title ?? "")!
            urlString = urlString.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        case .google:
            urlString = "https://www.google.com/search?q="+(player.nowPlayingItem?.title ?? "")! + "+lyrics"
            urlString = urlString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        case .metro:
            urlString = "https://search.azlyrics.com/search.php?q="+(player.nowPlayingItem?.title ?? "")!
            urlString = urlString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        }
        
        
        print(urlString)
        let urlReq = URLRequest(url: URL(string:urlString) ?? URL(string: "https://www.google.com/")!)
        self.webView.load(urlReq)
        startLoad()
    }
    func startLoadForSong(){
        print("swiped to lyrics")
        
        let songOpt = player.nowPlayingItem
        
        guard songOpt != nil else {
            return
        }
        let song = songOpt!
        if !songReqFlag {
            return
        }
        let songEntity = CoreDataManager.fetchStoredSong(title: song.title!, artist: song.artist)
        if songEntity.lyrics != ""{
            if webView.url == URL(string:songEntity.lyrics!) {
                return
            }
            let urlReq = URLRequest(url: URL(string:songEntity.lyrics!)!)
            self.webView.load(urlReq)
            startLoad()
        }else{
            var urlString = "https://www.google.com/search?q="+(player.nowPlayingItem?.title ?? "")! + "+lyrics"
            
            urlString = urlString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            urlString = urlString.replacingOccurrences(of: "{", with: "%7B", options: .literal, range: nil)
            urlString = urlString.replacingOccurrences(of: "}", with: "%7D", options: .literal, range: nil)
            if webView.url == URL(string:urlString) {
                return
            }
            let urlReq = URLRequest(url: URL(string:urlString) ?? URL(string:"https://www.google.com/")!)
            self.webView.load(urlReq)
            startLoad()
        }
    }
    func startLoad(){
        
        
        activityIndicator.startAnimating()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if self.webView.isLoading{
//                self.startLoad()
//            }else{
//                self.activityIndicator.stopAnimating()
//            }
//        }
    }
    @IBAction func openInSafariAction(_ sender: UIButton) {
        UIApplication.shared.open(webView.url ?? URL(string: "https://www.google.com/")!, options: [:], completionHandler: { (status) in})
    }
    @IBAction func playPauseAction(_ sender: UIButton) {
        if player.playbackState == .playing{
            player.pause()
        }else if player.playbackState == .paused || player.playbackState == .stopped{
            player.play()
            
        }else{
            print("fuck play")
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        noInternetLabel.isHidden = true
        self.activityIndicator.stopAnimating()
        webView.evaluateJavaScript("document.documentElement.outerHTML", completionHandler: { (doce, err) in
            print(doce)
        })

    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        noInternetLabel.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        noInternetLabel.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    func urlSavedAnimation(){
        urlSavedLabel.isHidden = false
        urlSavedLabel.alpha = 1
        UIView.animate(withDuration: 2) {
            self.urlSavedLabel.alpha = 0
        }
    }
}
enum SearchActionType {
    case google
    case metro
    case genius
}
