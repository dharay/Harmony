//
//  Constants.swift
//  xxx
//
//  Created by Dharay Mistry on 2/12/18.
//  Copyright © 2018 Dharay Mistry. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

var homeVCGlobal: HomeViewController! = nil
var playVCGlobal: PlayViewController! = nil

let uiHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.width :UIScreen.main.bounds.height
let uiWidth = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width :UIScreen.main.bounds.height
let statusBarHeight = UIApplication.shared.statusBarFrame.height

var uiCurrentWidth = UIScreen.main.bounds.width
var uiCurrentHeight = UIScreen.main.bounds.height

var playViewIsVisible = false
var artistsFlag = true

var animationTransitionDuration = 0.3

var currentQueue: [MPMediaItem] = []
var allQueue: [MPMediaItem] = []
var showQueue: [MPMediaItem] = []
var mostPlayedQueue: [[Any]] = []
var themeArray:[Theme] = []
var currentTheme: Theme!

var player = MPMusicPlayerController.applicationQueuePlayer

var songReqFlag = true //true if approved

var storedSongs: [SongEntity] = []
var storedPlaylists: [PlaylistEntity] = []
