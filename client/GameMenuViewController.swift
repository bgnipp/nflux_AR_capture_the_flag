//
//  GameMenuViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 11/21/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class GameMenuViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var mapSwitch: UISwitch!
    @IBOutlet var autoCameraSwitch: UISwitch!
    
    @IBOutlet var offense1Label: UILabel!
    @IBOutlet var offense2Label: UILabel!
    @IBOutlet var offense3Label: UILabel!
    @IBOutlet var offense4Label: UILabel!
    @IBOutlet var offense5Label: UILabel!
    @IBOutlet var defense1Label: UILabel!
    @IBOutlet var defense2Label: UILabel!
    @IBOutlet var defense3Label: UILabel!
    @IBOutlet var defense4Label: UILabel!
    @IBOutlet var defense5Label: UILabel!
    @IBOutlet var offense1Label2: UILabel!
    @IBOutlet var offense2Label2: UILabel!
    @IBOutlet var offense3Label2: UILabel!
    @IBOutlet var offense4Label2: UILabel!
    @IBOutlet var offense5Label2: UILabel!
    @IBOutlet var defense1Label2: UILabel!
    @IBOutlet var defense2Label2: UILabel!
    @IBOutlet var defense3Label2: UILabel!
    @IBOutlet var defense4Label2: UILabel!
    @IBOutlet var defense5Label2: UILabel!
    
    //menu refresh timer
    var menuRefreshTimer = Timer()
    var menuRefreshTimerCount: Int = 10
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard
        self.testRadiusTextField.delegate = self
        self.testTextField2.delegate = self
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        quittingGame = false
        
        //SHIP SHIP hide test features
        //if testFeaturesOn == false {
            self.testTextField2.isHidden = true
            self.testRadiusTextField.isHidden = true
            self.setTestRadiusButtonLabel.isHidden = true
            self.hideTestViewButtonLabel.isHidden = true
            
