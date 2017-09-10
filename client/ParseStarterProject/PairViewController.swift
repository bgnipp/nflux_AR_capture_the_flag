//
//  PairViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation
import CoreBluetooth

class PairViewController: UIViewController, UITextFieldDelegate {
    
    let PURP = UIColor(
        red:0.216,
        green:0.251,
        blue:0.812,
        alpha:1.0
    )
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false }
    
    var userDict = [String: [String : Any]]()
    
    @IBOutlet var gameNameLabel: UILabel!
    @IBOutlet var beginButtonLabel: UIButton!
    @IBOutlet var switchTeamsButtonLabel: UIButton!
    
    //0 = game not being created, 1 = game being created, 2 = game ready to join, 3 = game started
    var beginButtonState: Int = 0
    
    @IBOutlet var offense1: UILabel!
    @IBOutlet var offense2: UILabel!
    @IBOutlet var offense3: UILabel!
    @IBOutlet var offense4: UILabel!
    @IBOutlet var offense5: UILabel!
    
    @IBOutlet var defense1: UILabel!
    @IBOutlet var defense2: UILabel!
    @IBOutlet var defense3: UILabel!
    @IBOutlet var defense4: UILabel!
    @IBOutlet var defense5: UILabel!
    
    @IBOutlet var beingCreatedHelpOutlet: UIButton!
    @IBOutlet var startGameHelpOutlet: UIButton!
    
    //refresh timer
    var refreshTimer = Timer()
    var refreshTimerCount: Int = 4
    
    var entersoundlow : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SocketIOManager.sharedInstance.listenForWaitingUserUpdates(gameID: globalGameID, completionHandler: { (userDict, gameState) -> Void in
            self.populatePlayerLabels(userDict: userDict)
            self.userDict = userDict
            self.updateBeginButtonState(gameState: gameState)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        //self.beginButtonLabel.isEnabled = false
        
        self.updateBackgroundColor(isOffense: globalIsOffense)
        self.refreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PairViewController.refreshTimerUpdate), userInfo: nil, repeats: true)
        self.refreshTimer.tolerance = 0.3
        
        _ = self.checkIsConnected()
    }
    
    
