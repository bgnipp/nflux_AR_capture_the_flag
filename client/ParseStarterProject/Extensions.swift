//
//  ConnectionFunctions.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 7/20/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

//dev stuff
var globalTestModeEnabled = false
var devMode = true
var testViewHidden = true
var testAnnType = ""
var testAnnCaption = ""

//game setup globals
var globalUserName = ""
var globalIsOffense = true
var globalGameID = ""
var bluetoothOn = false
var globalPlayerNamesDict = [String: String]()
var globalIsRejoining = false

//game option globals 
var tagPickerSelect = "normal"
var timePickerSelect = "15:00"
var globalCaptureTime = 10
var globalItemsOn = true
var globalGameLength = 0
var globalTagThreshold = 0

//item option globals
var itemPricesOffense = [2,7,5,10,7,12,5,8,7,15,7,15]
var itemPricesDefense = [2,7,5,10,7,12,5,8,8,10,12,20]
var itemsDisabledOffense = [false,false,false,false,false,false,false,false,false,false,false,false]
var itemsDisabledDefense = [false,false,false,false,false,false,false,false,false,false,false,false]
var offenseAbundance = 3
var defenseAbundance = 3
var itemModeOn = true
var offenseStartingFunds: Int = 5
var defenseStartingFunds: Int = 5

//point location globals 
var pointLat: Double = 0
var pointLong: Double = 0
var pointRadius = CLLocationDistance(10)
var baseLat: Double = 0
var baseLong: Double = 0
var baseRadius = CLLocationDistance(10)

//in-game globals
let STATE_TIMER_INTERVAL: Int = 3
var globalGameStartTime: Int = -1
var playerStateDict = [String: [String: Any] ]()
var localPlayerPosition = ""
var localPlayerStatus: Int = 2
var playerCapturingPoint =  ""
var pointCaptureState = ""
var playerTagCount: Int = 0
var itemPrices = [Int]()
var itemsDisabled = [Bool]()
var slot1Powerup = 0
var slot2Powerup = 0
var slot3Powerup = 0
var currentFunds = 0
var map3d = true
var quittingGame = false
var eventsArray = [String]()
var gameTimerCount: Int = 1500
var gameWinner = ""

extension UIViewController: CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    func checkIsConnected() -> Bool {
        if Reachability.isConnectedToNetwork() == false {
            displayAlert("No internet connection", message: "nFlux requires an active internet/data connection.  Make sure airplane mode on your phone is OFF, and that you have an active data plan.")
            return false
        }
        else if bluetoothOn == false && devMode == false  {
            displayAlert("Bluetooth disabled", message: "nFlux requires bluetooth in order to determine when players get tagged by opponents. Make sure airplane mode on your phone is OFF, and that bluetooth is enabled and authorized.")
            return false
        }
        else if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse &&
            CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways){
            displayAlert("Location services disabled", message: "nFlux needs to know your location to pair you with opponents and administer the game.  Make sure airplane mode on your phone is OFF, and that you have authorized nFlux to use your location.")
            return false
        }
        return true
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Broadcasting...")
            bluetoothOn = true
        } else if peripheral.state == .poweredOff || peripheral.state == .unsupported || peripheral.state == .unauthorized {
            print("Stopped")
            bluetoothOn = false
        }
    }
    
    func displayAlert(_ title: String, message: String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateBackgroundColor(isOffense: Bool) {
        if isOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        else {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
    }
    
    func resetGlobalSetupVars() {
        //game setup globals
        globalUserName = ""
        globalIsOffense = true
        globalGameID = ""
        bluetoothOn = false
        globalPlayerNamesDict = [String: String]()
        globalIsRejoining = false
        
        //game option globals
        tagPickerSelect = "normal"
        timePickerSelect = "15:00"
        globalCaptureTime = 10
        globalItemsOn = true
        globalGameLength = 0
        globalTagThreshold = 0
        
        //item option globals
        itemPricesOffense = [2,7,5,10,7,12,5,8,7,15,7,15]
        itemPricesDefense = [2,7,5,10,7,12,5,8,8,10,12,20]
        itemsDisabledOffense = [false,false,false,false,false,false,false,false,false,false,false,false]
        itemsDisabledDefense = [false,false,false,false,false,false,false,false,false,false,false,false]
        offenseAbundance = 3
        defenseAbundance = 3
        itemModeOn = true
        offenseStartingFunds = 5
        defenseStartingFunds = 5
        
        //point location globals
        pointLat = 0
        pointLong = 0
        pointRadius = CLLocationDistance(10)
        baseLat = 0
        baseLong = 0
        baseRadius = CLLocationDistance(10)
        
        //in-game globals
        globalGameStartTime = -1
        playerStateDict = [String: [String: Any] ]()
        localPlayerPosition = ""
        localPlayerStatus = 2
        playerCapturingPoint = ""
        pointCaptureState = ""
        playerTagCount = 0
        itemPrices = [Int]()
        itemsDisabled = [Bool]()
        slot1Powerup = 0
        slot2Powerup = 0
        slot3Powerup = 0
        currentFunds = 0
        map3d = true
        quittingGame = false
        eventsArray = [String]()
        gameTimerCount = 1500
        gameWinner = ""
    }
    
    func loadGame(gameConfig: [String: Any], playerConfig: [String: [String: Any] ] ) {
        globalTagThreshold = gameConfig["tag_sensitivity"] as! Int
        gameTimerCount = gameConfig["game_length"] as! Int
        globalGameLength = gameConfig["game_length"] as! Int
        globalCaptureTime = gameConfig["capture_time"] as! Int
        globalItemsOn = gameConfig["items_enabled"] as! Bool
        globalTestModeEnabled = gameConfig["test_mode_enabled"] as! Bool
        pointLat = gameConfig["point_lat"] as! Double
        pointLong = gameConfig["point_lon"] as! Double
        pointRadius = CLLocationDistance(gameConfig["point_radius"] as! Int)
        baseLat = gameConfig["base_lat"] as! Double
        baseLong = gameConfig["base_lon"] as! Double
        baseRadius = CLLocationDistance(gameConfig["point_radius"] as! Int)
        if globalItemsOn {
            offenseStartingFunds = gameConfig["offense_starting_funds"] as! Int
            defenseStartingFunds = gameConfig["defense_starting_funds"] as! Int
            offenseAbundance = gameConfig["item_abundance_offense"] as! Int
            defenseAbundance = gameConfig["item_abundance_defense"] as! Int
            itemPricesOffense = gameConfig["item_prices_offense"] as! [Int]
            itemPricesDefense = gameConfig["item_prices_defense"] as! [Int]
            itemsDisabledOffense = gameConfig["items_disabled_offense"] as! [Bool]
            itemsDisabledDefense = gameConfig["items_disabled_defense"] as! [Bool]
            itemModeOn = gameConfig["item_mode_on"] as! Bool
        }
        for (position, player_dict) in playerConfig {
            globalPlayerNamesDict[position] = player_dict["user_name"] as? String
            if UDID == player_dict["udid"] as! String {
                localPlayerPosition = position
            }
        }
    }
    
    //hide keyboard when background is tapped
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Dismiss the keyboard when the user taps the "Return" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //lock in portrait orientation
//    override var shouldAutorotate : Bool {
//        return false }

}
