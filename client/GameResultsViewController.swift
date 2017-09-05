//
//  GameResultsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class GameResultsViewController: UIViewController {
    
    var logicLoseGame : AVAudioPlayer?
    var logicWinGame : AVAudioPlayer?

    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false
    }
    
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var winningPlayerLabel: UILabel!
    @IBOutlet var tagCountLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let logicLoseGame = self.setupAudioPlayerWithFile("logicLoseGame", type:"mp3") {
            self.logicLoseGame = logicLoseGame
        }
        self.logicLoseGame?.volume = 0.7
        if let logicWinGame = self.setupAudioPlayerWithFile("logicWinGame", type:"mp3") {
            self.logicWinGame = logicWinGame
        }
        self.logicWinGame?.volume = 0.7
        
        self.updateBackgroundColor(isOffense: globalIsOffense)
        
        if gameWinner == "defense" {
            if globalIsOffense == true {
                self.winnerLabel.text = "defense wins :("
            }
            else {
               self.winnerLabel.text = "defense wins!!!"
            }
            self.tagCountLabel.isHidden = true
            if globalIsOffense == true {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicLoseGame?.play()
            }
            if globalIsOffense == false {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicWinGame?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            if playerTagCount == 0 {
                self.winningPlayerLabel.text = "You got 0 tags"
            }
            else if playerTagCount == 1 {
                self.winningPlayerLabel.text = "You got 1 tag"
            }
            else {
                self.winningPlayerLabel.text = "You got \(String(playerTagCount)) tags"
            }
        } else {
            if globalIsOffense == true {
                self.winnerLabel.text = "offense wins!!!"
                self.winningPlayerLabel.text = "\(gameWinner) won it!!"
            }
            else {
                self.winnerLabel.text = "offense wins :("
                self.winningPlayerLabel.text = "\(gameWinner) won it!!"
            }
            
            if globalIsOffense == true {
                self.logicWinGame?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
            }
            if globalIsOffense == false {
                self.logicLoseGame?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            if playerTagCount == 0 {
                self.tagCountLabel.text = "You got 0 tags"
            }
            else if playerTagCount == 1 {
                self.tagCountLabel.text = "You got 1 tag"
            }
            else {
                self.tagCountLabel.text = "You got \(String(playerTagCount)) tags"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
