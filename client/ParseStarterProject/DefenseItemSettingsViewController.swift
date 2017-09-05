//
//  DefenseItemSettingsViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/20/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

class DefenseItemSettingsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var item1ButtonLabel: UIButton!
    @IBOutlet var item1TextField: UITextField!
    @IBOutlet var item2ButtonLabel: UIButton!
    @IBOutlet var item2TextField: UITextField!
    @IBOutlet var item3ButtonLabel: UIButton!
    @IBOutlet var item3TextField: UITextField!
    @IBOutlet var item4ButtonLabel: UIButton!
    @IBOutlet var item4TextField: UITextField!
    @IBOutlet var item5ButtonLabel: UIButton!
    @IBOutlet var item5TextField: UITextField!
    @IBOutlet var item6ButtonLabel: UIButton!
    @IBOutlet var item6TextField: UITextField!
    @IBOutlet var item7ButtonLabel: UIButton!
    @IBOutlet var item7TextField: UITextField!
    @IBOutlet var item8ButtonLabel: UIButton!
    @IBOutlet var item8TextField: UITextField!
    @IBOutlet var item9ButtonLabel: UIButton!
    @IBOutlet var item9TextField: UITextField!
    @IBOutlet var item10ButtonLabel: UIButton!
    @IBOutlet var item10TextField: UITextField!
    @IBOutlet var item11ButtonLabel: UIButton!
    @IBOutlet var item11TextField: UITextField!
    @IBOutlet var item12ButtonLabel: UIButton!
    @IBOutlet var item12TextField: UITextField!
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false
    }
    
    var typeclick : AVAudioPlayer?
    var entersound : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBackgroundColor(isOffense: globalIsOffense)
        if let typeclick = self.setupAudioPlayerWithFile("typeclick", type:"mp3") {
            self.typeclick = typeclick
        }
        self.typeclick?.volume = 0.9
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        self.entersound?.volume = 0.6
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DefenseItemSettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //numpad keyboard
        self.item1TextField.keyboardType = UIKeyboardType.numberPad
        self.item2TextField.keyboardType = UIKeyboardType.numberPad
        self.item3TextField.keyboardType = UIKeyboardType.numberPad
        self.item4TextField.keyboardType = UIKeyboardType.numberPad
        self.item5TextField.keyboardType = UIKeyboardType.numberPad
        self.item6TextField.keyboardType = UIKeyboardType.numberPad
        self.item7TextField.keyboardType = UIKeyboardType.numberPad
        self.item8TextField.keyboardType = UIKeyboardType.numberPad
        self.item9TextField.keyboardType = UIKeyboardType.numberPad
        self.item10TextField.keyboardType = UIKeyboardType.numberPad
        self.item11TextField.keyboardType = UIKeyboardType.numberPad
        self.item12TextField.keyboardType = UIKeyboardType.numberPad
        
        //hide keyboard
        self.item1TextField.delegate = self
        self.item2TextField.delegate = self
        self.item3TextField.delegate = self
        self.item4TextField.delegate = self
        self.item5TextField.delegate = self
        self.item6TextField.delegate = self
        self.item7TextField.delegate = self
        self.item8TextField.delegate = self
        self.item9TextField.delegate = self
        self.item10TextField.delegate = self
        self.item11TextField.delegate = self
        self.item12TextField.delegate = self
        
        self.item1TextField.text = String(itemPricesDefense[0])
        self.item2TextField.text = String(itemPricesDefense[1])
        self.item3TextField.text = String(itemPricesDefense[2])
        self.item4TextField.text = String(itemPricesDefense[3])
        self.item5TextField.text = String(itemPricesDefense[4])
        self.item6TextField.text = String(itemPricesDefense[5])
        self.item7TextField.text = String(itemPricesDefense[6])
        self.item8TextField.text = String(itemPricesDefense[7])
        self.item9TextField.text = String(itemPricesDefense[8])
        self.item10TextField.text = String(itemPricesDefense[9])
        self.item11TextField.text = String(itemPricesDefense[10])
        self.item12TextField.text = String(itemPricesDefense[11])
        
        //hide disabled items 
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"scan.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"scanT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[1] == true {
            self.item2ButtonLabel.setImage(UIImage(named:"superscan.png"), for: UIControlState())
        }
        else {
            self.item2ButtonLabel.setImage(UIImage(named:"superscanT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[2] == true {
            self.item3ButtonLabel.setImage(UIImage(named:"mine40.png"), for: UIControlState())
        }
        else {
            self.item3ButtonLabel.setImage(UIImage(named:"mine40T.png"), for: UIControlState())
        }
        if itemsDisabledDefense[3] == true {
            self.item4ButtonLabel.setImage(UIImage(named:"supermine.png"), for: UIControlState())
        }
        else {
            self.item4ButtonLabel.setImage(UIImage(named:"supermineT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[4] == true {
            self.item5ButtonLabel.setImage(UIImage(named:"bomb.png"), for: UIControlState())
        }
        else {
            self.item5ButtonLabel.setImage(UIImage(named:"bombT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[5] == true {
            self.item6ButtonLabel.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
        }
        else {
            self.item6ButtonLabel.setImage(UIImage(named:"superbombT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[6] == true {
            self.item7ButtonLabel.setImage(UIImage(named:"jammer.png"), for: UIControlState())
        }
        else {
            self.item7ButtonLabel.setImage(UIImage(named:"jammerT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[7] == true {
            self.item8ButtonLabel.setImage(UIImage(named:"spybot.png"), for: UIControlState())
        }
        else {
            self.item8ButtonLabel.setImage(UIImage(named:"spybotT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[8] == true {
            self.item9ButtonLabel.setImage(UIImage(named:"reach.png"), for: UIControlState())
        }
        else {
            self.item9ButtonLabel.setImage(UIImage(named:"reachT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[9] == true {
            self.item10ButtonLabel.setImage(UIImage(named:"fist.png"), for: UIControlState())
        }
        else {
            self.item10ButtonLabel.setImage(UIImage(named:"fistT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[10] == true {
            self.item11ButtonLabel.setImage(UIImage(named:"sickle.png"), for: UIControlState())
        }
        else {
            self.item11ButtonLabel.setImage(UIImage(named:"sickleT.png"), for: UIControlState())
        }
        if itemsDisabledDefense[11] == true {
            self.item12ButtonLabel.setImage(UIImage(named:"lightning.png"), for: UIControlState())
        }
        else {
            self.item12ButtonLabel.setImage(UIImage(named:"lightningT.png"), for: UIControlState())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        
        if self.item1TextField.text == "" || self.item2TextField.text == "" || self.item3TextField.text == "" || self.item4TextField.text == "" || self.item5TextField.text == "" || self.item6TextField.text == "" || self.item7TextField.text == "" || self.item8TextField.text == "" || self.item9TextField.text == "" || self.item10TextField.text == "" || self.item11TextField.text == "" || self.item12TextField.text == "" {
            displayAlert("Error", message: "Missing fields")
        }
        else {
            self.entersound?.play()
            itemPricesDefense = [Int(self.item1TextField.text!)!, Int(self.item2TextField.text!)!, Int(self.item3TextField.text!)!, Int(self.item4TextField.text!)!, Int(self.item5TextField.text!)!, Int(self.item6TextField.text!)!, Int(self.item7TextField.text!)!, Int(self.item8TextField.text!)!, Int(self.item9TextField.text!)!, Int(self.item10TextField.text!)!, Int(self.item11TextField.text!)!, Int(self.item12TextField.text!)!]
            self.performSegue(withIdentifier: "showItemOptionsViewControllerFromDefenseItemSettingsViewController", sender: nil)
        }
    }
    
    @IBAction func item1Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"scan.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"scanT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item2Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"superscan.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"superscanT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item3Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"mine40.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"mine40T.png"), for: UIControlState())
        }
    }
    
    @IBAction func item4Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"supermine.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"supermineT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item5Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"bomb.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"bombT.png"), for: UIControlState())
        }
    }

    @IBAction func item6Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"superbombT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item7Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"jammer.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"jammerT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item8Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"spybot.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"spybotT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item9Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"reach.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"reachT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item10Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"fist.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"fistT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item11Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"sickle.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"sickleT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item12Button(_ sender: AnyObject) {
        self.typeclick?.play()
        itemsDisabledDefense[0] = !itemsDisabledDefense[0]
        if itemsDisabledDefense[0] == true {
            self.item1ButtonLabel.setImage(UIImage(named:"lightning.png"), for: UIControlState())
        }
        else {
            self.item1ButtonLabel.setImage(UIImage(named:"lightningT.png"), for: UIControlState())
        }
    }
    
    @IBAction func item1HelpButton(_ sender: AnyObject) {
        displayAlert("Scan", message: "Reveals the location of all opponents in a selected area of the map")
    }

    @IBAction func item2HelpButton(_ sender: AnyObject) {
         displayAlert("Super Scan", message: "Reveals the location of all opponents for about 20 seconds")
    }
    
    @IBAction func item3HelpButton(_ sender: AnyObject) {
        displayAlert("Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging them.  Must be planted within 20 meters from you, and can't be planted in the base or flag zones.")
    }
    
    @IBAction func item4HelpButton(_ sender: AnyObject) {
        displayAlert("Super Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging all opponents in the area.  Must be planted within 20 meters from you, and can't be planted in the base or flag zones.")
    }
    
    @IBAction func item5HelpButton(_ sender: AnyObject) {
        displayAlert("Bomb", message: "Tags all players (even teammates) in a selected area of the map.  Can't be dropped in the flag zone.")
    }
    
    @IBAction func item6HelpButton(_ sender: AnyObject) {
        displayAlert("Super Bomb", message: "Tags all players (even teammates) in a selected area of the map (larger reach than the regular bomb).  Can't be dropped in the flag zone.")
    }
    
    @IBAction func item7HelpButton(_ sender: AnyObject) {
        displayAlert("Jammer", message: "When an opponent scans, it will not reveal the location of any opponents.  Lasts one minute.")
    }
    
    @IBAction func item8HelpButton(_ sender: AnyObject) {
        displayAlert("Spybot", message: "Gets planted at a selected point on the map, and reveals the location of all opponents in that area.  Lasts two minutes.")
    }
    
    @IBAction func item9HelpButton(_ sender: AnyObject) {
        displayAlert("Reach", message: "Can tag opponents from futher away.  Lasts one minute.")
    }
    
    @IBAction func item10HelpButton(_ sender: AnyObject) {
        displayAlert("Sense", message: "Detects the location of opponents who are near.  Lasts one minute.")
    }
    
    @IBAction func item11HelpButton(_ sender: AnyObject) {
        displayAlert("Sickle", message: "Tags the opponent closest to you")
    }
    
    @IBAction func item12HelpButton(_ sender: AnyObject) {
        displayAlert("Lightning", message: "Tags all opponents")
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
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.backsound?.play()
        self.performSegue(withIdentifier: "showItemOptionsViewControllerFromDefenseItemSettingsViewController", sender: nil)
    }

}
