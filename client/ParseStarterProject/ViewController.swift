//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import AVFoundation
import SocketIO

let UDID = UIDevice.current.identifierForVendor!.uuidString

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var peripheralManager: CBPeripheralManager!
    var locationManager = CLLocationManager()
    var entersound : AVAudioPlayer?
    
//    #if (arch(i386) || arch(x86_64))
//        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//    #endif
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    @IBOutlet var userName: UITextField!
    @IBOutlet var offenseTrueSwitch: UISwitch!
    @IBOutlet var nstructionsOutlet: UIButton!
    
    @IBAction func letsPlay(_ sender: AnyObject) {
        
        if checkIsConnected() == false {
            print("not connected")
        }
        else if userName.text == "" {
            displayAlert("Missing Field(s)", message: "You must enter your name or a nickname.")
        }
            //note - must add 12 to desired limit (to account for optional("")  )
        else if String(describing: userName.text).characters.count > 24 {
            displayAlert("Name too long", message: "Please limit your name to 12 characters, sorry!")
        }
        else {
            currentLocation = locManager.location
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            globalUserName = userName.text!
            globalIsOffense = offenseTrueSwitch.isOn
            SocketIOManager.sharedInstance.socket.emitWithAck("enterQueue", globalUserName, globalIsOffense, UDID, lat, long).timingOut(after: 3) {game in
                print("JOINiNG OBJ: ", game)
                if game[0] as! String == "rejoining" {
                    globalGameID = game[1] as! String
                    globalIsRejoining = true
                    let gameConfig = game[2] as! [String: Any]
                    let playerConfig = game[3] as! [String: [String: Any] ]
                    self.loadGame(gameConfig: gameConfig, playerConfig: playerConfig)
                    gameTimerCount = game[4] as! Int
                    self.entersound?.play()
                    self.performSegue(withIdentifier: "showGameViewControllerFromView", sender: nil)
                }
                else if game[0] as! String == "not_rejoining" {
                    globalGameID = game[1] as! String
                    self.entersound?.play()
                    self.performSegue(withIdentifier: "login", sender:self)
                }
                else {
                    self.displayAlert("Couldn't Connect", message: "Please check your network connection and try again.")
                }
            }
        }

    }
    @IBOutlet var defenseOutlet: UILabel!
    @IBOutlet var letsPlayOutlet: UIButton!
    @IBOutlet var offenseOutlet: UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketIOManager.sharedInstance.socket.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        resetGlobalSetupVars()
        
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.updateBackgroundColor(isOffense: globalIsOffense)
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)

        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        
        offenseTrueSwitch.isOn = globalIsOffense
        self.offenseTrueSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.offenseTrueSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.offenseTrueSwitch.layer.cornerRadius = 16.0
        
        //hide keyboard when tap on background
        self.userName.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //check for internet connection
        _ = checkIsConnected()
        
        globalPlayerNamesDict["offense1"] = ""
        globalPlayerNamesDict["offense2"] = ""
        globalPlayerNamesDict["offense3"] = ""
        globalPlayerNamesDict["offense4"] = ""
        globalPlayerNamesDict["offense5"] = ""
        globalPlayerNamesDict["defense1"] = ""
        globalPlayerNamesDict["defense2"] = ""
        globalPlayerNamesDict["defense3"] = ""
        globalPlayerNamesDict["defense4"] = ""
        globalPlayerNamesDict["defense5"] = ""
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didSwitch(_ sender: AnyObject) {
        globalIsOffense = !globalIsOffense
        self.updateBackgroundColor(isOffense: globalIsOffense)
    }
    
    @IBAction func button(_ sender: AnyObject) {
        let url = URL(string: "https://twitter.com/2080ar")
        UIApplication.shared.openURL(url!)
    }
    
    
    @IBAction func nStructionsButton(_ sender: AnyObject) {
        globalIsOffense = offenseTrueSwitch.isOn
        self.performSegue(withIdentifier: "showInstructionsViewControllerFromViewController", sender:self)
    }
}