//        }
//        else {
//            self.testTextField2.hidden = false
//            self.testRadiusTextField.hidden = false
//            self.setTestRadiusButtonLabel.hidden = false
//            self.hideTestViewButtonLabel.hidden = false
//        }
        
        //switch off color
        self.mapSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.mapSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.mapSwitch.layer.cornerRadius = 16.0
        self.autoCameraSwitch.tintColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.autoCameraSwitch.backgroundColor = UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        self.autoCameraSwitch.layer.cornerRadius = 16.0
        
        self.mapSwitch.isOn = map3d
        self.autoCameraSwitch.isOn = autoCameraEnabled
        // self.autoCameraSwitch.isEnabled = map3d
        
        //populate player names
        self.offense1Label.text = globalPlayerNamesDict["offense1"]!
        self.offense2Label.text = globalPlayerNamesDict["offense2"]!
        self.offense3Label.text = globalPlayerNamesDict["offense3"]!
        self.offense4Label.text = globalPlayerNamesDict["offense4"]!
        self.offense5Label.text = globalPlayerNamesDict["offense5"]!
        self.defense1Label.text = globalPlayerNamesDict["defense1"]!
        self.defense2Label.text = globalPlayerNamesDict["defense2"]!
        self.defense3Label.text = globalPlayerNamesDict["defense3"]!
        self.defense4Label.text = globalPlayerNamesDict["defense4"]!
        self.defense5Label.text = globalPlayerNamesDict["defense5"]!
        
        self.updateStatus()
        
        //start refresh timer
        self.menuRefreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameMenuViewController.menuRefreshTimerUpdate), userInfo: nil, repeats: true)
        self.menuRefreshTimer.tolerance = 0.2

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func returnToGameButton(_ sender: AnyObject) {
        map3d = self.mapSwitch.isOn
        autoCameraEnabled = self.autoCameraSwitch.isOn
        self.menuRefreshTimer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func quitGamebutton(_ sender: AnyObject) {
        quittingGame = true
        self.menuRefreshTimer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var testRadiusTextField: UITextField!
    @IBOutlet var testTextField2: UITextField!
    @IBOutlet var setTestRadiusButtonLabel: UIButton!
    @IBOutlet var hideTestViewButtonLabel: UIButton!
    
    @IBAction func hideTestViewButton(_ sender: AnyObject) {
        if testViewHidden == false {
            testViewHidden = true
        }
        else {
            testViewHidden = false
        }
    }
    
    @IBAction func didSwitch3dMap(_ sender: Any) {
//        self.autoCameraSwitch.isEnabled = self.mapSwitch.isOn
//        if !self.mapSwitch.isOn {
//            self.autoCameraSwitch.isOn = false
//        }
    }
    
    @IBAction func setTestRadiusButton(_ sender: AnyObject) {
        testAnnCaption = testRadiusTextField.text!
        testAnnType = testTextField2.text!
        print(testAnnType)
        print(testAnnCaption)
    }
    
    //menu refresh timer
    func menuRefreshTimerUpdate() {
        if menuRefreshTimerCount > 0 {
            menuRefreshTimerCount -= 1
        }
        if menuRefreshTimerCount == 0 {
            menuRefreshTimerCount = 4
            self.updateStatus()
        }
    }
    
    
    func updateStatus() {
        if globalPlayerNamesDict["offense1"]! != "" {
            if playerStateDict["offense1"]!["status"] as! Int == 1  {
                self.offense1Label2.text = "active"
            }
            else if playerStateDict["offense1"]!["status"] as! Int == 0 {
                self.offense1Label2.text = "tagged"
            }
            else if playerStateDict["offense1"]!["status"] as! Int == 2 {
                self.offense1Label2.text = "starting"
            }
        } else {
            self.offense1Label2.text = ""
        }
        
        if globalPlayerNamesDict["offense2"]! != "" {
            if playerStateDict["offense2"]!["status"] as! Int == 1 {
                self.offense2Label2.text = "active"
            }
            else if playerStateDict["offense2"]!["status"] as! Int == 0 {
                self.offense2Label2.text = "tagged"
            }
            else if playerStateDict["offense2"]!["status"] as! Int == 2 {
                self.offense2Label2.text = "starting"
            }
        } else {
            self.offense2Label2.text = ""
        }
        
        if globalPlayerNamesDict["offense3"]! != "" {
            if playerStateDict["offense3"]!["status"] as! Int == 1 {
                self.offense3Label2.text = "active"
            }
            else if playerStateDict["offense3"]!["status"] as! Int == 0 {
                self.offense3Label2.text = "tagged"
            }
            else if playerStateDict["offense3"]!["status"] as! Int == 2 {
                self.offense3Label2.text = "starting"
            }
        } else {
            self.offense3Label2.text = ""
        }
        
        if globalPlayerNamesDict["offense4"]! != "" {
            if playerStateDict["offense4"]!["status"] as! Int == 1 {
                self.offense4Label2.text = "active"
            }
            else if playerStateDict["offense4"]!["status"] as! Int == 0  {
                self.offense4Label2.text = "tagged"
            }
            else if playerStateDict["offense4"]!["status"] as! Int == 2 {
                self.offense4Label2.text = "starting"
            }
        } else {
            self.offense4Label2.text = ""
        }
        
        if globalPlayerNamesDict["offense5"]! != "" {
            if playerStateDict["offense5"]!["status"] as! Int == 1 {
                self.offense5Label2.text = "active"
            }
            else if playerStateDict["offense5"]!["status"] as! Int == 0 {
                self.offense5Label2.text = "tagged"
            }
            else if playerStateDict["offense5"]!["status"] as! Int == 2 {
                self.offense5Label2.text = "starting"
            }
        } else {
            self.offense5Label2.text = ""
        }
        
        
        if globalPlayerNamesDict["defense1"]! != "" {
            if playerStateDict["defense1"]!["status"] as! Int == 1 {
                self.defense1Label2.text = "active"
            }
            else if playerStateDict["defense1"]!["status"] as! Int == 0 {
                self.defense1Label2.text = "tagged"
            }
            else if playerStateDict["defense1"]!["status"] as! Int == 2 {
                self.defense1Label2.text = "starting"
            }
        } else {
            self.defense1Label2.text = ""
        }
        
        if globalPlayerNamesDict["defense2"]! != "" {
            if playerStateDict["defense2"]!["status"] as! Int == 1 {
                self.defense2Label2.text = "active"
            }
            else if playerStateDict["defense2"]!["status"] as! Int == 0 {
                self.defense2Label2.text = "tagged"
            }
            else if playerStateDict["defense2"]!["status"] as! Int == 2 {
                self.defense2Label2.text = "starting"
            }
        } else {
            self.defense2Label2.text = ""
        }
        
        if globalPlayerNamesDict["defense3"]! != "" {
            if playerStateDict["defense3"]!["status"] as! Int == 1 {
                self.defense3Label2.text = "active"
            }
            else if playerStateDict["defense3"]!["status"] as! Int == 0 {
                self.defense3Label2.text = "tagged"
            }
            else if playerStateDict["defense3"]!["status"] as! Int == 2 {
                self.defense3Label2.text = "starting"
            }
        } else {
            self.defense3Label2.text = ""
        }
        
        if globalPlayerNamesDict["defense4"]! != "" {
            if playerStateDict["defense4"]!["status"] as! Int == 1 {
                self.defense4Label2.text = "active"
            }
            else if playerStateDict["defense4"]!["status"] as! Int == 0 {
                self.defense4Label2.text = "tagged"
            }
            else if playerStateDict["defense4"]!["status"] as! Int == 2 {
                self.defense4Label2.text = "starting"
            }
        } else {
            self.defense4Label2.text = ""
        }
        
        if globalPlayerNamesDict["defense5"]! != "" {
            if playerStateDict["defense5"]!["status"] as! Int == 1 {
                self.defense5Label2.text = "active"
            }
            else if playerStateDict["defense5"]!["status"] as! Int == 0 {
                self.defense5Label2.text = "tagged"
            }
            else if playerStateDict["defense5"]!["status"] as! Int == 2 {
                self.defense5Label2.text = "starting"
            }
        } else {
            self.defense5Label2.text = ""
        }
        
        if globalIsOffense == true {
            if localPlayerPosition == "offense1" {
                if localPlayerStatus == 1 {
                    self.offense1Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.offense1Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.offense1Label2.text = "starting"
                }
            } else if localPlayerPosition == "offense2" {
                if localPlayerStatus == 1 {
                    self.offense2Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.offense2Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.offense2Label2.text = "starting"
                }
            } else if localPlayerPosition == "offense3" {
                if localPlayerStatus == 1 {
                    self.offense3Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.offense3Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.offense3Label2.text = "starting"
                }
            } else if localPlayerPosition == "offense4" {
                if localPlayerStatus == 1 {
                    self.offense4Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.offense4Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.offense4Label2.text = "starting"
                }
            } else if localPlayerPosition == "offense5" {
                if localPlayerStatus == 1 {
                    self.offense5Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.offense5Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.offense5Label2.text = "starting"
                }
            }
        } else {
            if localPlayerPosition == "defense1" {
                if localPlayerStatus == 1 {
                    self.defense1Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense1Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense1Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense2" {
                if localPlayerStatus == 1 {
                    self.defense2Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense2Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense2Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense3" {
                if localPlayerStatus == 1 {
                    self.defense3Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense3Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense3Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense4" {
                if localPlayerStatus == 1 {
                    self.defense4Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense4Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense4Label2.text = "starting"
                }
            }
            
            if localPlayerPosition == "defense5" {
                if localPlayerStatus == 1 {
                    self.defense5Label2.text = "active"
                }
                else if localPlayerStatus == 0 {
                    self.defense5Label2.text = "tagged"
                }
                else if localPlayerStatus == 2 {
                    self.defense5Label2.text = "starting"
                }
            }
        }
    
        if playerCapturingPoint == "offense1" {
            self.offense1Label2.text = "has flag"
        }
        if playerCapturingPoint == "offense2" {
            self.offense2Label2.text = "has flag"
        }
        if playerCapturingPoint == "offense3" {
            self.offense3Label2.text = "has flag"
        }
        if playerCapturingPoint == "offense4" {
            self.offense4Label2.text = "has flag"
        }
        if playerCapturingPoint == "offense5" {
            self.offense5Label2.text = "has flag"
        }
        
    }

}