//refresh timer
    func refreshTimerUpdate() {
        if(refreshTimerCount > 0)
        {
            refreshTimerCount -= 1
        }
        if(refreshTimerCount == 0)
        {
            refreshTimerCount = 4
            SocketIOManager.sharedInstance.getWaitingUserUpdates(gameID: globalGameID)
        }
    }
    
    @IBAction func beginButton(_ sender: AnyObject) {
        
        if checkIsConnected() == false {
            print("not connected")
        }
        
    //"Join" button
        else if self.beginButtonState == 2 {
            SocketIOManager.sharedInstance.joinGame(gameID: globalGameID, udid: UDID, completionHandler: { (canJoin) -> Void in
                if canJoin {
                    SocketIOManager.sharedInstance.getGameConfig(gameID: globalGameID, completionHandler: { (gameConfig, playerConfig) -> Void in
                        print("updateing game and player config")
                        self.loadGame(gameConfig: gameConfig, playerConfig: playerConfig)
                        self.refreshTimer.invalidate()
                        self.entersoundlow?.play()
                        self.performSegue(withIdentifier: "showWaitingViewControllerFromPair", sender: nil)
                    })
                } else {
                    self.displayAlert("Couldn't join game", message: "Either your network failed or some other shit happened. Please try again.")
                }
            })
        }
        
    //"Create Game" Button
        else if self.beginButtonState == 0 {
            var alert_title = ""
            var alert_message = ""
            if self.userDict.count == 1 {
                alert_title = "Are you sure?"
                alert_message = "Create a game with only one player?  Other players will not be able to join.  However, creating a game with only one player may be useful for learning how the game works."
            } else {
                alert_title = "Confirm"
                alert_message = "Create a game with \(self.userDict.count) players? Additional players will not be able to join after this point"
            }
            let refreshAlert = UIAlertController(title: alert_title, message: alert_message, preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                SocketIOManager.sharedInstance.createGame(gameID: globalGameID, udid: UDID, completionHandler: { (canCreate) -> Void in
                    if canCreate {
                        self.refreshTimer.invalidate()
                        self.entersoundlow?.play()
                        self.performSegue(withIdentifier: "showGameOptionsViewController", sender: self)
                    } else {
                        self.displayAlert("Couldn't create game", message: "Either your network failed or some other shit happened. Please try again.")
                    }
                })
            }))
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            }))
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func updateBeginButtonState(gameState: Int) {
        switch gameState {
            case 1: do {
                    self.beginButtonState = 1
                    self.beginButtonLabel.isEnabled = false
                    self.beginButtonLabel.setTitleColor(UIColor.black, for: UIControlState())
                    self.beginButtonLabel.setTitle("game being created...", for: UIControlState())
                    self.switchTeamsButtonLabel.isEnabled = false
                    self.switchTeamsButtonLabel.setTitleColor(UIColor.black, for: UIControlState())
            }
            case 2: do {
                    self.beginButtonState = 2
                    self.beginButtonLabel.setTitle("join game", for: UIControlState())
                    self.beginButtonLabel.setTitleColor(PURP, for: UIControlState())
                    self.beginButtonLabel.isEnabled = true
                    self.switchTeamsButtonLabel.isEnabled = false
                    self.switchTeamsButtonLabel.setTitleColor(UIColor.black, for: UIControlState())
            }
            default: do {
                    self.beginButtonState = 0
                    self.beginButtonLabel.setTitleColor(PURP, for: UIControlState())
                    self.beginButtonLabel.setTitle("start game", for: UIControlState())
                    self.beginButtonLabel.isEnabled = true
                    self.switchTeamsButtonLabel.setTitleColor(PURP, for: UIControlState())
                    self.switchTeamsButtonLabel.isEnabled = true
            }
        }
    }

    @IBAction func cancelButton(_ sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Exit waiting screen", message: "Are you sure?  You will not be able to participate in the current game", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.refreshTimer.invalidate()
            self.backsound?.play()
            SocketIOManager.sharedInstance.leaveQueuedGame(gameID: globalGameID)
            self.performSegue(withIdentifier: "showViewControllerFromPairViewController", sender: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func switchTeamsButton(_ sender: AnyObject) {
        if checkIsConnected() {
            SocketIOManager.sharedInstance.switchTeams(gameID: globalGameID, udid: UDID, completionHandler: { (success: Bool) -> Void in
                print("SUCCESS: ", success)
                if success {
                    globalIsOffense = !globalIsOffense
                    self.updateBackgroundColor(isOffense: globalIsOffense)
                } else {
                    self.notifyNetworkFailure()
                }
            })
        }
    }
    
    func populatePlayerLabels(userDict: [String: [String : Any]]) {
        
        var offensePlayersPopulated = 0
        var defensePlayersPopulated = 0
        for (_, player) in userDict {
            let username = player["user_name"] as! String
            let isOffense = player["is_offense"] as! Bool
            if isOffense {
                switch offensePlayersPopulated {
                    case 0: self.offense1.text = username
                    case 1: self.offense2.text = username
                    case 2: self.offense3.text = username
                    case 3: self.offense4.text = username
                    default: self.offense5.text = username
                }
                offensePlayersPopulated += 1
            } else {
                switch defensePlayersPopulated {
                    case 0: self.defense1.text = username
                    case 1: self.defense2.text = username
                    case 2: self.defense3.text = username
                    case 3: self.defense4.text = username
                    default: self.defense5.text = username
                }
                defensePlayersPopulated += 1
            }
        }
        while offensePlayersPopulated < 5 {
            switch offensePlayersPopulated {
                case 0: self.offense1.text = "..."
                case 1: self.offense2.text = "..."
                case 2: self.offense3.text = "..."
                case 3: self.offense4.text = "..."
                default: self.offense5.text = "..."
            }
            offensePlayersPopulated += 1
        }
        while defensePlayersPopulated < 5 {
            switch defensePlayersPopulated {
            case 0: self.defense1.text = "..."
            case 1: self.defense2.text = "..."
            case 2: self.defense3.text = "..."
            case 3: self.defense4.text = "..."
            default: self.defense5.text = "..."
            }
            defensePlayersPopulated += 1
        }
    }
    
    
    @IBAction func offenseHelpButton(_ sender: AnyObject) {
        self.displayAlert("Offense team", message: "The offense team tries to sneak past defensive players to capture the flag and return with it to their base before time runs out.  If tagged by a defender, offense players must return to their base before continuing.")
    }
    
    @IBAction func defenseHelpButton(_ sender: AnyObject) {
        self.displayAlert("Defense team", message: "The defense team tags offense players (forcing them to return to their base) to prevent them from capturing the flag.  Defense wins when time runs out and the flag has not been captured.")
    }
    
    @IBAction func startGameHelpButton(_ sender: AnyObject) {
        if self.beginButtonState == 0 {
        self.displayAlert("Start game", message: "When all players have joined, one player presses the create game button and sets up the game.  When the game is set up, all other players will be given the option to join.")
        }
        else if self.beginButtonState == 1 {self.displayAlert("Game being created", message: "Please wait, the game is being set up.  You will be given the option to join the game when it's ready.")
        }
        else if self.beginButtonState == 2 {
            self.displayAlert("Join game", message: "When you are ready to start the game, press this button.  The game begins when all players have joined.")
        }
    }
    
//    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        if peripheral.state == CBPeripheralManagerState.PoweredOn {
//            print("Broadcasting...")
//            bluetoothOn = true
//        } else if peripheral.state == CBPeripheralManagerState.PoweredOff || peripheral.state == CBPeripheralManagerState.Unsupported || peripheral.state == CBPeripheralManagerState.Unauthorized {
//            print("Stopped")
//            bluetoothOn = false
//        }
//    }
    
}
