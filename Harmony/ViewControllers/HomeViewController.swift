//
//  ViewController.swift
//  xxx
//
//  Created by Dharay Mistry on 11/28/17.
//  Copyright © 2017 Dharay Mistry. All rights reserved.
//

import UIKit
import MediaPlayer

let playViewPeekHeight: CGFloat = 80

class HomeViewController: UIViewController {

    var homeVC = UIViewController()
    var settingsVC = UIViewController()
    var onlineVC = UIViewController()
	
    
    @IBOutlet weak var baseViewHeight: NSLayoutConstraint!
	@IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pView: BmoViewPager!
    @IBOutlet weak var pageControlDots: UIPageControl!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var playView: UIView!
	@IBOutlet weak var baseViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playLabel: UILabel!
    
	var playBannerLastDragSpeed:CGFloat = 0
    let baseUpConstant:CGFloat = -playViewPeekHeight - statusBarHeight
    let baseDownConstant:CGFloat = -uiHeight + playViewPeekHeight + statusBarHeight
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		baseViewHeight.constant = uiHeight + playViewPeekHeight
        homeViewBottomConstraint.constant = playViewPeekHeight
		
        pView.dataSource = self
        pView.delegate = self
        pView.presentedPageIndex = 0
        homeVC = (self.storyboard?.instantiateViewController(withIdentifier: "Home"))!
        settingsVC = (self.storyboard?.instantiateViewController(withIdentifier: "settings"))!
        onlineVC = (self.storyboard?.instantiateViewController(withIdentifier: "online"))!
        pageControlDots.isUserInteractionEnabled = false
        managePageControlDots(page: 0)
		
		playView.frame = CGRect(origin: CGPoint(x: 0, y: baseView.frame.height), size: self.view.frame.size)
		baseView.clipsToBounds = true
		baseViewYConstraint.constant = baseDownConstant
        
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseViewYConstraint.constant = baseView.frame.minY > 0 ? baseDownConstant : -baseUpConstant
        self.currentSongChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        baseViewYConstraint.constant = baseView.frame.minY > 0 ? baseDownConstant : -baseUpConstant
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
        baseViewYConstraint.constant = baseView.frame.minY > 0 ? baseDownConstant : -baseUpConstant
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homeVCGlobal = self
        ThemeManager.register(vc: self)
        self.setTheme()
    }
    
    @IBAction func topRightButtonAction(_ sender: UIButton) {
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
    
    @IBAction func tapped(_ sender: UIPanGestureRecognizer) {
        
     
        sender.view?.center = CGPoint(x: (sender.view?.center.x)!, y: (sender.view?.center.y)! + sender.translation(in: sender.view).y)
		
        sender.setTranslation(CGPoint.zero, in: self.view)
	
		playBannerLastDragSpeed = sender.velocity(in: sender.view).y
        
        //print(playBannerLastDragSpeed)
        if sender.state == .ended{
			if playBannerLastDragSpeed < 100 && playBannerLastDragSpeed > -100{// dragged slowly
				UIView.animate(withDuration: 1 , animations: {
					if (sender.view?.frame.midY)! < self.view.frame.maxY*12/10{
						let tempFrame = sender.view?.frame
						sender.view?.frame = CGRect(x: (tempFrame?.minX)!, y: -(playViewPeekHeight), width: (tempFrame?.width)!, height: (tempFrame?.height)!)
					}else{
						let tempFrame = sender.view?.frame
						sender.view?.frame = CGRect(x: (tempFrame?.minX)!, y: self.view.frame.height-(playViewPeekHeight), width: (tempFrame?.width)!, height: (tempFrame?.height)!)
					}
                })
                
				
			}else{// dragged with speed
				if playBannerLastDragSpeed > 0{
					UIView.animate(withDuration: TimeInterval((self.view.frame.height-(sender.view?.frame.midY)!)/playBannerLastDragSpeed), animations: { //  time=dist/speed
						let tempFrame = sender.view?.frame
						sender.view?.frame = CGRect(x: (tempFrame?.minX)!, y: self.view.frame.height-playViewPeekHeight, width: (tempFrame?.width)!, height: (tempFrame?.height)!)
                    })
					
				}else{
					UIView.animate(withDuration: TimeInterval((self.view.frame.height-(sender.view?.frame.midY)!)/playBannerLastDragSpeed), animations: { //  time=dist/speed
						let tempFrame = sender.view?.frame
						sender.view?.frame = CGRect(x: (tempFrame?.minX)!, y: -(playViewPeekHeight), width: (tempFrame?.width)!, height: (tempFrame?.height)!)
					})
                    
					
				}
			}
            
		}
        
    }
    
    func managePageControlDots(page:Int){
        pageControlDots.alpha = 1
        pageControlDots.currentPage = page
        UIView.animate(withDuration: 1) {
            self.pageControlDots.alpha = 0
        }
    }
    func currentSongChanged(){
       playLabel.text = player.nowPlayingItem?.title ?? ""
        
    }
    
    
    @IBAction func playOnBase(_ sender: UIButton) {
        if player.playbackState == .playing{
            player.pause()
        }else{
            player.play()
        }
    }
    @IBAction func previousOnBase(_ sender: UIButton) {
        if player.currentPlaybackTime < 5{
            player.skipToPreviousItem()
        }else{
            player.skipToBeginning()
        }
    }
    @IBAction func nextOnBase(_ sender: UIButton) {
        player.skipToNextItem()
    }
}


extension HomeViewController:BmoViewPagerDataSource,BmoViewPagerDelegate,ThemeAdapatable{
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        return 2
    }
    
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        
		switch page {
		case 0:
			return homeVC
		case 1:
			return settingsVC
		case 2:
			return onlineVC
		default:
			return homeVC
		}
		
        
    }

    func bmoViewPagerDelegate(_ viewPager: BmoViewPager, didAppear viewController: UIViewController, page: Int) {
      //  managePageControlDots(page: page)
    }
    func setTheme() {
        self.mainView.backgroundColor = currentTheme.c3
        self.topView.backgroundColor = currentTheme.c2
        self.baseView.backgroundColor = currentTheme.c2
    }
    
}

