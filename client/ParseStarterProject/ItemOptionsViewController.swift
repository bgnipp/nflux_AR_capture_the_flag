//
//  ItemOptionsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/19/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

class ItemOptionsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var itemOptionsSystemTimer = Timer()
    var itemOptionsSystemTimerCount: Int = 3
    
    @IBOutlet var offenseStartingFundsTextField: UITextField!
    @IBOutlet var defenseStartingFundsTextField: UITextField!
    @IBOutlet var itemModeSwitch: UISwitch!
    @IBOutlet var offenseButtonLabel: UIButton!
    @IBOutlet var defenseButtonLabel: UIButton!
    
    @IBOutlet var offensePicker: UIPickerView!
    let offenseData = ["very high","high","normal","low","very low"]
    
    @IBOutlet var defensePicker: UIPickerView!
    let defenseData = ["very high","high","normal","low","very low"]
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false }
    
    //hide keyboard when background is tapped
    override func dismissKeyboard() {
        view.endEditing(true)
        self.offensePicker.isHidden = true
        self.defensePicker.isHidden = true
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
    var entersoundlow : AVAudioPlayer?
    var backsound: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBackgroundColor(isOffense: globalIsOffense)
        
        self.offensePicker.isHidden = true
        self.offensePicker.dataSource = self
        self.offensePicker.delegate = self
        self.defensePicker.isHidden = true
        self.defensePicker.dataSource = self
        self.defensePicker.delegate = self
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ItemOptionsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //numpad keyboard
        self.offenseStartingFundsTextField.keyboardType = UIKeyboardType.numberPad
        self.defenseStartingFundsTextField.keyboardType = UIKeyboardType.numberPad
        
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        if offenseAbundance == 3 {
            self.offenseButtonLabel.setTitle("normal", for: UIControlState())
            offensePicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 2 {
            self.offenseButtonLabel.setTitle("low", for: UIControlState())
            offensePicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 1 {
            self.offenseButtonLabel.setTitle("very low", for: UIControlState())
            offensePicker.selectRow(4, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 4 {
            self.offenseButtonLabel.setTitle("high", for: UIControlState())
            offensePicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if offenseAbundance == 5 {
            self.offenseButtonLabel.setTitle("very high", for: UIControlState())
            offensePicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        if defenseAbundance == 3 {
            self.defenseButtonLabel.setTitle("normal", for: UIControlState())
            defensePicker.selectRow(2, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 2 {
            self.defenseButtonLabel.setTitle("low", for: UIControlState())
            defensePicker.selectRow(3, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 1 {
            self.defenseButtonLabel.setTitle("very low", for: UIControlState())
            defensePicker.selectRow(4, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 4 {
            self.defenseButtonLabel.setTitle("high", for: UIControlState())
            defensePicker.selectRow(1, inComponent: 0, animated: false)
        }
        else if defenseAbundance == 5 {
            self.defenseButtonLabel.setTitle("very high", for: UIControlState())
            defensePicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        self.offenseStartingFundsTextField.text = String(offenseStartingFunds)
        self.defenseStartingFundsTextField.text = String(defenseStartingFunds)
        
        self.itemModeSwitch.isOn = itemModeOn
        
        //switch off color
        self.itemModeSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.itemModeSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.itemModeSwitch.layer.cornerRadius = 16.0
        
        //hide keyboard
        self.offenseStartingFundsTextField.delegate = self
        self.defenseStartingFundsTextField.delegate = self
        
        self.offenseStartingFundsTextField.text = String(offenseStartingFunds)
        self.defenseStartingFundsTextField.text = String(defenseStartingFunds)
        
        self.itemOptionsSystemTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ItemOptionsViewController.itemOptionsSystemTimerUpdate), userInfo: nil, repeats: true)
        self.itemOptionsSystemTimer.tolerance = 0.3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enterButton(_ sender: AnyObject) {
        if !checkIsConnected() {
            print("not connected")
        } else if offenseStartingFundsTextField.text == "" || defenseStartingFundsTextField.text == "" {
            displayAlert("Missing fields", message: "Enter offense defense starting $")
        } else if Int(offenseStartingFundsTextField.text!)! > 99 || Int(defenseStartingFundsTextField.text!)! > 99 {
            displayAlert("Too greedy!", message: "Can't set offense or defense starting funds above $99!")
        } else {
            SocketIOManager.sharedInstance.postItemOptions(gameID: globalGameID,
                                                           offenseStartingFunds: Int(self.offenseStartingFundsTextField.text!)!,
                                                           defenseStartingFunds: Int(self.defenseStartingFundsTextField.text!)!,
                                                           itemAbundanceOffense: offenseAbundance,
                                                           itemAbundanceDefense: defenseAbundance,
                                                           itemPricesOffense: itemPricesOffense,
                                                           itemPricesDefense: itemPricesDefense,
                                                           itemsDisabledOffense: itemsDisabledOffense,
                                                           itemsDisabledDefense: itemsDisabledDefense,
                                                           itemModeOn: itemModeOn,
                                                           completionHandler: { (canProceed) -> Void in
                                                            if canProceed {
                                                                self.entersoundlow?.play()
                                                                self.itemOptionsSystemTimer.invalidate()
                                                                self.performSegue(withIdentifier: "showPointLocationViewControllerFromItemOptionsViewController", sender: nil)
                                                            }
                                                            else {
                                                                self.displayAlert("Couldn't set item options", message: "Either your network failed or some other shit happened. Please try again.")
                                                            }
            })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func itemOptionsSystemTimerUpdate() {
        if itemOptionsSystemTimerCount > 0 {
            itemOptionsSystemTimerCount -= 1
        }
        if itemOptionsSystemTimerCount == 0 {
            SocketIOManager.sharedInstance.postHeartbeat(gameID: globalGameID)
            itemOptionsSystemTimerCount = 3
        }
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.itemOptionsSystemTimer.invalidate()
        self.backsound?.play()
        self.performSegue(withIdentifier: "showGameOptionsViewControllerFromItemOptionsViewController", sender: nil)
        self.saveSettings()
    }
    
    //pickers
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
        return offenseData.count
        }
        else {
        return defenseData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
        return offenseData[row]
        }
        else {
            return defenseData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            offenseButtonLabel.setTitle(offenseData[row], for: UIControlState())
            offenseAbundance = getAbundanceCode(label: offenseData[row])
        }
        else {
            defenseButtonLabel.setTitle(defenseData[row], for: UIControlState())
            defenseAbundance = getAbundanceCode(label: defenseData[row])
        }
    }

    @IBAction func startingFundsButton(_ sender: AnyObject) {
        displayAlert("Starting funds", message: "Sets the amount of money that players start with.  Money can be used to purchase items at any point during the game.")
    }
    
    @IBAction func abundanceButton(_ sender: AnyObject) {
        displayAlert("Item abundance", message: "Sets item generation frequency.  Very low: ~3 minutes, Low: ~1.5 minutes, Normal: ~1 minute, High ~45 seconds, Very high ~30 seconds.")
    }
    
    @IBAction func modeButton(_ sender: AnyObject) {
        displayAlert("Drop mode", message: "In the regular mode, most items drop on the map and must be picked up by walking to them.  In direct mode, generated items go directly to players.")
    }
    
    @IBAction func offenseButton(_ sender: AnyObject) {
        if offensePicker.isHidden == false {
            offensePicker.isHidden = true
        }
        else {
            offensePicker.isHidden = false
        }
        
    }
    
    @IBAction func defenseButton(_ sender: AnyObject) {
        if defensePicker.isHidden == false {
            defensePicker.isHidden = true
        }
        else {
            defensePicker.isHidden = false
        }
    }
    
    @IBAction func offenseItemSettingsButton(_ sender: AnyObject) {
        self.saveSettings()
        self.itemOptionsSystemTimer.invalidate()
        self.performSegue(withIdentifier: "showOffenseItemSettingsViewControllerFromItemOptionsViewController", sender: nil)
    }
    
    @IBAction func defenseItemSettingsButton(_ sender: AnyObject) {
        self.saveSettings()
        self.itemOptionsSystemTimer.invalidate()
        self.performSegue(withIdentifier: "showDefenseItemSettingsViewControllerFromItemOptionsViewController", sender: nil)
    }
    
    func saveSettings() {
        offenseStartingFunds = Int(self.offenseStartingFundsTextField.text!)!
        defenseStartingFunds = Int(self.defenseStartingFundsTextField.text!)!
        itemModeOn = self.itemModeSwitch.isOn
    }
    
    func getAbundanceCode(label: String) -> Int {
        switch label {
            case "very low": return 1
            case "low": return 2
            case "normal": return 3
            case "high": return 4
            default: return 5
        }
    }
}
