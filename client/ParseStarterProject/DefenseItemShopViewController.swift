//
//  DefenseItemShopViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/19/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

class DefenseItemShopViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var item1ButtonLabel: UIButton!
    @IBOutlet var item1PriceLabel: UILabel!
    @IBOutlet var item2ButtonLabel: UIButton!
    @IBOutlet var item2PriceLabel: UILabel!
    @IBOutlet var item3ButtonLabel: UIButton!
    @IBOutlet var item3PriceLabel: UILabel!
    @IBOutlet var item4ButtonLabel: UIButton!
    @IBOutlet var item4PriceLabel: UILabel!
    @IBOutlet var item5ButtonLabel: UIButton!
    @IBOutlet var item5PriceLabel: UILabel!
    @IBOutlet var item6ButtonLabel: UIButton!
    @IBOutlet var item6PriceLabel: UILabel!
    @IBOutlet var item7ButtonLabel: UIButton!
    @IBOutlet var item7PriceLabel: UILabel!
    @IBOutlet var item8ButtonLabel: UIButton!
    @IBOutlet var item8PriceLabel: UILabel!
    @IBOutlet var item9ButtonLabel: UIButton!
    @IBOutlet var item9PriceLabel: UILabel!
    @IBOutlet var item10ButtonLabel: UIButton!
    @IBOutlet var item10PriceLabel: UILabel!
    @IBOutlet var item11ButtonLabel: UIButton!
    @IBOutlet var item11PriceLabel: UILabel!
    @IBOutlet var item12ButtonLabel: UIButton!
    @IBOutlet var item12PriceLabel: UILabel!
    
    @IBOutlet var item1HelpButtonLabel: UIButton!
    @IBOutlet var item2HelpButtonLabel: UIButton!
    @IBOutlet var item3HelpButtonLabel: UIButton!
    @IBOutlet var item4HelpButtonLabel: UIButton!
    @IBOutlet var item5HelpButtonLabel: UIButton!
    @IBOutlet var item6HelpButtonLabel: UIButton!
    @IBOutlet var item7HelpButtonLabel: UIButton!
    @IBOutlet var item8HelpButtonLabel: UIButton!
    @IBOutlet var item9HelpButtonLabel: UIButton!
    @IBOutlet var item10HelpButtonLabel: UIButton!
    @IBOutlet var item11HelpButtonLabel: UIButton!
    @IBOutlet var item12HelpButtonLabel: UIButton!
    
    @IBOutlet var powerup1Slot: UIButton!
    @IBOutlet var powerup2Slot: UIButton!
    @IBOutlet var powerup3Slot: UIButton!
    
    var item1Price = 0
    var item2Price = 0
    var item3Price = 0
    var item4Price = 0
    var item5Price = 0
    var item6Price = 0
    var item7Price = 0
    var item8Price = 0
    var item9Price = 0
    var item10Price = 0
    var item11Price = 0
    var item12Price = 0
    
    var chaching : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false }
    
    //hide keyboard when background is tapped
