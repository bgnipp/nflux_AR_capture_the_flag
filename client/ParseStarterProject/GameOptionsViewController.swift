//
//  GameOptionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 10/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

class GameOptionsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var tagPicker: UIPickerView!
    let tagPickerData = ["very high","high","normal","low","very low"]
    var tagThreshold = -73
    
    @IBOutlet var timePicker: UIPickerView!
    let timePickerData = ["60:00","59:00","58:00","57:00","56:00","55:00","54:00","53:00","52:00","51:00","50:00","49:00","48:00","47:00","46:00","45:00","44:00","43:00","42:00","41:00","40:00","39:00","38:00","37:00","36:00","35:00","34:00","33:00","32:00","31:00","30:00","29:00","28:00","27:00","26:00","25:00","24:00","23:00","22:00","21:00","20:00","19:00","18:00","17:00","16:00","15:00","14:00","13:00","12:00","11:00","10:00","9:00","8:00","7:00","6:00","5:00","4:00","3:00"]
    
    
    @IBOutlet var tagButtonOutlet: UIButton!
    @IBOutlet var gameLengthButtonOutlet: UIButton!
    @IBOutlet var captureTimeTextField: UITextField!

    var entersoundlow : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false
    }
    
    @IBOutlet var testFeaturesSwitch: UISwitch!
    @IBOutlet var powerupsSwitch: UISwitch!

    var gameOptionsSystemTimer = Timer()
    var gameOptionsSystemTimerCount: Int = 3
    
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
        
        self.tagPicker.isHidden = true
        self.tagPicker.dataSource = self
        self.tagPicker.delegate = self
        self.timePicker.isHidden = true
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
        
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        if tagPickerSelect == "normal" {
            self.tagButtonOutlet.setTitle("normal", for: UIControlState())
            tagPicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if tagPickerSelect == "very high" {
            self.tagButtonOutlet.setTitle("very high", for: UIControlState())
            tagPicker.selectRow(0, inComponent: 0, animated: false)
            
        }
        else if tagPickerSelect == "high" {
            self.tagButtonOutlet.setTitle("high", for: UIControlState())
            tagPicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if tagPickerSelect == "low" {
            self.tagButtonOutlet.setTitle("low", for: UIControlState())
            tagPicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if tagPickerSelect == "very low" {
            self.tagButtonOutlet.setTitle("very low", for: UIControlState())
            tagPicker.selectRow(4, inComponent: 0, animated: false)
        }
        self.captureTimeTextField.text = String(globalCaptureTime)
        if globalItemsOn == false {
            self.powerupsSwitch.isOn = false
        }
        
        //default
        if timePickerSelect == "15:00" {
            self.gameLengthButtonOutlet.setTitle("15:00", for: UIControlState())
            timePicker.selectRow(45, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "60:00" {
            self.gameLengthButtonOutlet.setTitle("60:00", for: UIControlState())
            timePicker.selectRow(0, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "59:00" {
            self.gameLengthButtonOutlet.setTitle("59:00", for: UIControlState())
            timePicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "58:00" {
            self.gameLengthButtonOutlet.setTitle("58:00", for: UIControlState())
            timePicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "57:00" {
            self.gameLengthButtonOutlet.setTitle("57:00", for: UIControlState())
            timePicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "56:00" {
            self.gameLengthButtonOutlet.setTitle("56:00", for: UIControlState())
            timePicker.selectRow(4, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "55:00" {
            self.gameLengthButtonOutlet.setTitle("55:00", for: UIControlState())
            timePicker.selectRow(5, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "54:00" {
            self.gameLengthButtonOutlet.setTitle("54:00", for: UIControlState())
            timePicker.selectRow(6, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "53:00" {
            self.gameLengthButtonOutlet.setTitle("53:00", for: UIControlState())
            timePicker.selectRow(7, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "52:00" {
            self.gameLengthButtonOutlet.setTitle("52:00", for: UIControlState())
            timePicker.selectRow(8, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "51:00" {
            self.gameLengthButtonOutlet.setTitle("51:00", for: UIControlState())
            timePicker.selectRow(9, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "50:00" {
            self.gameLengthButtonOutlet.setTitle("50:00", for: UIControlState())
            timePicker.selectRow(10, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "49:00" {
            self.gameLengthButtonOutlet.setTitle("49:00", for: UIControlState())
            timePicker.selectRow(11, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "48:00" {
            self.gameLengthButtonOutlet.setTitle("48:00", for: UIControlState())
            timePicker.selectRow(12, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "47:00" {
            self.gameLengthButtonOutlet.setTitle("47:00", for: UIControlState())
            timePicker.selectRow(13, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "46:00" {
            self.gameLengthButtonOutlet.setTitle("46:00", for: UIControlState())
            timePicker.selectRow(14, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "45:00" {
            self.gameLengthButtonOutlet.setTitle("45:00", for: UIControlState())
            timePicker.selectRow(15, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "44:00" {
            self.gameLengthButtonOutlet.setTitle("44:00", for: UIControlState())
            timePicker.selectRow(16, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "43:00" {
            self.gameLengthButtonOutlet.setTitle("43:00", for: UIControlState())
            timePicker.selectRow(17, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "42:00" {
            self.gameLengthButtonOutlet.setTitle("42:00", for: UIControlState())
            timePicker.selectRow(18, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "41:00" {
            self.gameLengthButtonOutlet.setTitle("41:00", for: UIControlState())
            timePicker.selectRow(19, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "40:00" {
            self.gameLengthButtonOutlet.setTitle("40:00", for: UIControlState())
            timePicker.selectRow(20, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "39:00" {
            self.gameLengthButtonOutlet.setTitle("39:00", for: UIControlState())
            timePicker.selectRow(21, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "38:00" {
            self.gameLengthButtonOutlet.setTitle("38:00", for: UIControlState())
            timePicker.selectRow(22, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "37:00" {
            self.gameLengthButtonOutlet.setTitle("37:00", for: UIControlState())
            timePicker.selectRow(23, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "36:00" {
            self.gameLengthButtonOutlet.setTitle("36:00", for: UIControlState())
            timePicker.selectRow(24, inComponent: 0, animated: false)
        }
        else if timePickerSelect == "35:00" {
            self.gameLengthButtonOutlet.setTitle("35:00", for: UIControlState())
            timePicker.selectRow(25, inComponent: 0, animated: false)
        }
        if timePickerSelect == "34:00" {
            self.gameLengthButtonOutlet.setTitle("34:00", for: UIControlState())
            timePicker.selectRow(26, inComponent: 0, animated: false)
        }
        if timePickerSelect == "33:00" {
            self.gameLengthButtonOutlet.setTitle("33:00", for: UIControlState())
            timePicker.selectRow(27, inComponent: 0, animated: false)
        }
        if timePickerSelect == "32:00" {
            self.gameLengthButtonOutlet.setTitle("32:00", for: UIControlState())
            timePicker.selectRow(28, inComponent: 0, animated: false)
        }
        if timePickerSelect == "31:00" {
            self.gameLengthButtonOutlet.setTitle("31:00", for: UIControlState())
            timePicker.selectRow(29, inComponent: 0, animated: false)
        }
        if timePickerSelect == "30:00" {
            self.gameLengthButtonOutlet.setTitle("30:00", for: UIControlState())
            timePicker.selectRow(30, inComponent: 0, animated: false)
        }
        if timePickerSelect == "29:00" {
            self.gameLengthButtonOutlet.setTitle("29:00", for: UIControlState())
            timePicker.selectRow(31, inComponent: 0, animated: false)
        }
        if timePickerSelect == "28:00" {
            self.gameLengthButtonOutlet.setTitle("28:00", for: UIControlState())
            timePicker.selectRow(32, inComponent: 0, animated: false)
        }
        if timePickerSelect == "27:00" {
            self.gameLengthButtonOutlet.setTitle("27:00", for: UIControlState())
            timePicker.selectRow(33, inComponent: 0, animated: false)
        }
        if timePickerSelect == "26:00" {
            self.gameLengthButtonOutlet.setTitle("26:00", for: UIControlState())
            timePicker.selectRow(34, inComponent: 0, animated: false)
        }
        if timePickerSelect == "25:00" {
            self.gameLengthButtonOutlet.setTitle("25:00", for: UIControlState())
            timePicker.selectRow(35, inComponent: 0, animated: false)
        }
        if timePickerSelect == "24:00" {
            self.gameLengthButtonOutlet.setTitle("24:00", for: UIControlState())
            timePicker.selectRow(36, inComponent: 0, animated: false)
        }
        if timePickerSelect == "23:00" {
            self.gameLengthButtonOutlet.setTitle("23:00", for: UIControlState())
            timePicker.selectRow(37, inComponent: 0, animated: false)
        }
        if timePickerSelect == "22:00" {
            self.gameLengthButtonOutlet.setTitle("22:00", for: UIControlState())
            timePicker.selectRow(38, inComponent: 0, animated: false)
        }
        if timePickerSelect == "21:00" {
            self.gameLengthButtonOutlet.setTitle("21:00", for: UIControlState())
            timePicker.selectRow(39, inComponent: 0, animated: false)
        }
        if timePickerSelect == "20:00" {
            self.gameLengthButtonOutlet.setTitle("20:00", for: UIControlState())
            timePicker.selectRow(40, inComponent: 0, animated: false)
        }
        if timePickerSelect == "19:00" {
            self.gameLengthButtonOutlet.setTitle("19:00", for: UIControlState())
            timePicker.selectRow(41, inComponent: 0, animated: false)
        }
        if timePickerSelect == "18:00" {
            self.gameLengthButtonOutlet.setTitle("18:00", for: UIControlState())
            timePicker.selectRow(42, inComponent: 0, animated: false)
        }
        if timePickerSelect == "17:00" {
            self.gameLengthButtonOutlet.setTitle("17:00", for: UIControlState())
            timePicker.selectRow(43, inComponent: 0, animated: false)
        }
        if timePickerSelect == "16:00" {
            self.gameLengthButtonOutlet.setTitle("16:00", for: UIControlState())
            timePicker.selectRow(44, inComponent: 0, animated: false)
        }
        if timePickerSelect == "14:00" {
            self.gameLengthButtonOutlet.setTitle("14:00", for: UIControlState())
            timePicker.selectRow(46, inComponent: 0, animated: false)
        }
        if timePickerSelect == "13:00" {
            self.gameLengthButtonOutlet.setTitle("13:00", for: UIControlState())
            timePicker.selectRow(47, inComponent: 0, animated: false)
        }
        if timePickerSelect == "12:00" {
            self.gameLengthButtonOutlet.setTitle("12:00", for: UIControlState())
            timePicker.selectRow(48, inComponent: 0, animated: false)
        }
        if timePickerSelect == "11:00" {
            self.gameLengthButtonOutlet.setTitle("11:00", for: UIControlState())
            timePicker.selectRow(49, inComponent: 0, animated: false)
        }
        if timePickerSelect == "10:00" {
            self.gameLengthButtonOutlet.setTitle("10:00", for: UIControlState())
            timePicker.selectRow(50, inComponent: 0, animated: false)
        }
        if timePickerSelect == "9:00" {
            self.gameLengthButtonOutlet.setTitle("9:00", for: UIControlState())
            timePicker.selectRow(51, inComponent: 0, animated: false)
        }
        if timePickerSelect == "8:00" {
            self.gameLengthButtonOutlet.setTitle("8:00", for: UIControlState())
            timePicker.selectRow(52, inComponent: 0, animated: false)
        }
        if timePickerSelect == "7:00" {
            self.gameLengthButtonOutlet.setTitle("7:00", for: UIControlState())
            timePicker.selectRow(53, inComponent: 0, animated: false)
        }
        if timePickerSelect == "6:00" {
            self.gameLengthButtonOutlet.setTitle("6:00", for: UIControlState())
            timePicker.selectRow(54, inComponent: 0, animated: false)
        }
        if timePickerSelect == "5:00" {
            self.gameLengthButtonOutlet.setTitle("5:00", for: UIControlState())
            timePicker.selectRow(55, inComponent: 0, animated: false)
        }
        if timePickerSelect == "4:00" {
            self.gameLengthButtonOutlet.setTitle("4:00", for: UIControlState())
            timePicker.selectRow(56, inComponent: 0, animated: false)
        }
        if timePickerSelect == "3:00" {
            self.gameLengthButtonOutlet.setTitle("3:00", for: UIControlState())
            timePicker.selectRow(57, inComponent: 0, animated: false)
        }
        
        self.captureTimeTextField.keyboardType = UIKeyboardType.numberPad
    
        self.testFeaturesSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.testFeaturesSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.testFeaturesSwitch.layer.cornerRadius = 16.0
        self.powerupsSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.powerupsSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.powerupsSwitch.layer.cornerRadius = 16.0
        
        updateBackgroundColor(isOffense: globalIsOffense)
    
        self.gameOptionsSystemTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameOptionsViewController.gameOptionsSystemTimerUpdate), userInfo: nil, repeats: true)
        self.gameOptionsSystemTimer.tolerance = 0.3
        
        self.captureTimeTextField.delegate = self
        self.captureTimeTextField.text = String(globalCaptureTime)
    }

    @IBAction func enterButton(_ sender: AnyObject) {
    
        if !checkIsConnected() {
            print("not connected")
        }
        else if captureTimeTextField.text == ""{
            displayAlert("Error", message: "Missing fields")
        }
        else {
            switch tagPickerSelect {
                case "very low": self.tagThreshold = -40
                case "low": self.tagThreshold = -70
                case "normal": self.tagThreshold = -73
                case "high": self.tagThreshold = -75
                default: self.tagThreshold = -77
            }

            globalCaptureTime = Int(self.captureTimeTextField.text!)!
            globalItemsOn = self.powerupsSwitch.isOn
            SocketIOManager.sharedInstance.postGameOptions(gameID: globalGameID,
                                                           tagSensitivity: self.tagThreshold,
                                                           gameLength: Int(String(timePickerSelect.characters.dropLast(3)))! * 60,
                                                           captureTime: globalCaptureTime,
                                                           itemsEnabled: globalItemsOn,
                                                           testModeEnabled: globalTestModeEnabled,
                                                           completionHandler: { (canProceed) -> Void in
                if canProceed {
                    self.gameOptionsSystemTimer.invalidate()
                    if globalItemsOn == false {
                        self.performSegue(withIdentifier: "showPointLocationViewController", sender: nil)
                    }
                    else {
                        self.performSegue(withIdentifier: "showItemOptionsViewControllerFromGameOptionsViewController", sender: nil)
                    }
                } else {
                    self.displayAlert("Couldn't set game options", message: "Either your network failed or some other shit happened. Please try again.")
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        SocketIOManager.sharedInstance.stopCreatingGame(gameID: globalGameID, udid: UDID, completionHandler: { (didStop) -> Void in
            if didStop {
                self.gameOptionsSystemTimer.invalidate()
                self.backsound?.play()
                self.performSegue(withIdentifier: "showPairViewControllerFromGameOptionsViewController", sender: nil)
            } else {
                self.displayAlert("Couldn't quit game", message: "Either your network failed or some other shit happened. Please try again.")
            }
        })
    }
    
    func gameOptionsSystemTimerUpdate() {
        if gameOptionsSystemTimerCount > 0 {
            gameOptionsSystemTimerCount -= 1
        }
        if gameOptionsSystemTimerCount == 0 {
            SocketIOManager.sharedInstance.postHeartbeat(gameID: globalGameID)
            gameOptionsSystemTimerCount = 3
        }
    }
    
    //hide keyboard and pickers when background is tapped
    override func dismissKeyboard() {
        view.endEditing(true)
        self.tagPicker.isHidden = true
        self.timePicker.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func tagHelpButton(_ sender: AnyObject) {
        displayAlert("Tag sensitivity", message: "Sets how close an offense player must be to an oppoent to tag them")
    }
    
    @IBAction func gameLengthHelpButton(_ sender: AnyObject) {
        displayAlert("Game length", message: "The length of the game (in seconds).  If offense doesn't capture the flag before time runs out, defense wins")
    }
    
    @IBAction func captureTimeHelpButton(_ sender: AnyObject) {
        displayAlert("Capture time", message: "The number of seconds an offense player must stay within the flag region in order to capture the flag")
    }
    
    @IBAction func itemsHelpButton(_ sender: AnyObject) {
        displayAlert("items", message: "Examples of items include scans (reveals opponents' locations, bombs (tags opponents in a certain area of the map), mines, etc")
    }
    
    
    //picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return tagPickerData.count
        }
        else {
            return timePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return tagPickerData[row]
        }
        else {
            return timePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            tagButtonOutlet.setTitle(tagPickerData[row], for: UIControlState())
            tagPickerSelect = tagPickerData[row]
    
            }
                else {
            gameLengthButtonOutlet.setTitle(timePickerData[row], for: UIControlState())
            timePickerSelect = timePickerData[row]
            }
    }

    @IBAction func tagButton(_ sender: AnyObject) {
        if self.tagPicker.isHidden == false {
            self.tagPicker.isHidden = true
        }
        else {
            self.tagPicker.isHidden = false
        }
    }

    @IBAction func gameLengthButton(_ sender: AnyObject) {
        if self.timePicker.isHidden == false {
            self.timePicker.isHidden = true
        }
        else {
            self.timePicker.isHidden = false
        }
    }

    
}
