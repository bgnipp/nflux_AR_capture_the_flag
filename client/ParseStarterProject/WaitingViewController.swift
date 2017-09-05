//
//  WaitingViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class WaitingViewController: UIViewController {

    var logicSFX5 : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    var entersound : AVAudioPlayer?
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    var soundURL: URL?
    var soundID:SystemSoundID = 0
    
    var localPlayerPosition = ""
    var allPlayersJoined = false
    
    var countdownTimer = Timer()
    var countdownTimerCount: Int = -1
    var refreshTimer = Timer()
    var refreshTimerCount: Int = 2
    
    var startTime = 99

    func refreshTimerUpdate() {
        if refreshTimerCount > 0 {
            refreshTimerCount -= 1
        }
        if refreshTimerCount == 0 {
            refreshTimerCount = 2
            SocketIOManager.sharedInstance.getDidGameStart(gameID: globalGameID)
        }
    }
    
    func countdownTimerUpdate() {
        if countdownTimerCount == 3 {
            self.headerLabel.text = "game starting in..."
            self.cancelButtonOutlet.isHidden = true
            self.timerLabel.isHidden = false
        }
        if countdownTimerCount == 0 {
            self.countdownTimer.invalidate()
            self.performSegue(withIdentifier: "showGameViewController", sender: nil)
            self.countdownTimerCount = -1
        }
        if countdownTimerCount > 0 {
            timerLabel.text = String(describing: countdownTimerCount)
            countdownTimerCount -= 1
        }
    }
    
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer?  {
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = URL(fileURLWithPath: path!)
        var audioPlayer:AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    func startGame(gameStartTime: Int) {
        SocketIOManager.sharedInstance.stopListeningForGameStart()
        self.refreshTimer.invalidate()
        globalGameStartTime = gameStartTime
        let currentTime = Int(NSDate().timeIntervalSince1970)
        var secsUntilStart = currentTime - gameStartTime
        if secsUntilStart < 1 {
            secsUntilStart = 1
        }
        self.countdownTimerCount = secsUntilStart + 3
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(WaitingViewController.countdownTimerUpdate), userInfo: nil, repeats: true)
        self.countdownTimer.tolerance = 0.1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SocketIOManager.sharedInstance.listenForGameStart(gameID: globalGameID, completionHandler: { (gameStartTime) -> Void in
            if gameStartTime != -1 {
                self.startGame(gameStartTime: gameStartTime)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let logicSFX5 = self.setupAudioPlayerWithFile("logicSFX5", type:"mp3") {
            self.logicSFX5 = logicSFX5
        }
        self.logicSFX5?.volume = 0.7
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        self.entersound?.volume = 0.6
        self.updateBackgroundColor(isOffense: globalIsOffense)
        self.logicSFX5?.play()
        self.refreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(WaitingViewController.refreshTimerUpdate), userInfo: nil, repeats: true)
        self.refreshTimer.tolerance = 0.1
    }

    @IBOutlet var cancelButtonOutlet: UIButton!
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.backsound?.play()
        let refreshAlert = UIAlertController(title: "Exit", message: "Are you sure?  This will cancel the game for all players", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.entersound?.play()
            self.refreshTimer.invalidate()
            self.countdownTimer.invalidate()
            self.performSegue(withIdentifier: "showPairViewControllerFromWaitingViewController", sender: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func cancel(_ canceller: String) {
        self.backsound?.play()
        let refreshAlert = UIAlertController(title: "Game cancelled", message: "\(canceller) exited", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.entersound?.play()
            self.refreshTimer.invalidate()
            self.countdownTimer.invalidate()
            self.performSegue(withIdentifier: "showPairViewControllerFromWaitingViewController", sender: nil)
        }))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