//    func dismissKeyboard() {
//        view.endEditing(true)
//    }
    
    //sounds
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
        
        if let chaching = self.setupAudioPlayerWithFile("chaching", type:"mp3") {
            self.chaching = chaching
        }
        self.chaching?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DefenseItemShopViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //background color
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }

        //set labels
        self.headerLabel.text = "current funds - $\(currentFunds)"
        
        self.item1PriceLabel.text = "$\(itemPrices[0])"
        self.item2PriceLabel.text = "$\(itemPrices[1])"
        self.item3PriceLabel.text = "$\(itemPrices[2])"
        self.item4PriceLabel.text = "$\(itemPrices[3])"
        self.item5PriceLabel.text = "$\(itemPrices[4])"
        self.item6PriceLabel.text = "$\(itemPrices[5])"
        self.item7PriceLabel.text = "$\(itemPrices[6])"
        self.item8PriceLabel.text = "$\(itemPrices[7])"
        self.item9PriceLabel.text = "$\(itemPrices[8])"
        self.item10PriceLabel.text = "$\(itemPrices[9])"
        self.item11PriceLabel.text = "$\(itemPrices[10])"
        self.item12PriceLabel.text = "$\(itemPrices[11])"
        
        self.item1Price = Int("\(itemPrices[0])")!
        self.item2Price = Int("\(itemPrices[1])")!
        self.item3Price = Int("\(itemPrices[2])")!
        self.item4Price = Int("\(itemPrices[3])")!
        self.item5Price = Int("\(itemPrices[4])")!
        self.item6Price = Int("\(itemPrices[5])")!
        self.item7Price = Int("\(itemPrices[6])")!
        self.item8Price = Int("\(itemPrices[7])")!
        self.item9Price = Int("\(itemPrices[8])")!
        self.item10Price = Int("\(itemPrices[9])")!
        self.item11Price = Int("\(itemPrices[10])")!
        self.item12Price = Int("\(itemPrices[11])")!
        
        
        if itemsDisabled[0] as! Bool == true {
            self.item1PriceLabel.text = ""
            self.item1ButtonLabel.setImage(UIImage(named:"scanT.png"), for: UIControlState())
            self.item1ButtonLabel.isEnabled = false
            self.item1HelpButtonLabel.isEnabled = false
            self.item1HelpButtonLabel.isHidden = true
            
        }
        if itemsDisabled[1] as! Bool == true {
            self.item2PriceLabel.text = ""
            self.item2ButtonLabel.setImage(UIImage(named:"superscanT.png"), for: UIControlState())
            self.item2ButtonLabel.isEnabled = false
            self.item2HelpButtonLabel.isEnabled = false
            self.item2HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[2] as! Bool == true {
            self.item3PriceLabel.text = ""
            self.item3ButtonLabel.setImage(UIImage(named:"mine40T.png"), for: UIControlState())
            self.item3ButtonLabel.isEnabled = false
            self.item3HelpButtonLabel.isEnabled = false
            self.item3HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[3] as! Bool == true {
            self.item4PriceLabel.text = ""
            self.item4ButtonLabel.setImage(UIImage(named:"supermineT.png"), for: UIControlState())
            self.item4ButtonLabel.isEnabled = false
            self.item4HelpButtonLabel.isEnabled = false
            self.item4HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[4] as! Bool == true {
            self.item5PriceLabel.text = ""
            self.item5ButtonLabel.setImage(UIImage(named:"bombT.png"), for: UIControlState())
            self.item5ButtonLabel.isEnabled = false
            self.item5HelpButtonLabel.isEnabled = false
            self.item5HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[5] as! Bool == true {
            self.item6PriceLabel.text = ""
            self.item6ButtonLabel.setImage(UIImage(named:"superbombT.png"), for: UIControlState())
            self.item6ButtonLabel.isEnabled = false
            self.item6HelpButtonLabel.isEnabled = false
            self.item6HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[6] as! Bool == true {
            self.item7PriceLabel.text = ""
            self.item7ButtonLabel.setImage(UIImage(named:"jammerT.png"), for: UIControlState())
            self.item7ButtonLabel.isEnabled = false
            self.item7HelpButtonLabel.isEnabled = false
            self.item7HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[7] as! Bool == true {
            self.item8PriceLabel.text = ""
            self.item8ButtonLabel.setImage(UIImage(named:"spybotT.png"), for: UIControlState())
            self.item8ButtonLabel.isEnabled = false
            self.item8HelpButtonLabel.isEnabled = false
            self.item8HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[8] as! Bool == true {
            self.item9PriceLabel.text = ""
            self.item9ButtonLabel.setImage(UIImage(named:"reachT.png"), for: UIControlState())
            self.item9ButtonLabel.isEnabled = false
            self.item9HelpButtonLabel.isEnabled = false
            self.item9HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[9] as! Bool == true {
            self.item10PriceLabel.text = ""
            self.item10ButtonLabel.setImage(UIImage(named:"fistT.png"), for: UIControlState())
            self.item10ButtonLabel.isEnabled = false
            self.item10HelpButtonLabel.isEnabled = false
            self.item10HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[10] as! Bool == true {
            self.item11PriceLabel.text = ""
            self.item11ButtonLabel.setImage(UIImage(named:"sickleT.png"), for: UIControlState())
            self.item11ButtonLabel.isEnabled = false
            self.item11HelpButtonLabel.isEnabled = false
            self.item11HelpButtonLabel.isHidden = true
        }
        if itemsDisabled[11] as! Bool == true {
            self.item12PriceLabel.text = ""
            self.item12ButtonLabel.setImage(UIImage(named:"lightningT.png"), for: UIControlState())
            self.item12ButtonLabel.isEnabled = false
            self.item12HelpButtonLabel.isEnabled = false
            self.item12HelpButtonLabel.isHidden = true
        }
        
        
        if slot1Powerup == 1 {
            self.powerup1Slot.setImage(UIImage(named:"scan.png"), for: UIControlState())
        }
        if slot1Powerup == 2 {
            self.powerup1Slot.setImage(UIImage(named:"superscan.png"), for: UIControlState())
        }
        if slot1Powerup == 3 {
            self.powerup1Slot.setImage(UIImage(named:"mine40.png"), for: UIControlState())
        }
        if slot1Powerup == 4 {
            self.powerup1Slot.setImage(UIImage(named:"supermine.png"), for: UIControlState())
        }
        if slot1Powerup == 5 {
            self.powerup1Slot.setImage(UIImage(named:"bomb.png"), for: UIControlState())
        }
        if slot1Powerup == 6 {
            self.powerup1Slot.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
        }
        if slot1Powerup == 7 {
            self.powerup1Slot.setImage(UIImage(named:"jammer.png"), for: UIControlState())
        }
        if slot1Powerup == 8 {
            self.powerup1Slot.setImage(UIImage(named:"spybot.png"), for: UIControlState())
        }
        if slot1Powerup == 9 {
            self.powerup1Slot.setImage(UIImage(named:"heal.png"), for: UIControlState())
        }
        if slot1Powerup == 10 {
            self.powerup1Slot.setImage(UIImage(named:"superheal.png"), for: UIControlState())
        }
        if slot1Powerup == 11 {
            self.powerup1Slot.setImage(UIImage(named:"shield.png"), for: UIControlState())
        }
        if slot1Powerup == 12 {
            self.powerup1Slot.setImage(UIImage(named:"ghost.png"), for: UIControlState())
        }
        if slot1Powerup == 13 {
            self.powerup1Slot.setImage(UIImage(named:"reach.png"), for: UIControlState())
        }
        if slot1Powerup == 14 {
            self.powerup1Slot.setImage(UIImage(named:"fist.png"), for: UIControlState())
        }
        if slot1Powerup == 15 {
            self.powerup1Slot.setImage(UIImage(named:"sickle.png"), for: UIControlState())
        }
        if slot1Powerup == 16 {
            self.powerup1Slot.setImage(UIImage(named:"lightning.png"), for: UIControlState())
        }
        
        
        if slot2Powerup == 1 {
            self.powerup2Slot.setImage(UIImage(named:"scan.png"), for: UIControlState())
        }
        if slot2Powerup == 2 {
            self.powerup2Slot.setImage(UIImage(named:"superscan.png"), for: UIControlState())
        }
        if slot2Powerup == 3 {
            self.powerup2Slot.setImage(UIImage(named:"mine40.png"), for: UIControlState())
        }
        if slot2Powerup == 4 {
            self.powerup2Slot.setImage(UIImage(named:"supermine.png"), for: UIControlState())
        }
        if slot2Powerup == 5 {
            self.powerup2Slot.setImage(UIImage(named:"bomb.png"), for: UIControlState())
        }
        if slot2Powerup == 6 {
            self.powerup2Slot.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
        }
        if slot2Powerup == 7 {
            self.powerup2Slot.setImage(UIImage(named:"jammer.png"), for: UIControlState())
        }
        if slot2Powerup == 8 {
            self.powerup2Slot.setImage(UIImage(named:"spybot.png"), for: UIControlState())
        }
        if slot2Powerup == 9 {
            self.powerup2Slot.setImage(UIImage(named:"heal.png"), for: UIControlState())
        }
        if slot2Powerup == 10 {
            self.powerup2Slot.setImage(UIImage(named:"superheal.png"), for: UIControlState())
        }
        if slot2Powerup == 11 {
            self.powerup2Slot.setImage(UIImage(named:"shield.png"), for: UIControlState())
        }
        if slot2Powerup == 12 {
            self.powerup2Slot.setImage(UIImage(named:"ghost.png"), for: UIControlState())
        }
        if slot2Powerup == 13 {
            self.powerup2Slot.setImage(UIImage(named:"reach.png"), for: UIControlState())
        }
        if slot2Powerup == 14 {
            self.powerup2Slot.setImage(UIImage(named:"fist.png"), for: UIControlState())
        }
        if slot2Powerup == 15 {
            self.powerup2Slot.setImage(UIImage(named:"sickle.png"), for: UIControlState())
        }
        if slot2Powerup == 16 {
            self.powerup2Slot.setImage(UIImage(named:"lightning.png"), for: UIControlState())
        }
        
        
        if slot3Powerup == 1 {
            self.powerup3Slot.setImage(UIImage(named:"scan.png"), for: UIControlState())
        }
        if slot3Powerup == 2 {
            self.powerup3Slot.setImage(UIImage(named:"superscan.png"), for: UIControlState())
        }
        if slot3Powerup == 3 {
            self.powerup3Slot.setImage(UIImage(named:"mine40.png"), for: UIControlState())
        }
        if slot3Powerup == 4 {
            self.powerup3Slot.setImage(UIImage(named:"supermine.png"), for: UIControlState())
        }
        if slot3Powerup == 5 {
            self.powerup3Slot.setImage(UIImage(named:"bomb.png"), for: UIControlState())
        }
        if slot3Powerup == 6 {
            self.powerup3Slot.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
        }
        if slot3Powerup == 7 {
            self.powerup3Slot.setImage(UIImage(named:"jammer.png"), for: UIControlState())
        }
        if slot3Powerup == 8 {
            self.powerup3Slot.setImage(UIImage(named:"spybot.png"), for: UIControlState())
        }
        if slot3Powerup == 9 {
            self.powerup3Slot.setImage(UIImage(named:"heal.png"), for: UIControlState())
        }
        if slot3Powerup == 10 {
            self.powerup3Slot.setImage(UIImage(named:"superheal.png"), for: UIControlState())
        }
        if slot3Powerup == 11 {
            self.powerup3Slot.setImage(UIImage(named:"shield.png"), for: UIControlState())
        }
        if slot3Powerup == 12 {
            self.powerup3Slot.setImage(UIImage(named:"ghost.png"), for: UIControlState())
        }
        if slot3Powerup == 13 {
            self.powerup3Slot.setImage(UIImage(named:"reach.png"), for: UIControlState())
        }
        if slot3Powerup == 14 {
            self.powerup3Slot.setImage(UIImage(named:"fist.png"), for: UIControlState())
        }
        if slot3Powerup == 15 {
            self.powerup3Slot.setImage(UIImage(named:"sickle.png"), for: UIControlState())
        }
        if slot3Powerup == 16 {
            self.powerup3Slot.setImage(UIImage(named:"lightning.png"), for: UIControlState())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func item1Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item1Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item1Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item1Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 1
                powerup1Slot.setImage(UIImage(named:"scan.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 1
                powerup2Slot.setImage(UIImage(named:"scan.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 1
                powerup3Slot.setImage(UIImage(named:"scan.png"), for: UIControlState())
            }
        }
    }

    @IBAction func item2Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
            
        else if currentFunds <  self.item2Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
            
        else if currentFunds >= self.item2Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item2Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 2
                powerup1Slot.setImage(UIImage(named:"superscan.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 2
                powerup2Slot.setImage(UIImage(named:"superscan.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 2
                powerup3Slot.setImage(UIImage(named:"superscan.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item3Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item3Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item3Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item3Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 3
                powerup1Slot.setImage(UIImage(named:"mine40.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 3
                powerup2Slot.setImage(UIImage(named:"mine40.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 3
                powerup3Slot.setImage(UIImage(named:"mine40.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item4Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item4Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item4Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item4Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 4
                powerup1Slot.setImage(UIImage(named:"supermine.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 4
                powerup2Slot.setImage(UIImage(named:"supermine.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 4
                powerup3Slot.setImage(UIImage(named:"supermine.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item5Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item5Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item5Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item5Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 5
                powerup1Slot.setImage(UIImage(named:"bomb.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 5
                powerup2Slot.setImage(UIImage(named:"bomb.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 5
                powerup3Slot.setImage(UIImage(named:"bomb.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item6Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item6Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item6Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item6Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 6
                powerup1Slot.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 6
                powerup2Slot.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 6
                powerup3Slot.setImage(UIImage(named:"superbomb.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item7Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item7Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item7Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item7Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 7
                powerup1Slot.setImage(UIImage(named:"jammer.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 7
                powerup2Slot.setImage(UIImage(named:"jammer.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 7
                powerup3Slot.setImage(UIImage(named:"jammer.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item8Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item8Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item8Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item8Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 8
                powerup1Slot.setImage(UIImage(named:"spybot.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 8
                powerup2Slot.setImage(UIImage(named:"spybot.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 8
                powerup3Slot.setImage(UIImage(named:"spybot.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item9Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item9Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item9Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item9Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 13
                powerup1Slot.setImage(UIImage(named:"reach.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 13
                powerup2Slot.setImage(UIImage(named:"reach.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 13
                powerup3Slot.setImage(UIImage(named:"reach.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item10Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item10Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item10Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item10Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 14
                powerup1Slot.setImage(UIImage(named:"fist.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 14
                powerup2Slot.setImage(UIImage(named:"fist.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 14
                powerup3Slot.setImage(UIImage(named:"fist.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item11Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item11Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item11Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item11Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 15
                powerup1Slot.setImage(UIImage(named:"sickle.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 15
                powerup2Slot.setImage(UIImage(named:"sickle.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 15
                powerup3Slot.setImage(UIImage(named:"sickle.png"), for: UIControlState())
            }
        }
    }
    
    @IBAction func item12Button(_ sender: AnyObject) {
        if slot1Powerup != 0 && slot2Powerup != 0 && slot3Powerup != 0 {
            self.backsound?.play()
            displayAlert("Error", message: "No open item slots")
        }
        else if currentFunds <  self.item12Price {
            self.backsound?.play()
            displayAlert("Error", message: "Insufficient funds")
        }
        else if currentFunds >= self.item12Price && (slot1Powerup == 0 || slot2Powerup == 0 || slot3Powerup == 0) {
            self.chaching?.play()
            currentFunds = currentFunds - self.item12Price
            self.headerLabel.text = "current funds - $\(currentFunds)"
            if slot1Powerup == 0 {
                slot1Powerup = 16
                powerup1Slot.setImage(UIImage(named:"lightning.png"), for: UIControlState())
            }
            else if slot2Powerup == 0 {
                slot2Powerup = 16
                powerup2Slot.setImage(UIImage(named:"lightning.png"), for: UIControlState())
            }
            else if slot3Powerup == 0 {
                slot3Powerup = 16
                powerup3Slot.setImage(UIImage(named:"lightning.png"), for: UIControlState())
            }
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
        displayAlert("Jammer", message: "When an opponent scans, it will not reveal the location of any opponents.  Lasts one minute")
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

    @IBAction func backButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
