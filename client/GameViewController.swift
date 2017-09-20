//
//  GameViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/29/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import CoreMotion
import MapKit
import AudioToolbox
import AVFoundation
import Foundation

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

extension String {
    func trunc(_ length: Int) -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length))
        } else {
            return self
        }
    }
}

class GameViewController: UIViewController, MKMapViewDelegate {
    
    var headingImageView: UIImageView?
    var userHeading: CLLocationDirection?

    let NETWORK_FAILURE_MAX = 25 / STATE_TIMER_INTERVAL
    let REVEAL_TAGEE_DURATION = 7 / STATE_TIMER_INTERVAL
    let INTRUDER_ALERT_DURATION = 12 / STATE_TIMER_INTERVAL
    let CAPTURE_ALERT_DURATION = 12 / STATE_TIMER_INTERVAL
    
    let SCAN_DURATION: Int = 15 / STATE_TIMER_INTERVAL
    let SUPER_SCAN_DURATION: Int = 15 / STATE_TIMER_INTERVAL
    let JAMMER_DURATION: Int = 75 / STATE_TIMER_INTERVAL
    let SPYBOT_DURATION: Int = 75 / STATE_TIMER_INTERVAL
    let REACH_DURATION: Int = 60 / STATE_TIMER_INTERVAL
    let SENSE_DURATION: Int = 60 / STATE_TIMER_INTERVAL
    
    var captureClearMapCycleCount = 0
    
    //game timer
    var gameTimer = Timer()
    var captureTimer = Timer()
    var captureTimerCount: Int = 10
    var eventsLabelResetCount: Int = 0
    var eventsLabelLast = ""
    var eventsLabelCurrent = ""
    
    var networkFailedCount = 0
    
    var stateTimer = Timer()
    let STATE_TIMER_CONSTANT: Int = 3
    var stateTimerCount: Int = 0
    
    var defenseRechargeTimer = Timer()
    var defenseRechargeTimerCount: Int = 10
    
    var mapViewCameraTimer = Timer()
    var mapViewCameraTimerCount: Int = 0
    var mapView2DTrackingCount: Int = 0
    var deviceHeading = 0.0
    var inItemView = false
    
    //temp (for video creaetion purposes)
    var tempdropcircle = MKCircle()
    var tempdropcircle2 = MKCircle()
    var tempdroppinlast = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var offensedroptemp = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var offensedroptempx = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var offensedroptempflag = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var defensedroptemp = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var circletemp = MKCircle(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: CLLocationDistance(5))

    //sounds
    var logicGamestart2 : AVAudioPlayer?
    var logicPowerUp : AVAudioPlayer?
    var logicScan : AVAudioPlayer?
    var logicLoseLife : AVAudioPlayer?
    var logicCapture : AVAudioPlayer?
    var logicCapturing2 : AVAudioPlayer?
    var logicCancel : AVAudioPlayer?
    var logicReign : AVAudioPlayer?
    var logicSFX1 : AVAudioPlayer?
    var logicSFX3 : AVAudioPlayer?
    var logicSFX4 : AVAudioPlayer?
    var logicGotTag : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    var bomb : AVAudioPlayer?
    var chaching : AVAudioPlayer?
    var coin : AVAudioPlayer?
    var directitem : AVAudioPlayer?
    var entersound : AVAudioPlayer?
    var entersoundlow : AVAudioPlayer?
    var ghost : AVAudioPlayer?
    var itemdrop : AVAudioPlayer?
    var jammer : AVAudioPlayer?
    var lightning : AVAudioPlayer?
    var reach : AVAudioPlayer?
    var scansound : AVAudioPlayer?
    var setmine : AVAudioPlayer?
    var shield : AVAudioPlayer?
    var showtargetimageview : AVAudioPlayer?
    var sickle : AVAudioPlayer?
    var spybotsound : AVAudioPlayer?
    var superbomb : AVAudioPlayer?
    var bombtag : AVAudioPlayer?
    var lightningtag : AVAudioPlayer?
    var sickletag : AVAudioPlayer?
    var superbombtag : AVAudioPlayer?
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false
    }
    
    //mapview
    @IBOutlet var mapView: MKMapView!
    var locationManager:CLLocationManager!
    var mapCamera = MKMapCamera()
    var pointCircle = MKCircle()
    var baseCircle = MKCircle()
    var currentLatitude: CLLocationDegrees = 0
    var currentLongitude: CLLocationDegrees = 0
    var initialMapSetup = false
    var didInitialZoom = false
    
    //current region, 0 = neutral, 1 = base region, 2 = point region
    var localPlayerRegion: Int = 0
    
    var intruderAlertResetCount = 0

    //gameplay tag vars
    var localPlayerTaggedBy = ""
    var playerTaggedBy = "n"
    var localPlayerTagged = ""
    var playerWithPointTagged = "n"
    var T = [] as NSArray
    var T2 = [] as NSArray
    
    var revealTagee1 = 0
    var revealTagee2 = 0
    var revealTagee3 = 0
    
    var revealTagee1Count = 0
    var revealTagee2Count = 0
    var revealTagee3Count = 0
    
    //player locations
    var offense1Lat: Double = 0
    var offense1Long: Double = 0
    var offense2Lat: Double = 0
    var offense2Long: Double = 0
    var offense3Lat: Double = 0
    var offense3Long: Double = 0
    var offense4Lat: Double = 0
    var offense4Long: Double = 0
    var offense5Lat: Double = 0
    var offense5Long: Double = 0
    var offense1Coordinates = CLLocationCoordinate2D()
    var offense2Coordinates = CLLocationCoordinate2D()
    var offense3Coordinates = CLLocationCoordinate2D()
    var offense4Coordinates = CLLocationCoordinate2D()
    var offense5Coordinates = CLLocationCoordinate2D()
    var offense1DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 1")
    var offense2DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 2")
    var offense3DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 3")
    var offense4DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 4")
    var offense5DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 5")
    var offense1XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 1")
    var offense2XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 2")
    var offense3XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 3")
    var offense4XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 4")
    var offense5XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 5")
    var offense1flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 1")
    var offense2flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 2")
    var offense3flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 3")
    var offense4flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 4")
    var offense5flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 5")
    
    var pointDropPin = CustomPin(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Flag", subtitle: "Not captured")
    var baseDropPin = CustomPinBase(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Offense's base")
    
    var defense1Lat: Double = 0
    var defense1Long: Double = 0
    var defense2Lat: Double = 0
    var defense2Long: Double = 0
    var defense3Lat: Double = 0
    var defense3Long: Double = 0
    var defense4Lat: Double = 0
    var defense4Long: Double = 0
    var defense5Lat: Double = 0
    var defense5Long: Double = 0
    var defense1Coordinates = CLLocationCoordinate2D()
    var defense2Coordinates = CLLocationCoordinate2D()
    var defense3Coordinates = CLLocationCoordinate2D()
    var defense4Coordinates = CLLocationCoordinate2D()
    var defense5Coordinates = CLLocationCoordinate2D()
    var defense1DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 1")
    var defense2DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 2")
    var defense3DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 3")
    var defense4DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 4")
    var defense5DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 5")
    var defense1XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 1")
    var defense2XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 2")
    var defense3XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 3")
    var defense4XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 4")
    var defense5XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 5")
    
    //UI label outlets
    @IBOutlet var RSSILabel: UILabel!
    @IBOutlet var thresholdLabel: UILabel!
    @IBOutlet var eventsLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var alertIconImageView: UIImageView!
    @IBOutlet var testButton: UIButton!
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var lifeMeterImageView: UIImageView!
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var powerup1ButtonOutlet: UIButton!
    @IBOutlet var powerup2ButtonOutlet: UIButton!
    @IBOutlet var powerup3ButtonOutlet: UIButton!
    @IBOutlet var targetImageView: UIImageView!
    @IBOutlet var itemButtonBackdropImageView: UIImageView!
    @IBOutlet var itemLabelIconImageView: UIImageView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var useButtonOutlet: UIButton!
    @IBOutlet var helpButtonOutlet: UIButton!
    @IBOutlet var cancelButtonOutlet: UIButton!
    @IBOutlet var itemShopButtonIconTextOutlet: UIButton!
    @IBOutlet var activeItemImageView: UIImageView!
    @IBOutlet var activeItemImageView2: UIImageView!
    @IBOutlet var activeItemImageView3: UIImageView!
    @IBOutlet var fundsLabel: UILabel!
    
    //powerup currently being displayed
    var activePowerup = 0
    
    //slot for the currently displayed power up
    var activePowerupSlot = 0
    
    var firstDropped = 0
    var secondDropped = 0
    var thirdDropped = 0
    var fourthDropped = 0
    
    var powerupState = 0
    
    var itemViewHidden = true

    var I1: Double = 0
    var I2: Double = 0
    var I3: Double = 0
    var I4: Double = 0
    var I5: Double = 0
    
    var drop1DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop1Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop1Circle = MKCircle()
    var drop1Region = CLCircularRegion()
    var drop1Dropped = false
    
    var drop2DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop2Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop2Circle = MKCircle()
    var drop2Region = CLCircularRegion()
    var drop2Dropped = false
    
    var drop3DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop3Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop3Circle = MKCircle()
    var drop3Region = CLCircularRegion()
    var drop3Dropped = false
    
    var drop4DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop4Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop4Circle = MKCircle()
    var drop4Region = CLCircularRegion()
    var drop4Dropped = false
    
    var drop5DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop5Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop5Circle = MKCircle()
    var drop5Region = CLCircularRegion()
    var drop5Dropped = false
    
    var all5Dropped = false
    
    var scanCount = 0
    var regScanCount = 0
    var lightningScanCount = 0
    var scanRegion = CLCircularRegion()
    var scanCircle = MKCircle()
    var scanCoordinates = CLLocationCoordinate2D()
    var scanDropPin = CustomPinScan(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Scan")
    
    var mine1Dropped = false
    var mine1isSuper = false
    var mine1Circle = MKCircle()
    var mine1Coordinates = CLLocationCoordinate2D()
    var mine1DropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine1DropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    var mine1region = CLCircularRegion()
    
    var mine2Dropped = false
    var mine2isSuper = false
    var mine2Circle = MKCircle()
    var mine2Coordinates = CLLocationCoordinate2D()
    var mine2DropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine2DropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    var mine2region = CLCircularRegion()
    
    var mine3Dropped = false
    var mine3isSuper = false
    var mine3Circle = MKCircle()
    var mine3Coordinates = CLLocationCoordinate2D()
    var mine3DropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine3DropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    var mine3region = CLCircularRegion()
    
    var firstMineDropped = 0
    var secondMineDropped = 0
    
    var mine1VDropped = false
    var mine1VisSuper = false
    var mine1VCircle = MKCircle()
    var mine1VCoordinates = CLLocationCoordinate2D()
    var mine1VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine1VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine2VDropped = false
    var mine2VisSuper = false
    var mine2VCircle = MKCircle()
    var mine2VCoordinates = CLLocationCoordinate2D()
    var mine2VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine2VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine3VDropped = false
    var mine3VisSuper = false
    var mine3VCircle = MKCircle()
    var mine3VCoordinates = CLLocationCoordinate2D()
    var mine3VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine3VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine4VDropped = false
    var mine4VisSuper = false
    var mine4VCircle = MKCircle()
    var mine4VCoordinates = CLLocationCoordinate2D()
    var mine4VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine4VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine5VDropped = false
    var mine5VisSuper = false
    var mine5VCircle = MKCircle()
    var mine5VCoordinates = CLLocationCoordinate2D()
    var mine5VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine5VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var firstMineVDropped = 0
    var secondMineVDropped = 0
    var thirdMineVDropped = 0
    var fourthMineVDropped = 0
    
    var bombCircle = MKCircle()
    var bombDropPin = CustomPinBomb(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Bomb")
    var superbombDropPin = CustomPinSuperbomb(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Bomb")
    var bombRegion = CLCircularRegion()
    
    var jammerCount = 0
    var ownJammerCount = 0
    
    var spybot1Count = 0
    var spybot1Circle = MKCircle()
    var spybot1Coordinates = CLLocationCoordinate2D()
    var spybot1DropPin = CustomPinSpybot(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), title: "Spybot")
    var spybot1Region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), radius: CLLocationDistance(1), identifier: "")
    var spybot1Dropped = false
    
    var spybot2Count = 0
    var spybot2Circle = MKCircle()
    var spybot2Coordinates = CLLocationCoordinate2D()
    var spybot2DropPin = CustomPinSpybot(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), title: "Spybot")
    var spybot2Region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), radius: CLLocationDistance(1), identifier: "")
    var spybot2Dropped = false
    
    var spybot3Count = 0
    var spybot3Circle = MKCircle()
    var spybot3Coordinates = CLLocationCoordinate2D()
    var spybot3DropPin = CustomPinSpybot(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), title: "Spybot")
    var spybot3Region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), radius: CLLocationDistance(1), identifier: "")
    var spybot3Dropped = false
    
    var firstSpybotDropped = 0
    var secondSpybotDropped = 0

    var shieldLevel = 0

    var ownGhostCount = 0

    var reachCount = 0
    var ownReachCount = 0
    var reachPlayer = 0
    
    var senseCount = 0

    var itemTimer = Timer()
    var itemTimerCount: Int = STATE_TIMER_INTERVAL
    
    let motionManager = CMMotionManager()
    
    //beacon emitter variables
    var peripheralManager = CBPeripheralManager()
    var advertisedData = NSDictionary()
    var emitterRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Init")
    var detectionRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
    //game info data
    var localPlayerMinorValue: UInt16 = 5766
    
    //geofence stuff
    var pointCoordinates = CLLocationCoordinate2D()
    var pointRegion = CLCircularRegion()
    var baseCoordinates = CLLocationCoordinate2D()
    var baseRegion = CLCircularRegion()
    var basePointDistance = CLLocationDistance()
    var mapCenterPoint = CLLocationCoordinate2D()
    var mapCenterPointLat: Double = 0
    var mapCenterPointLong: Double = 0
    
    //overlay clear timer
    var overlayTimer = Timer()
    var overlayTimerCount: Int = 0
    
    //tag timer
    var tagTimer = Timer()
    var tagTimerCount: Int = 0
    
    //dict to assign beacon minor value based on defense position
    let beaconMinorValueDictionary: [String: UInt16] = ["offense1":5761,"offense2":5762,"offense3":5763,"offense4":5764,"offense5":5765,"defense1":5766,"defense2":5767,"defense3":5768,"defense4":5769,"defense5":5760]
    
    var currentRSSI1: Int = -100
    var currentRSSI2: Int = -100

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
        
        loadSounds()
        updateBackgroundColor(isOffense: globalIsOffense)
        hideUIElements()
        
        SocketIOManager.sharedInstance.listenForGameEvents(completionHandler: { (gameEvent) -> Void in
            self.processGameEvent(gameEvent: gameEvent)
        })
        
        //intro sound
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.logicGamestart2?.play()
        
        //set up map & geofence monitoring
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        if globalIsOffense == false { mapView.tintColor = UIColor.red }
        self.mapView.delegate = self
        self.mapView.mapType = MKMapType.hybridFlyover
        self.mapView.showsCompass = false
        locationManager.delegate = self
        

        if globalItemsOn == true {
            
            //calculate vars for geo item drops
            self.basePointDistance = ((Double(CLLocation(latitude: baseLat, longitude: baseLong).distance(from: CLLocation(latitude: pointLat, longitude: pointLong)) + pointRadius ))) / 220000
            
            self.mapCenterPointLat = Double((pointLat + baseLat) / 2)
            self.mapCenterPointLong = Double((pointLong + baseLong) / 2)
            self.mapCenterPoint = CLLocationCoordinate2D(latitude: self.mapCenterPointLat, longitude: self.mapCenterPointLong)
            
            if globalIsOffense  == true {
                itemPrices = itemPricesOffense
                itemsDisabled = itemsDisabledOffense
                currentFunds = offenseStartingFunds
            }
            else {
                itemPrices = itemPricesDefense
                itemsDisabled = itemsDisabledDefense
                currentFunds = defenseStartingFunds
            }
            self.fundsLabel.text = "\(currentFunds)"
        }
        else {
            self.powerup1ButtonOutlet.isEnabled = false
            self.powerup2ButtonOutlet.isEnabled = false
            self.powerup3ButtonOutlet.isEnabled = false
            self.itemShopButtonIconTextOutlet.isEnabled = false
            self.powerup1ButtonOutlet.isHidden = true
            self.powerup2ButtonOutlet.isHidden = true
            self.powerup3ButtonOutlet.isHidden = true
            self.itemShopButtonIconTextOutlet.isHidden = true
            self.fundsLabel.isHidden = true
        }
        
        //populate UI labels
        if globalTestModeEnabled == true {
            testViewHidden = false
            self.thresholdLabel.text = "Thrs: \(globalTagThreshold)"
        }
        else {
            self.hideTestView(true)
        }
        self.localPlayerMinorValue = self.beaconMinorValueDictionary[localPlayerPosition]!

        //use point/base lat/long to set up CLLocationCoordinate2D for point and base locations
        self.pointCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(pointLat), longitude: CLLocationDegrees(pointLong))
        print("BASELATLONG: ", baseLat, " ", baseLong)
        self.baseCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(baseLat), longitude: CLLocationDegrees(baseLong))
        
        //Add point annotation pin to map view
        self.pointDropPin = CustomPin(coordinate: self.pointCoordinates, title: "Flag", subtitle: "Not captured")
        self.mapView.addAnnotation(self.pointDropPin)
        
        //set up circle overlay on point region
        self.pointCircle = MKCircle(center: self.pointCoordinates, radius: pointRadius)
        self.mapView?.add(self.pointCircle)
        
        //Add base pin annotation pin to map view
        self.baseDropPin = CustomPinBase(coordinate: self.baseCoordinates, title: "Offense's base")
        self.mapView.addAnnotation(self.baseDropPin)
        
        //set up circle overlay on base region
        self.baseCircle = MKCircle(center: self.baseCoordinates, radius: baseRadius)
        self.mapView?.add(self.baseCircle)
        
        //if on offense, listen for beacons
        if globalIsOffense == true {
            self.locationManager.startRangingBeacons(in: self.detectionRegion)
        }
        
        //start timers
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.gameTimerUpdate), userInfo: nil, repeats: true)
        self.stateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.stateTimerUpdate), userInfo: nil, repeats: true)
        self.stateTimer.tolerance = 0.3
        
        //set up point/base regions
        self.pointRegion = CLCircularRegion(center: self.pointCoordinates, radius: pointRadius, identifier: "pointRegion")
        self.baseRegion = CLCircularRegion(center: self.baseCoordinates, radius: baseRadius, identifier: "baseRegion")
        
        //trigger additional loading/syncing for players who are rejoining
        if globalIsRejoining == true {
            self.rejoinLoad()
        }
    
        //broadcast beacon signal, if on defense
        if globalIsOffense == false {
            print("Local player minor value: ", self.localPlayerMinorValue)
            let major: CLBeaconMajorValue = 5151
            let minor: CLBeaconMinorValue = self.localPlayerMinorValue
            self.emitterRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: major, minor: minor, identifier: "Estimotes")
            self.advertisedData = self.emitterRegion.peripheralData(withMeasuredPower: nil)
        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if globalTestModeEnabled == false {
            self.hideTestView(true)
        }
        if map3d == true {
            self.mapView.mapType = MKMapType.hybridFlyover
        }
        if map3d == false {
            self.mapView.mapType = MKMapType.satellite
        }
        self.refreshItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdates()
        if globalTestModeEnabled == true && testViewHidden == false {
            self.hideTestView(false)
        }
        else if globalTestModeEnabled == true && testViewHidden == true {
            self.hideTestView(true)
        }
        if autoCameraEnabled {
            headingImageView?.isHidden = true
        }
        if initialMapSetup == false {
            self.initialMapSetup = true
            setInitialCameraOrientation()
        } else if autoCameraEnabled {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        } else {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
        }
        if quittingGame == true {
            self.quitGame()
        }
        if gameWinner != "" {
            endGame()
        }
    }
    
    func checkForMineTag() {
        if globalIsOffense == true {
            //mine 1
            if self.mine1Dropped == true {
                if self.mine1region.contains(self.defense1Coordinates) || self.mine1region.contains(self.defense2Coordinates) || self.mine1region.contains(self.defense3Coordinates) || self.mine1region.contains(self.defense4Coordinates) || self.mine1region.contains(self.defense5Coordinates) {

                    var playerTaggedByMine = ""
                    var playersTaggedByMine = 0
                    if self.mine1region.contains(self.defense1Coordinates) && playerStateDict["defense1"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense1", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense1"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense1"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.defense2Coordinates) && playerStateDict["defense2"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense2", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense2"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense2"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.defense3Coordinates) && playerStateDict["defense3"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense3", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense3"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense3"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.defense4Coordinates) && playerStateDict["defense4"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense4", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense4"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense4"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.defense5Coordinates) && playerStateDict["defense5"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense5", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense5"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense5"]!
                        playersTaggedByMine += 1
                    }
                    if playersTaggedByMine > 1 {
                        self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                    }
                    else if playersTaggedByMine == 1 {
                        self.logEvent("Mine triggered on \(playerTaggedByMine)")
                    }
                    else if playersTaggedByMine == 0 {
                        self.logEvent("Mine tripped by tagged player!")
                    }
                    self.mine1Dropped = false
                    if self.mine1isSuper == false {
                        self.mapView.removeAnnotation(self.mine1DropPin)
                    }
                    if self.mine1isSuper == true {
                        self.mapView.removeAnnotation(self.supermine1DropPin)
                    }
                    self.mapView.remove(self.mine1Circle)
                }
            }
            //mine2
            if self.mine2Dropped == true {
                if self.mine2region.contains(self.defense1Coordinates) || self.mine2region.contains(self.defense2Coordinates) || self.mine2region.contains(self.defense3Coordinates) || self.mine2region.contains(self.defense4Coordinates) || self.mine2region.contains(self.defense5Coordinates) {
                    
                    var playerTaggedByMine = ""
                    var playersTaggedByMine = 0
                    if self.mine2region.contains(self.defense1Coordinates) && playerStateDict["defense1"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense1", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense1"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense1"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.defense2Coordinates) && playerStateDict["defense2"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense2", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense2"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense2"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.defense3Coordinates) && playerStateDict["defense3"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense3", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense3"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense3"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.defense4Coordinates) && playerStateDict["defense4"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense4", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense4"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense4"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.defense5Coordinates) && playerStateDict["defense5"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense5", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense5"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense5"]!
                        playersTaggedByMine += 1
                    }
                    if playersTaggedByMine > 1 {
                        self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                    }
                    else if playersTaggedByMine == 1 {
                        self.logEvent("Mine triggered on \(playerTaggedByMine)")
                    }
                    else if playersTaggedByMine == 0 {
                        self.logEvent("Mine tripped by tagged player!")
                    }
                    self.mine2Dropped = false
                    if self.mine2isSuper == false {
                        self.mapView.removeAnnotation(self.mine2DropPin)
                    }
                    if self.mine2isSuper == true {
                        self.mapView.removeAnnotation(self.supermine2DropPin)
                    }
                    self.mapView.remove(self.mine2Circle)
                }
            }
            //mine3
            if self.mine3Dropped == true {
                if self.mine3region.contains(self.defense1Coordinates) || self.mine3region.contains(self.defense2Coordinates) || self.mine3region.contains(self.defense3Coordinates) || self.mine3region.contains(self.defense4Coordinates) || self.mine3region.contains(self.defense5Coordinates) {
                    
                    var playerTaggedByMine = ""
                    var playersTaggedByMine = 0
                    if self.mine3region.contains(self.defense1Coordinates) && playerStateDict["defense1"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense1", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense1"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense1"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.defense2Coordinates) && playerStateDict["defense2"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense2", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense2"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense2"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.defense3Coordinates) && playerStateDict["defense3"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense3", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense3"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense3"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.defense4Coordinates) && playerStateDict["defense4"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense4", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense4"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense4"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.defense5Coordinates) && playerStateDict["defense5"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "defense5", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["defense5"]!)
                        playerTaggedByMine = globalPlayerNamesDict["defense5"]!
                        playersTaggedByMine += 1
                    }
                    if playersTaggedByMine > 1 {
                        self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                    }
                    else if playersTaggedByMine == 1 {
                        self.logEvent("Mine triggered on \(playerTaggedByMine)")
                    }
                    else if playersTaggedByMine == 0 {
                        self.logEvent("Mine tripped by tagged player!")
                    }
                    self.mine3Dropped = false
                    if self.mine3isSuper == false {
                        self.mapView.removeAnnotation(self.mine3DropPin)
                    }
                    if self.mine3isSuper == true {
                        self.mapView.removeAnnotation(self.supermine3DropPin)
                    }
                    self.mapView.remove(self.mine3Circle)
                }
            }
        }
        else {
            //mine 1
            if self.mine1Dropped == true {
                if self.mine1region.contains(self.offense1Coordinates) || self.mine1region.contains(self.offense2Coordinates) || self.mine1region.contains(self.offense3Coordinates) || self.mine1region.contains(self.offense4Coordinates) || self.mine1region.contains(self.offense5Coordinates) {
                    
                    var playerTaggedByMine = ""
                    var playersTaggedByMine = 0
                    if self.mine1region.contains(self.offense1Coordinates) && playerStateDict["offense1"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense1", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense1"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense1"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.offense2Coordinates) && playerStateDict["offense2"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense2", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense2"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense2"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.offense3Coordinates) && playerStateDict["offense3"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense3", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense3"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense3"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.offense4Coordinates) && playerStateDict["offense4"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense4", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense4"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense4"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine1region.contains(self.offense5Coordinates) && playerStateDict["offense5"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense5", latitude: self.mine1Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense5"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense5"]!
                        playersTaggedByMine += 1
                    }
                    if playersTaggedByMine > 1 {
                        self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                    }
                    else if playersTaggedByMine == 1 {
                        self.logEvent("Mine triggered on \(playerTaggedByMine)")
                    }
                    else if playersTaggedByMine == 0 {
                        self.logEvent("Mine tripped by tagged player!")
                    }
                    self.mine1Dropped = false
                    if self.mine1isSuper == false {
                        self.mapView.removeAnnotation(self.mine1DropPin)
                    }
                    if self.mine1isSuper == true {
                        self.mapView.removeAnnotation(self.supermine1DropPin)
                    }
                    self.mapView.remove(self.mine1Circle)
                }
            }
            //mine2
            if self.mine2Dropped == true {
                if self.mine2region.contains(self.offense1Coordinates) || self.mine2region.contains(self.offense2Coordinates) || self.mine2region.contains(self.offense3Coordinates) || self.mine2region.contains(self.offense4Coordinates) || self.mine2region.contains(self.offense5Coordinates) {
                    
                    var playerTaggedByMine = ""
                    var playersTaggedByMine = 0
                    if self.mine2region.contains(self.offense1Coordinates) && playerStateDict["offense1"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense1", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense1"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense1"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.offense2Coordinates) && playerStateDict["offense2"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense2", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense2"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense2"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.offense3Coordinates) && playerStateDict["offense3"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense3", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense3"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense3"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.offense4Coordinates) && playerStateDict["offense4"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense4", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense4"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense4"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine2region.contains(self.offense5Coordinates) && playerStateDict["offense5"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense5", latitude: self.mine2Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense5"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense5"]!
                        playersTaggedByMine += 1
                    }
                    if playersTaggedByMine > 1 {
                        self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                    }
                    else if playersTaggedByMine == 1 {
                        self.logEvent("Mine triggered on \(playerTaggedByMine)")
                    }
                    else if playersTaggedByMine == 0 {
                        self.logEvent("Mine tripped by tagged player!")
                    }
                    self.mine2Dropped = false
                    if self.mine2isSuper == false {
                        self.mapView.removeAnnotation(self.mine2DropPin)
                    }
                    if self.mine2isSuper == true {
                        self.mapView.removeAnnotation(self.supermine2DropPin)
                    }
                    self.mapView.remove(self.mine2Circle)
                }
            }
            //mine3
            if self.mine3Dropped == true {
                if self.mine3region.contains(self.offense1Coordinates) || self.mine3region.contains(self.offense2Coordinates) || self.mine3region.contains(self.offense3Coordinates) || self.mine3region.contains(self.offense4Coordinates) || self.mine3region.contains(self.offense5Coordinates) {
                    
                    var playerTaggedByMine = ""
                    var playersTaggedByMine = 0
                    if self.mine3region.contains(self.offense1Coordinates) && playerStateDict["offense1"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense1", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense1"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense1"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.offense2Coordinates) && playerStateDict["offense2"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense2", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense2"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense2"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.offense3Coordinates) && playerStateDict["offense3"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense3", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense3"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense3"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.offense4Coordinates) && playerStateDict["offense4"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense4", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense4"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense4"]!
                        playersTaggedByMine += 1
                    }
                    if self.mine3region.contains(self.offense5Coordinates) && playerStateDict["offense5"]!["status"] as! Int == 1 {
                        self.postMineTag(tagee: "offense5", latitude: self.mine3Coordinates.latitude)
                        self.revealTagee(globalPlayerNamesDict["offense5"]!)
                        playerTaggedByMine = globalPlayerNamesDict["offense5"]!
                        playersTaggedByMine += 1
                    }
                    if playersTaggedByMine > 1 {
                        self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                    }
                    else if playersTaggedByMine == 1 {
                        self.logEvent("Mine triggered on \(playerTaggedByMine)")
                    }
                    else if playersTaggedByMine == 0 {
                        self.logEvent("Mine tripped by tagged player!")
                    }
                    self.mine3Dropped = false
                    if self.mine3isSuper == false {
                        self.mapView.removeAnnotation(self.mine3DropPin)
                    }
                    if self.mine3isSuper == true {
                        self.mapView.removeAnnotation(self.supermine3DropPin)
                    }
                    self.mapView.remove(self.mine3Circle)
                }
            }
        }
    }
    
    func postMineTag(tagee: String, latitude: Double) {
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "mine_tag", sender: localPlayerPosition, recipient: tagee, latitude: latitude, longitude: 0, extra: "", timingOut: 10, completionHandler: { (didPost) -> Void in
        })
    }
    
    func processMinePlantEvent(gameEvent: [String: Any]) {
        let mineDropper = gameEvent["sender"] as! String
        let mineDropperNickname = globalPlayerNamesDict[mineDropper]!
        let mineRecipient = gameEvent["recipient"] as! String
        let mineLatitude = gameEvent["latitude"] as! Double
        let mineLongitude = gameEvent["longitude"] as! Double
        var mineType = "mine"
        var isSuper = false
        if gameEvent["eventName"] as! String == "supermine_plant" {
            mineType = "supermine"
            isSuper = true
        }
        if mineDropper != localPlayerPosition && localPlayerPosition.range(of:mineRecipient) != nil {
            self.logEvent("\(mineDropperNickname) dropped a \(mineType)")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.dropMineView(latitude: mineLatitude, longitude: mineLongitude, isSuper: isSuper, player: mineDropperNickname)
        }
    }
    
    func unmapMineView(latitude: Double) {
        if latitude == mine1VDropPin.coordinate.latitude && self.mine1VDropped == true {
            mine1VDropPin.coordinate.latitude = 0
            self.mapView.removeAnnotation(self.mine1VDropPin)
            self.mapView.removeAnnotation(self.supermine1VDropPin)
            self.mapView.remove(self.mine1VCircle)
            self.mine1VDropped = false
        } else if latitude == mine2VDropPin.coordinate.latitude && self.mine2VDropped == true {
            mine2VDropPin.coordinate.latitude = 0
            self.mapView.removeAnnotation(self.mine2VDropPin)
            self.mapView.removeAnnotation(self.supermine2VDropPin)
            self.mapView.remove(self.mine2VCircle)
            self.mine2VDropped = false
        } else if latitude == mine3VDropPin.coordinate.latitude && self.mine3VDropped == true {
            mine3VDropPin.coordinate.latitude = 0
            self.mapView.removeAnnotation(self.mine3VDropPin)
            self.mapView.removeAnnotation(self.supermine3VDropPin)
            self.mapView.remove(self.mine3VCircle)
            self.mine3VDropped = false
        } else if latitude == mine4VDropPin.coordinate.latitude && self.mine4VDropped == true {
            mine4VDropPin.coordinate.latitude = 0
            self.mapView.removeAnnotation(self.mine4VDropPin)
            self.mapView.removeAnnotation(self.supermine4VDropPin)
            self.mapView.remove(self.mine4VCircle)
            self.mine4VDropped = false
        } else if latitude == mine5VDropPin.coordinate.latitude && self.mine5VDropped == true {
            mine5VDropPin.coordinate.latitude = 0
            self.mapView.removeAnnotation(self.mine5VDropPin)
            self.mapView.removeAnnotation(self.supermine5VDropPin)
            self.mapView.remove(self.mine5VCircle)
            self.mine5VDropped = false
        }
    }
    
    func processMineTagEvent(gameEvent: [String: Any]) {
        let mineDropper = gameEvent["sender"] as! String
        let mineDropperNickname = globalPlayerNamesDict[mineDropper]!
        let mineRecipient = gameEvent["recipient"] as! String
        if localPlayerPosition == mineRecipient {
            self.logEvent("Tagged by \(mineDropperNickname)'s mine!")
            self.bombtag?.play()
        } else if mineDropper != localPlayerPosition {
            self.bombtag?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logEvent("\(mineDropper)'s mine tagged \(mineRecipient)!")
        }
        if mineDropper != localPlayerPosition {
            let mineLatID = gameEvent["latitude"] as! Double
            self.unmapMineView(latitude: mineLatID)
        }
    }
    
    func processBombEvent(gameEvent: [String: Any]) {
        let bomber = gameEvent["sender"] as! String
        let bomberNickname = globalPlayerNamesDict[bomber]!
        let bombRecipient = gameEvent["recipient"] as! String
        let bombRecipientNickname = globalPlayerNamesDict[bombRecipient]!
        if localPlayerPosition == bombRecipient {
            self.tagLocalPlayer()
            self.logEvent("Tagged by \(bomberNickname)'s bomb!")
            self.bombtag?.play()
        } else if bomber != localPlayerPosition {
            self.bombtag?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logEvent("\(bomber) bombed \(bombRecipientNickname)!")
        }
    }
    
    func processJammerEvent(gameEvent: [String: Any]) {
        let jammerSender = gameEvent["sender"] as! String
        let jammerSenderNickname = globalPlayerNamesDict[jammerSender]!
        var senderIsOffense = false
        if jammerSender.range(of:"offense") != nil {
            senderIsOffense = true
        }
        //recieve jammer from teammate
        if senderIsOffense == globalIsOffense && jammerSender != localPlayerPosition {
            self.jammer?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.ownJammerCount = 1
            self.addActiveItemImageView(7)
            self.logEvent("\(jammerSenderNickname) used a jammer")
        } else if jammerSender != localPlayerPosition {
        //get inflicted with jammer
            self.jammerCount = 1
        }
    }
    
    func processSpybotEvent(gameEvent: [String: Any]) {
        let spybotSender = gameEvent["sender"] as! String
        let spybotSenderNickname = globalPlayerNamesDict[spybotSender]!
        let spybotLatitude = gameEvent["latitude"] as! Double
        let spybotLongitude = gameEvent["longitude"] as! Double
        var senderIsOffense = false
        if spybotSender.range(of:"offense") != nil {
            senderIsOffense = true
        }
        if senderIsOffense == globalIsOffense {
            self.dropSpybot(latitude: spybotLatitude, longitude: spybotLongitude, player: spybotSenderNickname)
            self.logEvent("\(spybotSenderNickname) dropped a Spybot")
        }
    }
    
    func processHealEvent(gameEvent: [String: Any]) {
        //receive notification of heal (defense)
        if globalIsOffense == false {
            let healer = gameEvent["sender"] as! String
            let healerNickname = globalPlayerNamesDict[healer]!
            self.logEvent("\(healerNickname) healed!")
        }
    }
    
    func processSuperhealEvent(gameEvent: [String: Any]) {
        let healer = gameEvent["sender"] as! String
        if globalIsOffense == false {
            self.logEvent("Entire offense team healed!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if globalIsOffense && localPlayerStatus == 0 && healer != localPlayerPosition {
            self.heal()
            self.logEvent("Recieved heal!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func processGhostEvent(gameEvent: [String: Any]) {
        let ghoster = gameEvent["sender"] as! String
        let ghosterNickname = globalPlayerNamesDict[ghoster]!
        if globalIsOffense == false {
            self.jammerCount = 1
            slot1Powerup = 0
            slot2Powerup = 0
            slot3Powerup = 0
            self.activePowerup = 0
            self.activePowerupSlot = 0
            if self.itemViewHidden == false {
                self.hideItemView()
            }
            self.refreshItems()
            self.logEvent("Ghosted!!")
        } else if globalIsOffense == true && ghoster != localPlayerPosition {
            self.ownGhostCount = 1
            self.addActiveItemImageView(12)
            self.logEvent("\(ghosterNickname) ghosted!")
        } else {
            return
        }
        self.ghost?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func processReachEvent(gameEvent: [String: Any]) {
        if globalIsOffense == true {
            let reacher = gameEvent["sender"] as! String
            switch reacher {
                case "defense1": self.reachPlayer = 5766
                case "defense2": self.reachPlayer = 5767
                case "defense3": self.reachPlayer = 5768
                case "defense4": self.reachPlayer = 5769
                default: self.reachPlayer = 5760
            }
            self.reachCount = 1
        }
    }
    
    func processSickleEvent(gameEvent: [String: Any]) {
        let reaper = gameEvent["sender"] as! String
        let reaperNickname = globalPlayerNamesDict[reaper]!
        let victim = gameEvent["recipient"] as! String
        let victimNickname = globalPlayerNamesDict[victim]!
        if victim == localPlayerPosition && localPlayerStatus == 1 {
            self.tagLocalPlayer()
            self.logEvent("Tagged by \(reaperNickname)'s sickle!")
            self.sickletag?.play()
        } else if reaper != localPlayerPosition {
            self.logicSFX4?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logEvent("\(reaperNickname) sickled \(victimNickname)!")
        }
    }
    
    func processLightningEvent(gameEvent: [String: Any]) {
        let lightninger = gameEvent["sender"] as! String
        let lightningerNickname = globalPlayerNamesDict[lightninger]!
        if globalIsOffense == true && localPlayerStatus == 1 {
            self.tagLocalPlayer()
            self.logEvent("Tagged by \(lightningerNickname)'s lightning!")
            self.lightningtag?.play()
        } else if lightninger != localPlayerPosition {
            self.logEvent("\(lightningerNickname) used lightning!")
            self.lightning?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func processItemPostEvent(gameEvent: [String: Any]) {
        let latitude = gameEvent["latitude"] as! Double
        let longitude = gameEvent["longitude"] as! Double
        let recipient = gameEvent["recipient"] as! String
        if localPlayerPosition.range(of:recipient) != nil {
            self.mapItem(lat: latitude, long: longitude)
        }
    }
    
    func processItemUnpostEvent(gameEvent: [String: Any]) {
        let sender = gameEvent["sender"] as! String
        let recipient = gameEvent["recipient"] as! String
        if localPlayerPosition != sender && localPlayerPosition.range(of:recipient) != nil {
            let latitude = gameEvent["latitude"] as! Double
            self.unmapItem(lat: latitude)
        }
    }
    
    func unmapItem(lat: Double) {
        if lat == self.drop1Coordinates.latitude {
            self.drop1Dropped = false
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.remove(self.drop1Circle)
            self.drop1DropPin.coordinate.latitude = 0
        } else if lat == self.drop2Coordinates.latitude {
            self.drop2Dropped = false
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.remove(self.drop2Circle)
            self.drop2DropPin.coordinate.latitude = 0
        } else if lat == self.drop3Coordinates.latitude {
            self.drop3Dropped = false
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.remove(self.drop3Circle)
            self.drop3DropPin.coordinate.latitude = 0
        } else if lat == self.drop4Coordinates.latitude {
            self.drop4Dropped = false
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.remove(self.drop4Circle)
            self.drop4DropPin.coordinate.latitude = 0
        } else if lat == self.drop5Coordinates.latitude {
            self.drop5Dropped = false
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.remove(self.drop5Circle)
            self.drop5DropPin.coordinate.latitude = 0
        }
    }
    
    func processRegularTagEvent(gameEvent: [String: Any]) {
        let tagee = gameEvent["sender"] as! String
        if tagee != localPlayerPosition {
            let tageeNickname = globalPlayerNamesDict[tagee]!
            let tageeTeam = tagee.substring(to:tagee.index(tagee.startIndex, offsetBy: 7))
            let localPlayerTeam = localPlayerPosition.substring(to:localPlayerPosition.index(localPlayerPosition.startIndex, offsetBy: 7))
            let tagger = gameEvent["recipient"] as! String
            let taggerNickname = globalPlayerNamesDict[tagger]!
            var logString = ""
            if tagger == localPlayerPosition {
                logString = "You tagged \(tageeNickname)!"
                playerTagCount += 1
            } else {
                logString = "\(taggerNickname) tagged \(tageeNickname)"
            }
            if playerCapturingPoint == tagee && pointCaptureState == "capturing" {
                playerCapturingPoint = ""
                pointCaptureState = ""
            }
            if playerCapturingPoint == tagee && pointCaptureState == "captured" {
                playerCapturingPoint = ""
                pointCaptureState = ""
                logString += ". Flag returned."
            }
            self.logEvent(logString)
            if tageeTeam == localPlayerTeam {
                self.logicCancel?.play()
            } else {
                self.logicGotTag?.play()
            }
            self.revealTagee(tagee)
        }
    }
    
    func processOtherPlayerCapturingPointEvent(gameEvent: [String: Any]) {
        pointCaptureState = "capturing"
        playerCapturingPoint = gameEvent["sender"] as! String
        if playerCapturingPoint != localPlayerPosition {
            if !globalIsOffense {
                if localPlayerStatus == 1 {
                    self.iconLabel.text = "Intruder alert!"
                    self.alertIconImageView.image = UIImage(named:"yellowExclaimation.png") }
                self.logEvent("Somebody in the flag zone!")
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicSFX4?.play()
            }
        }
    }
    
    func processOtherPlayerCapturedPointEvent(gameEvent: [String: Any]) {
        pointCaptureState = "captured"
        playerCapturingPoint = gameEvent["sender"] as! String
        if playerCapturingPoint != localPlayerPosition {
            let capturerNickname = globalPlayerNamesDict[playerCapturingPoint]!
            self.logEvent("\(capturerNickname) captured the flag!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicCapture?.play()
            self.captureClearMapCycleCount = 1
            self.showCapturer()
            if !globalIsOffense && localPlayerStatus == 1 {
                self.captureClearMapCycleCount = 1
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
        }
    }
    
    func processGameOverEvent(gameEvent: [String: Any]) {
        gameWinner = gameEvent["extra"] as! String
        self.endGame()
    }
    
    func processGameEvent(gameEvent: [String: Any]) {
        let eventName = gameEvent["eventName"] as! String
        print("PROCESS game event fired, eventName: ", eventName)
        switch eventName {
            case "mine_plant": processMinePlantEvent(gameEvent: gameEvent)
            case "mine_tag": processMineTagEvent(gameEvent: gameEvent)
            case "supermine_plant": processMinePlantEvent(gameEvent: gameEvent)
            case "bomb": processBombEvent(gameEvent: gameEvent)
            case "jammer": processJammerEvent(gameEvent: gameEvent)
            case "spybot": processSpybotEvent(gameEvent: gameEvent)
            case "heal": processHealEvent(gameEvent: gameEvent)
            case "superheal": processSuperhealEvent(gameEvent: gameEvent)
            case "ghost": processGhostEvent(gameEvent: gameEvent)
            case "reach": processReachEvent(gameEvent: gameEvent)
            case "sickle": processSickleEvent(gameEvent: gameEvent)
            case "lightning": processLightningEvent(gameEvent: gameEvent)
            case "item_post": processItemPostEvent(gameEvent: gameEvent)
            case "item_unpost": processItemUnpostEvent(gameEvent: gameEvent)
            case "tag": processRegularTagEvent(gameEvent: gameEvent)
            case "capturing": processOtherPlayerCapturingPointEvent(gameEvent: gameEvent)
            case "capture": processOtherPlayerCapturedPointEvent(gameEvent: gameEvent)
            case "game_over": processGameOverEvent(gameEvent: gameEvent)
            default: return
        }
    }
    
    func setInitialCameraOrientation() {
        self.mapCamera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), fromDistance: 1500, pitch: 0, heading: 0)
        self.mapView.setCamera(self.mapCamera, animated: false)
        self.mapViewCameraTimerCount = 9
        self.mapViewCameraTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(GameViewController.mapViewCameraTimerUpdate), userInfo: nil, repeats: true)
        self.mapViewCameraTimer.tolerance = 0.3
    }
    
    func setCameraOrientation(pitch: Double, fromDistance: Double) {
        self.mapCamera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), fromDistance: fromDistance, pitch: CGFloat(pitch), heading: (self.locationManager.heading?.trueHeading)!)
        self.mapView.setCamera(self.mapCamera, animated: true)
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
    }
    
    func mapViewCameraTimerUpdate() {
        if self.inItemView {
            return
        }
        if autoCameraEnabled && map3d {
            if self.mapViewCameraTimerCount > 0 {
                self.mapViewCameraTimerCount -= 1
            } else if self.didInitialZoom {
                let devicePitch = (self.motionManager.deviceMotion?.attitude.pitch)! * 180  / Double.pi
                if devicePitch < 20 && self.mapView.camera.pitch > 20 {
                    self.setCameraOrientation(pitch: 0, fromDistance: 500)
                    self.mapViewCameraTimerCount = 6
                } else if devicePitch > 65 && self.mapView.camera.pitch < 65 {
                    self.setCameraOrientation(pitch: 70, fromDistance: 300)
                    self.mapViewCameraTimerCount = 6
                }
            } else if self.mapView.camera.altitude < 1200 {
                self.didInitialZoom = true
                self.mapViewCameraTimerCount = 6
                self.setCameraOrientation(pitch: 35, fromDistance: 400)
            }
            return
        } else if autoCameraEnabled {
            if self.mapView2DTrackingCount > 0 {
                self.mapView2DTrackingCount -= 1
            } else if !self.inItemView {
                self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
                self.mapView2DTrackingCount = 30
            }
        }
//        else {
//            self.updateHeadingAnnotationRotation()
//        }
    }
    
    func enterItemMapView() {
        self.inItemView = true
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = false
    }
    
    func exitItemMapView() {
        self.inItemView = false
        mapView.isPitchEnabled = true
        mapView.isZoomEnabled = true
        if autoCameraEnabled {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        }
    }
    
    @IBAction func testButton(_ sender: AnyObject) {
        if globalIsOffense == true && (localPlayerStatus == 2 || localPlayerStatus == 0) {
            localPlayerStatus = 1
            self.alertIconImageView.isHidden = true
            self.iconLabel.isHidden = true
            self.lifeMeterImageView.isHidden = false
            self.lifeMeterImageView.image = UIImage(named:"5life.png")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
        }
        
        //power up defense player 
        if globalIsOffense == false && (localPlayerStatus == 2 || localPlayerStatus == 0) {
            localPlayerStatus = 1
            
            //set the alert icon and label
            if playerCapturingPoint == "" {
                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                self.iconLabel.text = "Flag in place"
            }
            if playerCapturingPoint != "" {
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
            
            //start broadcasting beacon
            self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
        }
    }
    
    func getPowerupLabel(powerup: Int) -> String {
        switch powerup {
            case 1: return "Scan"
            case 2: return "Super Scan"
            case 3: return "Mine"
            case 4: return "Super Mine"
            case 5: return "Bomb"
            case 6: return "Super Bomb"
            case 7: return "Jammer"
            case 8: return "Spybot"
            case 9: return "Heal"
            case 10: return "Super Heal"
            case 11: return "Shield"
            case 12: return "Ghost"
            case 13: return "Reach"
            case 14: return "Sense"
            case 15: return "Sickle"
            case 16: return "Lightning"
            default: return "error"
        }
    }
    
    func getPowerupImage(powerup: Int) -> String {
        switch powerup {
            case 0: return "emptyBox.png"
            case 1: return "scan.png"
            case 2: return "superscan.png"
            case 3: return "mine40.png"
            case 4: return "supermine.png"
            case 5: return "bomb.png"
            case 6: return "superbomb.png"
            case 7: return "jammer.png"
            case 8: return "spybot.png"
            case 9: return "heal.png"
            case 10: return "superheal.png"
            case 11: return "shield.png"
            case 12: return "ghost.png"
            case 13: return "reach.png"
            case 14: return "fist.png"
            case 15: return "sickle.png"
            case 16: return "lightning.png"
            default: return "error"
        }
    }
    
    func getPowerupDescription(powerup: Int) -> String {
        switch powerup {
            case 1: return "Reveals the location of all opponents in a selected area of the map"
            case 2: return "Reveals the location of all opponents for about 20 seconds"
            case 3: return "Plants a mine on the map that triggers when an opponent gets near, tagging them.  Must be planted within 20 meters from you, and can't be planted in the base or flag zones."
            case 4: return "Plants a mine on the map that triggers when an opponent gets near, tagging all opponents in the area.  Must be planted within 20 meters from you, and can't be planted in the base or flag zones."
            case 5: return "Tags all players (even teammates) in a selected area of the map.  Can't be dropped in the flag zone."
            case 6: return "Tags all players (even teammates) in a selected area of the map (larger reach than the regular bomb.  Can't be dropped in the flag zone."
            case 7: return "When an opponent scans, it will not reveal the location of any opponents.  Lasts one minute."
            case 8: return "Gets planted at a selected point on the map, and reveals all opponents locations within that area.  Lasts two minutes."
            case 9: return "Recharges you (don't need to return to base)"
            case 10: return "Recharges your whole team (don't need to return to base)"
            case 11: return "Takes longer to get tagged"
            case 12: return "All opponents lose all stored items.  Your entire team becomes invisible for one minute."
            case 13: return "Can tag opponents from futher away.  Lasts one minute."
            case 14: return "Detect opponents' locations when they are near"
            case 15: return "Tags the opponent closest to you"
            case 16: return "Tags all opponents"
            default: return "error"
        }
    }
    
    func updatePowerupSlot(slot: Int, powerup: Int) {
        if powerup == 0 {
            if globalIsOffense == true {
                self.performSegue(withIdentifier: "showOffenseItemShopViewControllerFromGameViewController", sender: nil)
            }
            else {
                self.performSegue(withIdentifier: "showDefenseItemShopViewControllerFromGameViewController", sender: nil)
            }
            return
        } else {
            self.itemLabel.text = self.getPowerupLabel(powerup: powerup)
            self.itemLabelIconImageView.image = UIImage(named:self.getPowerupImage(powerup: powerup))
            self.activePowerup = powerup
            self.activePowerupSlot = slot
            if powerup == 1 {
                self.showRadarItemView()
            } else if powerup == 3 || powerup == 4 || powerup == 5 || powerup == 6 {
                self.showTargetItemView()
            } else if powerup == 8 {
                self.showSpybotItemView()
            } else {
                self.showItemView()
            }
        }
    }
    
    @IBAction func powerup1Button(_ sender: AnyObject) {
        self.updatePowerupSlot(slot: 1, powerup: slot1Powerup)
    }
    
    @IBAction func powerup2Button(_ sender: AnyObject) {
        self.updatePowerupSlot(slot: 2, powerup: slot2Powerup)
    }
    
    @IBAction func powerup3Button(_ sender: AnyObject) {
        self.updatePowerupSlot(slot: 3, powerup: slot3Powerup)
    }
    
    func useScan() {
        self.scansound?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.scanDropPin.coordinate = mapView.centerCoordinate
        self.scanDropPin.title = "scan"
        self.mapView.addAnnotation(self.scanDropPin)
        self.overlayTimerCount = 1
        self.overlayTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.overlayTimerUpdate), userInfo: nil, repeats: true)
        self.overlayTimer.tolerance = 0.3
        self.scanRegion = CLCircularRegion(center: mapView.centerCoordinate, radius: CLLocationDistance(20), identifier: "scanRegion")
        self.regScanCount = 1
        scan(region: self.scanRegion, circle: self.scanCircle)
        clearAfterUse()
    }
    
    func useSuperScan() {
        self.scanCount = 1
        self.superscan()
        self.scansound?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        clearAfterUse()
    }
    
    func useMine() {
        let screenCoordinate = mapView.centerCoordinate
        let distanceFromPlayer = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude).distance(from: CLLocation(latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude))
        if self.baseRegion.contains(screenCoordinate) == true || self.pointRegion.contains(screenCoordinate) == true {
            displayAlert("Error", message: "You can't plant a mine in the base or flag regions")
            self.enterItemMapView()
        }
        else if distanceFromPlayer > 20 {
            displayAlert("Error", message: "Must plant within 20 meters of your current location")
            self.enterItemMapView()
        }
        else if self.mine1Dropped == true && self.mine2Dropped == true && self.mine3Dropped == true {
            let refreshAlert = UIAlertController(title: "Mine limit reached", message: "You can't plant more than three mines at once, exchange mine for money?", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                if self.activePowerupSlot == 1 {
                    slot1Powerup = 0
                }
                if self.activePowerupSlot == 2 {
                    slot2Powerup = 0
                }
                if self.activePowerupSlot == 3 {
                    slot3Powerup = 0
                }
                if self.activePowerup == 3 {
                    currentFunds = currentFunds + 5
                }
                if self.activePowerup == 4 {
                    currentFunds = currentFunds + 10
                }
                self.activePowerup = 0
                self.clearAfterUse()
                self.refreshItems()
            }))
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                self.hideItemView()
            }))
            present(refreshAlert, animated: true, completion: nil)
        }
        else {
            var eventName = ""
            var isSuper = false
            if self.activePowerup == 3 {
                eventName = "mine_plant"
                self.logEvent("Mine planted!")
            } else {
                eventName = "supermine_plant"
                self.logEvent("Supermine planted!")
                isSuper = true
            }
            let recipient = localPlayerPosition.substring(to:localPlayerPosition.index(localPlayerPosition.startIndex, offsetBy: 7))
            SocketIOManager.sharedInstance.postGameEvent(
                gameID: globalGameID, eventName: eventName, sender: localPlayerPosition, recipient: recipient, latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude, extra: "", timingOut: 10, completionHandler: { (didPost) -> Void in
            })
            self.dropMine(latitude:screenCoordinate.latitude, longitude: screenCoordinate.longitude, isSuper: isSuper)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            clearAfterUse()
        }
    }
    
    func postBombTag(recipient: String) {
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "bomb", sender: localPlayerPosition, recipient: recipient, latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
        })
    }
    
    func useBomb() {
        let screenCoordinate = mapView.centerCoordinate
        if self.pointRegion.contains(screenCoordinate) == true {
            displayAlert("Error", message: "You can't drop a bomb in the flag zone")
            self.enterItemMapView()
        }
        else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            if self.activePowerup == 5 {
                self.bomb?.play()
                self.bombDropPin.coordinate = screenCoordinate
                self.bombDropPin.title = "bomb"
                self.mapView.addAnnotation(self.bombDropPin)
                self.overlayTimerCount = 1
                self.overlayTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.overlayTimerUpdate), userInfo: nil, repeats: true)
                self.overlayTimer.tolerance = 0.3
                self.bombRegion = CLCircularRegion(center: screenCoordinate, radius: CLLocationDistance(8), identifier: "bombRegion")
            }
            if self.activePowerup == 6 {
                self.superbomb?.play()
                self.superbombDropPin.coordinate = screenCoordinate
                self.superbombDropPin.title = "superbomb"
                self.mapView.addAnnotation(self.superbombDropPin)
                self.overlayTimerCount = 1
                self.overlayTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.overlayTimerUpdate), userInfo: nil, repeats: true)
                self.overlayTimer.tolerance = 0.3
                self.bombRegion = CLCircularRegion(center: screenCoordinate, radius: CLLocationDistance(15), identifier: "bombRegion")
            }
            if self.bombRegion.contains(self.defense1Coordinates) || self.bombRegion.contains(self.defense2Coordinates) || self.bombRegion.contains(self.defense3Coordinates) || self.bombRegion.contains(self.defense4Coordinates) || self.bombRegion.contains(self.defense5Coordinates) || self.bombRegion.contains(self.offense1Coordinates) || self.bombRegion.contains(self.offense2Coordinates) || self.bombRegion.contains(self.offense3Coordinates) || self.bombRegion.contains(self.offense4Coordinates) || self.bombRegion.contains(self.offense5Coordinates) {
                var playerTaggedByBomb = ""
                var playersTaggedByBomb = 0
                if self.bombRegion.contains(self.defense1Coordinates) && playerStateDict["defense1"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "defense1")
                    playerTaggedByBomb = globalPlayerNamesDict["defense1"]!
                    self.revealTagee(globalPlayerNamesDict["defense1"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.defense2Coordinates) && playerStateDict["defense2"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "defense2")
                    playerTaggedByBomb = globalPlayerNamesDict["defense2"]!
                    self.revealTagee(globalPlayerNamesDict["defense2"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.defense3Coordinates) && playerStateDict["defense3"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "defense3")
                    playerTaggedByBomb = globalPlayerNamesDict["defense3"]!
                    self.revealTagee(globalPlayerNamesDict["defense3"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.defense4Coordinates) && playerStateDict["defense4"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "defense4")
                    playerTaggedByBomb = globalPlayerNamesDict["defense4"]!
                    self.revealTagee(globalPlayerNamesDict["defense4"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.defense5Coordinates) && playerStateDict["defense5"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "defense5")
                    playerTaggedByBomb = globalPlayerNamesDict["defense5"]!
                    self.revealTagee(globalPlayerNamesDict["defense5"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.offense1Coordinates) && playerStateDict["offense1"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "offense1")
                    playerTaggedByBomb = globalPlayerNamesDict["offense1"]!
                    self.revealTagee(globalPlayerNamesDict["offense1"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.offense2Coordinates) && playerStateDict["offense2"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "offense2")
                    playerTaggedByBomb = globalPlayerNamesDict["offense2"]!
                    self.revealTagee(globalPlayerNamesDict["offense2"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.offense3Coordinates) && playerStateDict["offense3"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "offense3")
                    playerTaggedByBomb = globalPlayerNamesDict["offense3"]!
                    self.revealTagee(globalPlayerNamesDict["offense3"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.offense4Coordinates) && playerStateDict["offense4"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "offense4")
                    playerTaggedByBomb = globalPlayerNamesDict["offense4"]!
                    self.revealTagee(globalPlayerNamesDict["offense4"]!)
                    playersTaggedByBomb += 1
                }
                if self.bombRegion.contains(self.offense5Coordinates) && playerStateDict["offense5"]!["status"] as! Int == 1 {
                    self.postBombTag(recipient: "offense5")
                    playerTaggedByBomb = globalPlayerNamesDict["offense5"]!
                    self.revealTagee(globalPlayerNamesDict["offense5"]!)
                    playersTaggedByBomb += 1
                }
                if playersTaggedByBomb > 1 {
                    self.logEvent("Bomb tagged \(playersTaggedByBomb) players!")
                }
                else if playerTaggedByBomb != "" {
                    self.logEvent("Bomb tagged \(playerTaggedByBomb)!")
                }
                else {
                    self.logEvent("Bomb missed")
                }
            }
            else {
                self.logEvent("Bomb missed")
            }
            self.clearAfterUse()
        }
    }
    
    func useJammer() {
        self.jammer?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        var recipient = ""
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "jammer", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
        })
        self.ownJammerCount = 1
        self.addActiveItemImageView(7)
        clearAfterUse()
    }
    
    func useSpybot() {
        let screenCoordinate = mapView.centerCoordinate
        var recipient = ""
        if globalIsOffense == true {
            recipient = "offense"
        }
        else {
            recipient = "defense"
        }
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "spybot", sender: localPlayerPosition, recipient: recipient, latitude: Double(screenCoordinate.latitude), longitude: Double(screenCoordinate.longitude), extra: "", completionHandler: { (didPost) -> Void in
        })
        self.dropSpybot(latitude: Double(screenCoordinate.latitude), longitude: Double(screenCoordinate.longitude), player: globalUserName)
        clearAfterUse()
    }
    
    func useHeal() {
        self.heal()
        self.logEvent("Healed!")
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "heal", sender: localPlayerPosition, recipient: "defense", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
        })
        clearAfterUse()
    }
    
    func useSuperHeal() {
        self.heal()
        self.logEvent("Healed everybody!")
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "superheal", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
        })
        clearAfterUse()
    }
    
    func useShield() {
        if localPlayerStatus != 1 {
            displayAlert("Error", message: "Must power-up before using shield")
        }
        else {
            self.shieldLevel = 6
            self.lifeMeterImageView.image = UIImage(named:"lifeshield.png")
            self.shield?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            clearAfterUse()
        }
    }
    
    func useGhost() {
        self.ghost?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "ghost", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
                self.ownGhostCount = 1
                self.addActiveItemImageView(12)
        })
        clearAfterUse()
    }
    
    func useReach() {
        self.reach?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "reach", sender: localPlayerPosition, recipient: "defense", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
                self.ownReachCount = 1
                self.addActiveItemImageView(13)
        })
        clearAfterUse()
    }
    
    func useSense() {
        self.senseCount = 1
        self.logEvent("Sensing...")
        self.addActiveItemImageView(14)
        self.entersound?.play()
        self.scan(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), radius: CLLocationDistance(20), identifier: "sense region"), circle: MKCircle())
        clearAfterUse()
    }
    
    func useSickle() {
        self.sickle?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        //determine which opponent is closest
        let currentCoordinate = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
        let distance1 = currentCoordinate.distance(from: CLLocation(latitude: self.offense1Lat, longitude: self.offense1Long))
        let distance2 = currentCoordinate.distance(from: CLLocation(latitude: self.offense2Lat, longitude: self.offense2Long))
        let distance3 = currentCoordinate.distance(from: CLLocation(latitude: self.offense3Lat, longitude: self.offense3Long))
        let distance4 = currentCoordinate.distance(from: CLLocation(latitude: self.offense4Lat, longitude: self.offense4Long))
        let distance5 = currentCoordinate.distance(from: CLLocation(latitude: self.offense5Lat, longitude: self.offense5Long))
        let distanceArray = [distance1,distance2,distance3,distance4,distance5]
        var minDistance: Double = 99999999999.0
        var iteration = 0
        var closestOpponent = 0
        for distance in distanceArray {
            iteration += 1
            if distance < minDistance {
                minDistance = distance
                closestOpponent = iteration
            }
        }
        var sickleHit = true
        if closestOpponent == 1 && playerStateDict["offense1"]!["status"] as! Int == 1 {
            self.logEvent("Tagged \(globalPlayerNamesDict["offense1"]!) with sickle!")
            self.revealTagee(globalPlayerNamesDict["offense1"]!)
            playerTagCount += 1
        }
        else if closestOpponent == 2 && playerStateDict["offense2"]!["status"] as! Int == 1 {
            self.logEvent("Tagged \(globalPlayerNamesDict["offense2"]!) with sickle!")
            self.revealTagee(globalPlayerNamesDict["offense2"]!)
            playerTagCount += 1
        }
        else if closestOpponent == 3 && playerStateDict["offense3"]!["status"] as! Int == 1 {
            self.logEvent("Tagged \(globalPlayerNamesDict["offense3"]!) with sickle!")
            self.revealTagee(globalPlayerNamesDict["offense3"]!)
            playerTagCount += 1
        }
        else if closestOpponent == 4 && playerStateDict["offense4"]!["status"] as! Int == 1 {
            self.logEvent("Tagged \(globalPlayerNamesDict["offense4"]!) with sickle!")
            self.revealTagee(globalPlayerNamesDict["offense4"]!)
            playerTagCount += 1
        }
        else if closestOpponent == 5 && playerStateDict["offense5"]!["status"] as! Int == 1 {
            self.logEvent("Tagged \(globalPlayerNamesDict["offense5"]!) with sickle!")
            self.revealTagee(globalPlayerNamesDict["offense5"]!)
            playerTagCount += 1
        }
        else {
            self.logEvent("Sickle missed!")
            sickleHit = false
        }
        if sickleHit == true {
            SocketIOManager.sharedInstance.postGameEvent(
                gameID: globalGameID, eventName: "sickle", sender: localPlayerPosition, recipient: "offense\(closestOpponent)", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
            })
        }
        clearAfterUse()
    }
    
    func useLightning() {
        self.lightning?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "lightning", sender: localPlayerPosition, recipient: "offense", latitude: 0, longitude: 0, extra: "", completionHandler: { (didPost) -> Void in
        })
        if globalPlayerNamesDict["defense1"]! != "" {
            self.revealTagee(globalPlayerNamesDict["defense1"]!)
        }
        if globalPlayerNamesDict["defense2"]! != "" {
            self.revealTagee(globalPlayerNamesDict["defense2"]!)
        }
        if globalPlayerNamesDict["defense3"]! != "" {
            self.revealTagee(globalPlayerNamesDict["defense3"]!)
        }
        if globalPlayerNamesDict["defense4"]! != "" {
            self.revealTagee(globalPlayerNamesDict["defense4"]!)
        }
        if globalPlayerNamesDict["defense5"]! != "" {
            self.revealTagee(globalPlayerNamesDict["defense5"]!)
        }
        self.logEvent("Lightning tagged all opponents!")
        self.lightningScan()
        self.lightningScanCount = 1
        clearAfterUse()
    }
    
    @IBAction func useButton(_ sender: AnyObject) {
        self.exitItemMapView()
        switch self.activePowerup {
            case 1: self.useScan()
            case 2: self.useSuperScan()
            case 3: self.useMine()
            case 4: self.useMine()
            case 5: self.useBomb()
            case 6: self.useBomb()
            case 7: self.useJammer()
            case 8: self.useSpybot()
            case 9: self.useHeal()
            case 10: self.useSuperHeal()
            case 11: self.useShield()
            case 12: self.useGhost()
            case 13: self.useReach()
            case 14: self.useSense()
            case 15: self.useSickle()
            case 16: self.useLightning()
            default: print("useButton error")
        }
    }
    
    @IBAction func helpButton(_ sender: AnyObject) {
        displayAlert(self.getPowerupLabel(powerup: self.activePowerup), message: self.getPowerupDescription(powerup: self.activePowerup))
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.hideItemView()
        self.exitItemMapView()
        self.backsound?.play()
    }

    //broadcast beacon signal
    override func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("ADVERTISING!!")
            self.peripheralManager.startAdvertising(((self.advertisedData as NSDictionary) as! [String : Any]))
            bluetoothOn = true
        } else if peripheral.state == .poweredOff || peripheral.state == .unsupported || peripheral.state == .unauthorized {
            bluetoothOn = false
        }
        print("peripheralManagerDidUpdateState bluetooth is: ", bluetoothOn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //location manager to monitor user's current lat/long
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLatitude = location.latitude
        self.currentLongitude = location.longitude
    }

    //beacon detection func
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in detectionRegion: CLBeaconRegion) {
            let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
            if (knownBeacons.count > 0) {
                var closestBeacon = knownBeacons[0] as CLBeacon
                if closestBeacon.minor != 5766 && closestBeacon.minor != 5767 && closestBeacon.minor != 5768 && closestBeacon.minor != 5769 && closestBeacon.minor != 5760 && closestBeacon.minor != 33826 {
                    for beacon in knownBeacons {
                        if beacon.minor == 5766 || beacon.minor == 5767 || beacon.minor == 5768 || beacon.minor == 5769 || beacon.minor == 5760 || beacon.minor == 33826 {
                            closestBeacon = beacon as CLBeacon
                            break
                        }
                    }
                }
                for beacon in knownBeacons {
                    if beacon.rssi > closestBeacon.rssi && (beacon.minor == 5766 || beacon.minor == 5767 || beacon.minor == 5768 || beacon.minor == 5769 || beacon.minor == 5760 || beacon.minor == 33826) {
                        closestBeacon = beacon as CLBeacon
                    }
                }
                currentRSSI1 = closestBeacon.rssi
                let currentRSSIString = String(currentRSSI1)
                self.RSSILabel.text = "RSSI: \(currentRSSIString)"
                if self.shieldLevel == 0 {
                    //if defender is appropriate distance, set to 5 life
                    if currentRSSI1 < -98 && localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767  || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) {
                        self.lifeMeterImageView.image = UIImage(named:"5life.png")
                    }
                    //if defender is appropriate distance, set to 3 life
                    if currentRSSI1 > -98 && currentRSSI1 <= -84 && localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767  || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) {
                        self.lifeMeterImageView.image = UIImage(named:"3life.png")
                    }
                    //if defender is appropriate distance, set to 1 life
                    if currentRSSI1 > -84 && localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767  || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) {
                        self.lifeMeterImageView.image = UIImage(named:"1life.png")
                    }
                }
        //check to see if "tagged" (threshold exceeded), and if so vibrate, play sound, and reset current RSSI value to a high number as a "cool down" timer
                if localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767 || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) && (currentRSSI1 > globalTagThreshold || (self.reachCount > 0 && currentRSSI1 > (globalTagThreshold - 6)  && Int(closestBeacon.minor) == self.reachPlayer)) {
                    var tagger = ""
                    if self.shieldLevel == 0 {
                        if closestBeacon.minor == 5766 {
                            self.localPlayerTaggedBy = "defense1"
                            self.logEvent("Tagged by \(globalPlayerNamesDict["defense1"]!)!")
                            tagger = globalPlayerNamesDict["defense1"]!
                        }
                        if closestBeacon.minor == 5767 {
                            self.localPlayerTaggedBy = "defense2"
                            self.logEvent("Tagged by \(globalPlayerNamesDict["defense2"]!)!")
                            tagger = globalPlayerNamesDict["defense2"]!
                        }
                        if closestBeacon.minor == 5768 {
                            self.localPlayerTaggedBy = "defense3"
                            self.logEvent("Tagged by \(globalPlayerNamesDict["defense3"]!)!")
                            tagger = globalPlayerNamesDict["defense3"]!
                        }
                        if closestBeacon.minor == 5769 {
                            self.localPlayerTaggedBy = "defense4"
                            self.logEvent("Tagged by \(globalPlayerNamesDict["defense4"]!)!")
                            tagger = globalPlayerNamesDict["defense4"]!
                        }
                        if closestBeacon.minor == 5760 {
                            self.localPlayerTaggedBy = "defense5"
                            self.logEvent("Tagged by \(globalPlayerNamesDict["defense5"]!)!")
                            tagger = globalPlayerNamesDict["defense5"]!
                        }
                        if closestBeacon.minor == 33826 {
                            self.localPlayerTaggedBy = "beacon"
                            self.logEvent("Tagged by the blue beacon!")
                            tagger = "blue beacon"
                        }
                        self.tagLocalPlayer()
                        self.logicLoseLife?.play()
                        SocketIOManager.sharedInstance.postGameEvent(
                            gameID: globalGameID, eventName: "tag", sender: localPlayerPosition, recipient: tagger, latitude: 0, longitude: 0, extra: "reg", timingOut: 99, completionHandler: { (didPost) -> Void in
                        })
                    }
                    else {
                        self.shieldLevel -= 1
                        if self.shieldLevel == 3 {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.shield?.play()
                            self.logEvent("Shield cracked!")
                            self.lifeMeterImageView.image = UIImage(named:"lifecrackedshield.png")
                        }
                        if self.shieldLevel == 0 {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.shield?.play()
                            self.logEvent("Shield broken!")
                            self.lifeMeterImageView.image = UIImage(named:"3life.png")
                        }
                    }
                }
            }
        }
    
    //radius overlay on point and base map pins
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay as! MKCircle  == self.baseCircle {
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.5
        overlayRenderer.strokeColor = UIColor.blue
        return overlayRenderer
        }
        
        else if overlay as! MKCircle  == self.mine1Circle || overlay as! MKCircle  == self.mine2Circle || overlay as! MKCircle  == self.mine1VCircle || overlay as! MKCircle  == self.mine2VCircle || overlay as! MKCircle  == self.mine3VCircle || overlay as! MKCircle  == self.mine4VCircle || overlay as! MKCircle  == self.mine5VCircle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 1.0
            overlayRenderer.strokeColor = UIColor(red:0.440, green:0.138, blue:0.456, alpha:1.00)
            return overlayRenderer
        }
            
        else if overlay as! MKCircle  == self.drop1Circle || overlay as! MKCircle  == self.drop2Circle || overlay as! MKCircle  == self.drop3Circle || overlay as! MKCircle  == self.drop4Circle || overlay as! MKCircle  == self.drop5Circle || overlay as! MKCircle  == self.tempdropcircle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 1.0
            overlayRenderer.strokeColor = UIColor(red:0.957, green:0.565, blue:0.000, alpha:1.00)
            return overlayRenderer
        }
            
        else if overlay as! MKCircle  == self.spybot1Circle || overlay as! MKCircle  == self.spybot2Circle || overlay as! MKCircle  == self.spybot3Circle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 1.0
            overlayRenderer.strokeColor = UIColor(red:0.252, green:1.000, blue:0.432, alpha:1.00)
            return overlayRenderer
        }
        
        else {
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.5
        overlayRenderer.strokeColor = UIColor.red
        return overlayRenderer
        }
    }
    
    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        let image = UIImage(named:"arrowImage.png")
        if headingImageView == nil {
            headingImageView = UIImageView(image: image)
            headingImageView!.frame = CGRect(x: (annotationView.frame.size.width - (image?.size.width)!)/2, y: (annotationView.frame.size.height - (image?.size.height)!)/2, width: (image?.size.width)!, height: (image?.size.height)!)
            annotationView.insertSubview(headingImageView!, at: 0)
            headingImageView!.isHidden = true
        }
    }
    
    func updateHeadingAnnotationRotation() {
        headingImageView?.isHidden = false
        let heading = self.locationManager.heading?.trueHeading
        let rotation = CGFloat(heading! * .pi / 180)
        headingImageView?.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            addHeadingView(toAnnotationView: views.last!)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        //set base graphic
        if annotation is MKPointAnnotation {
            let pin2 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin2")
            pin2.pinTintColor = UIColor.red
            pin2.canShowCallout = true
            return pin2
                }

        //set offense pins to blue color
        if annotation is CustomPinBlue {
            let pin3 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin3")
            pin3.pinTintColor = UIColor.blue
            pin3.canShowCallout = true
            return pin3
        }
        
        if annotation is CustomPinBase {
            let baseDropPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "baseDropPin")
            baseDropPin.canShowCallout = true
            baseDropPin.image = UIImage(named:"basePin.png")
            baseDropPin.frame.size.height = 80
            baseDropPin.frame.size.width = 27
            return baseDropPin
        }
        
        if annotation is CustomPinDrop {
            let minePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "minePin")
            minePin.canShowCallout = true
            minePin.image = UIImage(named:"questionBox.png")
            minePin.frame.size.height = 80
            minePin.frame.size.width = 27
            return minePin
        }
        if annotation is CustomPinScan {
            let scanPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "scanPin")
            scanPin.canShowCallout = true
            scanPin.image = UIImage(named:"radar.png")
            scanPin.frame.size.height = 148
            scanPin.frame.size.width = 150
            return scanPin
        }
        if annotation is CustomPinMine {
            let minePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "minePin")
            minePin.canShowCallout = true
            minePin.image = UIImage(named:"mineSmall.png")
            minePin.frame.size.height = 80
            minePin.frame.size.width = 27
            return minePin
        }
        
        if annotation is CustomPinSupermine {
            let minePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "superminePin")
            minePin.canShowCallout = true
            minePin.image = UIImage(named:"superminePin.png")
            minePin.frame.size.height = 80
            minePin.frame.size.width = 27
            return minePin
        }
        
        if annotation is CustomPinBomb {
            let bombPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bombPin")
            bombPin.canShowCallout = true
            bombPin.image = UIImage(named:"explosion.png")
            bombPin.frame.size.height = 92
            bombPin.frame.size.width = 100
            return bombPin
        }
        
        if annotation is CustomPinSuperbomb {
            let bombPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "superbombPin")
            bombPin.canShowCallout = true
            bombPin.image = UIImage(named:"explosion2.png")
            bombPin.frame.size.height = 151
            bombPin.frame.size.width = 150
            return bombPin
        }
        
        if annotation is CustomPinSpybot {
            let spybotPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "spybotPin")
            spybotPin.canShowCallout = true
            spybotPin.image = UIImage(named:"spybotPin.png")
            spybotPin.frame.size.height = 80
            spybotPin.frame.size.width = 27
            return spybotPin
        }
        
        if annotation is CustomPinBlueperson {
            let bluepersonPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bluepersonPin")
            bluepersonPin.canShowCallout = true
            bluepersonPin.image = UIImage(named:"blueperson.png")
            bluepersonPin.frame.size.height = 80
            bluepersonPin.frame.size.width = 29
            return bluepersonPin
        }
        
        if annotation is CustomPinBluepersonX {
            let bluepersonXPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bluepersonXPin")
            bluepersonXPin.canShowCallout = true
            bluepersonXPin.image = UIImage(named:"bluepersonX.png")
            bluepersonXPin.frame.size.height = 80
            bluepersonXPin.frame.size.width = 29
            return bluepersonXPin
        }
        
        if annotation is CustomPinBluepersonflag {
            let bluepersonflagPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bluepersonflagPin")
            bluepersonflagPin.canShowCallout = true
            bluepersonflagPin.image = UIImage(named:"bluepersonflag.png")
            bluepersonflagPin.frame.size.height = 80
            bluepersonflagPin.frame.size.width = 29
            return bluepersonflagPin
        }
        
        if annotation is CustomPinRedperson {
            let redpersonPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "redpersonPin")
            redpersonPin.canShowCallout = true
            redpersonPin.image = UIImage(named:"redperson.png")
            redpersonPin.frame.size.height = 80
            redpersonPin.frame.size.width = 29
            return redpersonPin
        }
        
        if annotation is CustomPinRedpersonX {
            let redpersonXPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "redpersonXPin")
            redpersonXPin.canShowCallout = true
            redpersonXPin.image = UIImage(named:"redpersonX.png")
            redpersonXPin.frame.size.height = 80
            redpersonXPin.frame.size.width = 29
            return redpersonXPin
        }
        
        //set flag graphic (map annotation)
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.canShowCallout = true
        pin.image = UIImage(named:"robotMapFlag.png")
        pin.frame.size.height = 120
        pin.frame.size.width = 80
        return pin
    }
    
    func gameTimerUpdate() {
        if gameTimerCount > 0 {
            gameTimerCount -= 1
            let min = gameTimerCount / 60
            let sec = gameTimerCount % 60
            var secStr = String(sec)
            if secStr.characters.count == 1 {
                secStr = "0\(secStr)"
            }
            self.timeLabel.text = "\(min):\(secStr)"
            
            //clear the events label after displaying the same text for a few seconds
            if gameTimerCount % 5 == 0 {
                self.eventsLabelCurrent = String(describing: self.eventsLabel.text)
                if self.eventsLabelCurrent == self.eventsLabelLast {
                self.eventsLabelResetCount += 1
                if self.eventsLabelResetCount == 2 {
                    self.eventsLabelResetCount = 0
                    self.eventsLabel.text = ""
                    }
                }
                self.eventsLabelLast = self.eventsLabelCurrent
            }
        }
        if(gameTimerCount == 0) {
            gameWinner = "defense"
            self.endGame()
        }
    }
    
    func itemStateUpdate() {
        if self.jammerCount > 0 {
            self.jammerCount += 1
            if self.jammerCount == JAMMER_DURATION {
                self.jammerCount = 0
            }
        }
        //timer, to indicate to jammer owner when it expires
        if self.ownJammerCount > 0 {
            self.ownJammerCount += 1
            if self.ownJammerCount == JAMMER_DURATION {
                self.ownJammerCount = 0
                self.logEvent("Jammer expired")
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.removeActiveItemImageView(7)
            }
        }
        //timer, to indicate to ghost owner when it expires
        if self.ownGhostCount > 0 {
            self.ownGhostCount += 1
            if self.ownGhostCount == JAMMER_DURATION {
                self.ownGhostCount = 0
                self.logEvent("Ghost expired")
                self.removeActiveItemImageView(12)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
        if self.reachCount > 0 {
            self.reachCount += 1
            if self.reachCount == REACH_DURATION {
                self.reachCount = 0
                self.reachPlayer = 0
            }
        }
        if self.ownReachCount > 0 {
            self.ownReachCount += 1
            if self.ownReachCount == REACH_DURATION {
                self.ownReachCount = 0
                self.logEvent("Reach expired")
                self.removeActiveItemImageView(13)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
        
        //roll for drop
        self.weightedDropRoll()
                
        //pick up item if in region
        var itemPickedUp = false
        let currentCoordinate = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
        if self.drop1Dropped == true  && self.drop1Region.contains(currentCoordinate)  {
            self.drop1Dropped = false
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.remove(self.drop1Circle)
            self.unpostItem(lat: self.drop1Coordinates.latitude)
            itemPickedUp = true
        }
        if self.drop2Dropped == true && self.drop2Region.contains(currentCoordinate) {
            self.drop2Dropped = false
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.remove(self.drop2Circle)
            self.unpostItem(lat: self.drop2Coordinates.latitude)
            itemPickedUp = true
        }
        if self.drop3Dropped == true && self.drop3Region.contains(currentCoordinate) {
            self.drop3Dropped = false
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.remove(self.drop3Circle)
            self.unpostItem(lat: self.drop3Coordinates.latitude)
            itemPickedUp = true
        }
        if self.drop4Dropped == true && self.drop4Region.contains(currentCoordinate) {
            self.drop4Dropped = false
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.remove(self.drop4Circle)
            self.unpostItem(lat: self.drop4Coordinates.latitude)
            itemPickedUp = true
        }
        if self.drop5Dropped == true && self.drop5Region.contains(currentCoordinate) {
            self.drop5Dropped = false
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.remove(self.drop5Circle)
            self.unpostItem(lat: self.drop5Coordinates.latitude)
            itemPickedUp = true
        }
        if itemPickedUp == true {
            self.genItem()
            self.coin?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func captureTimerUpdate() {
        if captureTimerCount > 0 {
            captureTimerCount -= 1
            eventsLabel.text = "Capturing... \(String(captureTimerCount))"
        }
        if captureTimerCount == 0 {
            if playerCapturingPoint == localPlayerPosition && pointCaptureState == "capturing" && localPlayerStatus == 1 {
                SocketIOManager.sharedInstance.postGameEvent(
                    gameID: globalGameID, eventName: "capture", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: "", completionHandler: { (passedCheck) -> Void in
                        if passedCheck {
                            pointCaptureState = "captured"
                            self.updateFlagState()
                            playerCapturingPoint = localPlayerPosition
                            self.flagImageView.isHidden = false // show flag in top right of capturer's screen
                            self.logEvent("Captured the flag! Get back to base")
                            self.captureTimer.invalidate()
                            self.logicCapturing2?.stop()
                            self.logicCapturing2?.currentTime = 0
                            self.logicCapture?.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        } else {
                            pointCaptureState = ""
                            playerCapturingPoint = ""
                            self.displayAlert("Error", message: "You were unable to capture the flag.  Please make sure you have an active network connection.")
                        }
                })
            }
            captureTimerCount = -1
            self.captureTimer.invalidate()
        }
    }
    
    func overlayTimerUpdate() {
        if overlayTimerCount > 0 {
            overlayTimerCount += 1
        }
        if overlayTimerCount == 5 {
            self.mapView.removeAnnotation(self.superbombDropPin)
            self.mapView.removeAnnotation(self.bombDropPin)
            self.mapView.removeAnnotation(self.scanDropPin)
            self.overlayTimerCount = 0
            self.overlayTimer.invalidate()
        }
    }
    
    func tagTimerUpdate() {
        self.tagTimerCount += 1
        if self.tagTimerCount < 10 && self.tagTimerCount % 2 == 0 {
            if globalIsOffense == true {
                self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
            }
            else if globalIsOffense == false {
                self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
            }
            if self.tagTimerCount == 6 {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
        else if self.tagTimerCount < 10 {
            if globalIsOffense == true {
                self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
            }
            else {
                self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
            }
        }
        else {
            self.tagTimer.invalidate()
        }
    }
    
    func defenseRechargeTimerUpdate() {
        if defenseRechargeTimerCount > 0 {
            defenseRechargeTimerCount -= 1
            eventsLabel.text = "Recharging... \(String(defenseRechargeTimerCount))"
        }
        if defenseRechargeTimerCount == 0 {
            localPlayerStatus = 1
            //set the alert icon and label
            if playerCapturingPoint == "" {
                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                self.iconLabel.text = "Flag in place"
            }
            if playerCapturingPoint != "" {
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
            //start broadcasting beacon signal
            self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
            self.defenseRechargeTimer.invalidate()
            self.defenseRechargeTimerCount = -1
            eventsLabel.text = "Recharged!"
        }
    }

    func stateTimerUpdate() {
        if stateTimerCount > 0 {
            stateTimerCount -= 1
        }
        if stateTimerCount == 0 {
            stateUpdate()
            stateTimerCount = STATE_TIMER_CONSTANT
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.tagLocalPlayer()
        self.logicLoseLife?.play()
        displayAlert("App backgrounded", message: "You automatically get tagged when you put the app in the background (to prevent cheating).")
    }
    
    func quitGame() {
        self.backsound?.play()
        let refreshAlert = UIAlertController(title: "Exit game", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.endGame()
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            quittingGame = false
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func itemShopButtonIcon(_ sender: AnyObject) {
        if globalIsOffense == true {
            self.performSegue(withIdentifier: "showOffenseItemShopViewControllerFromGameViewController", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "showDefenseItemShopViewControllerFromGameViewController", sender: nil)
        }
    }
    
    @IBAction func gameMenuButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showGameMenuViewControllerFromGameViewController", sender: nil)
        self.entersoundlow?.play()
    }

    @IBAction func newsButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showEventLogViewControllerFromGameViewController", sender: nil)
        self.entersoundlow?.play()
    }
    
    func tagLocalPlayer() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        localPlayerStatus = 0
        self.tagTimerCount = 1
        self.tagTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(GameViewController.tagTimerUpdate), userInfo: nil, repeats: true)
        self.tagTimer.tolerance = 0.3
        if globalIsOffense {
            if playerCapturingPoint == localPlayerPosition {
                playerCapturingPoint = ""
                pointCaptureState = ""
            }
            self.lifeMeterImageView.image = UIImage(named:"0life.png")
            self.logicCapturing2?.stop()
            self.logicCapturing2?.currentTime = 0
            self.captureTimer.invalidate()
            self.flagImageView.isHidden = true
        } else {
            self.alertIconImageView.image = UIImage(named:"walkIcon.png")
            self.iconLabel.text = "Return to base"
            self.peripheralManager.stopAdvertising()
        }
    }

    func scan(region: CLCircularRegion, circle: MKCircle) {
        if self.jammerCount == 0 {
            //if player is offense, show all defense players in scan region
            if globalIsOffense == true {
                if region.contains(defense1Coordinates) {
                    self.mapView.removeAnnotation(self.defense1DropPin)
                    self.mapView.removeAnnotation(self.defense1XDropPin)
                    if playerStateDict["defense1"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense1DropPin)
                    }
                }
                if region.contains(defense2Coordinates) {
                    self.mapView.removeAnnotation(self.defense2DropPin)
                    self.mapView.removeAnnotation(self.defense2XDropPin)
                    if playerStateDict["defense2"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense2DropPin)
                    }
                }
                if region.contains(defense3Coordinates) {
                    self.mapView.removeAnnotation(self.defense3DropPin)
                    self.mapView.removeAnnotation(self.defense3XDropPin)
                    if playerStateDict["defense3"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense3DropPin)
                    }
                }
                if region.contains(defense4Coordinates) {
                    self.mapView.removeAnnotation(self.defense4DropPin)
                    self.mapView.removeAnnotation(self.defense4XDropPin)
                    if playerStateDict["defense4"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense4DropPin)
                    }
                }
                if region.contains(defense5Coordinates) {
                    self.mapView.removeAnnotation(self.defense5DropPin)
                    self.mapView.removeAnnotation(self.defense5XDropPin)
                    if playerStateDict["defense5"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense5DropPin)
                    }
                }
            //if player is defense, show all offense players in scan region
            } else {
                if region.contains(offense1Coordinates) {
                    self.mapView.removeAnnotation(self.offense1DropPin)
                    self.mapView.removeAnnotation(self.offense1XDropPin)
                    self.mapView.removeAnnotation(self.offense1flagDropPin)
                    
                    if playerCapturingPoint == "offense1" {
                        self.mapView.addAnnotation(self.offense1flagDropPin)
                    }
                    else if playerStateDict["offense1"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense1DropPin)
                    }
                }
                if region.contains(offense2Coordinates) {
                    self.mapView.removeAnnotation(self.offense2DropPin)
                    self.mapView.removeAnnotation(self.offense2XDropPin)
                    self.mapView.removeAnnotation(self.offense2flagDropPin)
                    
                    if playerCapturingPoint == "offense2" {
                        self.mapView.addAnnotation(self.offense2flagDropPin)
                    }
                    else if playerStateDict["offense2"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense2DropPin)
                    }
                }
                if region.contains(offense3Coordinates) {
                    self.mapView.removeAnnotation(self.offense3DropPin)
                    self.mapView.removeAnnotation(self.offense3XDropPin)
                    self.mapView.removeAnnotation(self.offense3flagDropPin)
                    
                    if playerCapturingPoint == "offense3" {
                        self.mapView.addAnnotation(self.offense3flagDropPin)
                    }
                    else if playerStateDict["offense3"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense3DropPin)
                    }
                }
                if region.contains(offense4Coordinates) {
                    self.mapView.removeAnnotation(self.offense4DropPin)
                    self.mapView.removeAnnotation(self.offense4XDropPin)
                    self.mapView.removeAnnotation(self.offense4flagDropPin)
                    
                    if playerCapturingPoint == "offense4" {
                        self.mapView.addAnnotation(self.offense4flagDropPin)
                    }
                    else if playerStateDict["offense4"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense4DropPin)
                    }
                }
                if region.contains(offense5Coordinates) {
                    self.mapView.removeAnnotation(self.offense5DropPin)
                    self.mapView.removeAnnotation(self.offense5XDropPin)
                    self.mapView.removeAnnotation(self.offense5flagDropPin)
                    
                    if playerCapturingPoint == "offense5" {
                        self.mapView.addAnnotation(self.offense5flagDropPin)
                    }
                    else if playerStateDict["offense5"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense5DropPin)
                    }
                }
            }
        }
    }
    
    func lightningScan() {
        if self.offense1Lat != 0 {
            self.mapView.removeAnnotation(self.offense1DropPin)
            self.mapView.removeAnnotation(self.offense1XDropPin)
            self.mapView.removeAnnotation(self.offense1flagDropPin)
            self.mapView.addAnnotation(self.offense1XDropPin)
        }
        if self.offense2Lat != 0 {
            self.mapView.removeAnnotation(self.offense2DropPin)
            self.mapView.removeAnnotation(self.offense2XDropPin)
            self.mapView.removeAnnotation(self.offense2flagDropPin)
            self.mapView.addAnnotation(self.offense2XDropPin)
        }
        if self.offense3Lat != 0 {
            self.mapView.removeAnnotation(self.offense3DropPin)
            self.mapView.removeAnnotation(self.offense3XDropPin)
            self.mapView.removeAnnotation(self.offense3flagDropPin)
            self.mapView.addAnnotation(self.offense3XDropPin)
        }
        if self.offense4Lat != 0 {
            self.mapView.removeAnnotation(self.offense4DropPin)
            self.mapView.removeAnnotation(self.offense4XDropPin)
            self.mapView.removeAnnotation(self.offense4flagDropPin)
            self.mapView.addAnnotation(self.offense4XDropPin)
        }
        if self.offense5Lat != 0 {
            self.mapView.removeAnnotation(self.offense5DropPin)
            self.mapView.removeAnnotation(self.offense5XDropPin)
            self.mapView.removeAnnotation(self.offense5flagDropPin)
            self.mapView.addAnnotation(self.offense5XDropPin)
        }
    }
    
    func superscan() {
        if self.jammerCount == 0 {
            //if player is offense, show all defense players
            if globalIsOffense == true {
                if playerStateDict["defense1"] != nil {
                    self.mapView.removeAnnotation(self.defense1DropPin)
                    self.mapView.removeAnnotation(self.defense1XDropPin)
                    if playerStateDict["defense1"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense1DropPin)
                    }
                }
                if playerStateDict["defense2"] != nil {
                    self.mapView.removeAnnotation(self.defense2DropPin)
                    self.mapView.removeAnnotation(self.defense2XDropPin)
                    if playerStateDict["defense2"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense2DropPin)
                    }
                }
                if playerStateDict["defense3"] != nil {
                    self.mapView.removeAnnotation(self.defense3DropPin)
                    self.mapView.removeAnnotation(self.defense3XDropPin)
                    if playerStateDict["defense3"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense3DropPin)
                    }
                }
                if playerStateDict["defense4"] != nil {
                    self.mapView.removeAnnotation(self.defense4DropPin)
                    self.mapView.removeAnnotation(self.defense4XDropPin)
                    if playerStateDict["defense4"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense4DropPin)
                    }
                }
                if playerStateDict["defense5"] != nil {
                    self.mapView.removeAnnotation(self.defense5DropPin)
                    self.mapView.removeAnnotation(self.defense5XDropPin)
                    if playerStateDict["defense5"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense5DropPin)
                    }
                }
            } else {
                if playerStateDict["offense1"] != nil {
                    self.mapView.removeAnnotation(self.offense1DropPin)
                    self.mapView.removeAnnotation(self.offense1XDropPin)
                    self.mapView.removeAnnotation(self.offense1flagDropPin)
                    if playerCapturingPoint == "offense1" {
                        self.mapView.addAnnotation(self.offense1flagDropPin)
                    }
                    else if playerStateDict["offense1"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense1DropPin)
                    }
                }
                if playerStateDict["offense2"] != nil {
                    self.mapView.removeAnnotation(self.offense2DropPin)
                    self.mapView.removeAnnotation(self.offense2XDropPin)
                    self.mapView.removeAnnotation(self.offense2flagDropPin)
                    if playerCapturingPoint == "offense2" {
                        self.mapView.addAnnotation(self.offense2flagDropPin)
                    }
                    else if playerStateDict["offense2"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense2DropPin)
                    }
                }
                if playerStateDict["offense3"] != nil {
                    self.mapView.removeAnnotation(self.offense3DropPin)
                    self.mapView.removeAnnotation(self.offense3XDropPin)
                    self.mapView.removeAnnotation(self.offense3flagDropPin)
                    if playerCapturingPoint == "offense3" {
                        self.mapView.addAnnotation(self.offense3flagDropPin)
                    }
                    else if playerStateDict["offense3"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense3DropPin)
                    }
                }
                if playerStateDict["offense4"] != nil {
                    self.mapView.removeAnnotation(self.offense4DropPin)
                    self.mapView.removeAnnotation(self.offense4XDropPin)
                    self.mapView.removeAnnotation(self.offense4flagDropPin)
                    if playerCapturingPoint == "offense4" {
                        self.mapView.addAnnotation(self.offense4flagDropPin)
                    }
                    else if playerStateDict["offense4"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense4DropPin)
                    }
                }
                if playerStateDict["offense5"] != nil {
                    self.mapView.removeAnnotation(self.offense5DropPin)
                    self.mapView.removeAnnotation(self.offense5XDropPin)
                    self.mapView.removeAnnotation(self.offense5flagDropPin)
                    if playerCapturingPoint == "offense5" {
                        self.mapView.addAnnotation(self.offense5flagDropPin)
                    }
                    else if playerStateDict["offense5"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense5DropPin)
                    }
                }
            }
        }
    }
    
    func dropSpybot(latitude: Double, longitude: Double, player: String) {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if self.spybot1Dropped == false || (self.firstSpybotDropped != 1 && self.secondSpybotDropped != 1) {
            self.spybotsound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.spybot1Count = 1
            self.mapView.removeAnnotation(self.spybot1DropPin)
            self.mapView.remove(self.spybot1Circle)
            self.spybot1Dropped = true
            self.spybot1DropPin = CustomPinSpybot(coordinate: coord, title: "\(player)'s spybot")
            self.mapView.addAnnotation(self.spybot1DropPin)
            self.spybot1Region = CLCircularRegion(center: coord, radius: CLLocationDistance(15), identifier: "")
            self.spybot1Circle = MKCircle(center: coord, radius: CLLocationDistance(15))
            self.mapView.add(self.spybot1Circle)
            self.secondSpybotDropped = self.firstSpybotDropped
            self.firstSpybotDropped = 1
            self.logEvent("Spybot planted!")
            self.spybot()
        }
        else if self.spybot2Dropped == false || (self.firstSpybotDropped != 2 && self.secondSpybotDropped != 2) {
            self.spybotsound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.spybot2Count = 1
            self.mapView.removeAnnotation(self.spybot2DropPin)
            self.mapView.remove(self.spybot2Circle)
            self.spybot2Dropped = true
            self.spybot2DropPin = CustomPinSpybot(coordinate: coord, title: "\(player)'s spybot")
            self.mapView.addAnnotation(self.spybot2DropPin)
            self.spybot2Region = CLCircularRegion(center: coord, radius: CLLocationDistance(15), identifier: "")
            self.spybot2Circle = MKCircle(center: coord, radius: CLLocationDistance(15))
            self.mapView.add(self.spybot2Circle)
            self.secondSpybotDropped = self.firstSpybotDropped
            self.firstSpybotDropped = 2
            self.logEvent("Spybot planted!")
            self.spybot()
        }
        else if self.spybot3Dropped == false || (self.firstSpybotDropped != 3 && self.secondSpybotDropped != 3) {
            self.spybotsound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.spybot3Count = 1
            self.mapView.removeAnnotation(self.spybot3DropPin)
            self.mapView.remove(self.spybot3Circle)
            self.spybot3Dropped = true
            self.spybot3DropPin = CustomPinSpybot(coordinate: coord, title: "\(player)'s spybot")
            self.mapView.addAnnotation(self.spybot3DropPin)
            self.spybot3Region = CLCircularRegion(center: coord, radius: CLLocationDistance(15), identifier: "")
            self.spybot3Circle = MKCircle(center: coord, radius: CLLocationDistance(15))
            self.mapView.add(self.spybot3Circle)
            self.secondSpybotDropped = self.firstSpybotDropped
            self.firstSpybotDropped = 3
            self.logEvent("Spybot planted!")
            self.spybot()
        }
    }
    
    func spybot() {
        if self.jammerCount == 0 {
            if globalIsOffense == true {
                if self.spybot1Region.contains(self.defense1Coordinates) || self.spybot2Region.contains(self.defense1Coordinates) || self.spybot3Region.contains(self.defense1Coordinates) {
                    self.mapView.removeAnnotation(self.defense1DropPin)
                    self.mapView.removeAnnotation(self.defense1XDropPin)
                    if playerStateDict["defense1"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense1DropPin)
                    }
                }
                if self.spybot1Region.contains(self.defense2Coordinates) || self.spybot2Region.contains(self.defense2Coordinates) || self.spybot3Region.contains(self.defense2Coordinates)  {
                    self.mapView.removeAnnotation(self.defense2DropPin)
                    self.mapView.removeAnnotation(self.defense2XDropPin)
                    if playerStateDict["defense2"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense2DropPin)
                    }
                }
                if self.spybot1Region.contains(self.defense3Coordinates) || self.spybot2Region.contains(self.defense3Coordinates) || self.spybot3Region.contains(self.defense3Coordinates) {
                    self.mapView.removeAnnotation(self.defense3DropPin)
                    self.mapView.removeAnnotation(self.defense3XDropPin)
                    if playerStateDict["defense3"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense3DropPin)
                    }
                }
                if self.spybot1Region.contains(self.defense4Coordinates) || self.spybot2Region.contains(self.defense4Coordinates) || self.spybot3Region.contains(self.defense4Coordinates) {
                    self.mapView.removeAnnotation(self.defense4DropPin)
                    self.mapView.removeAnnotation(self.defense4XDropPin)
                    if playerStateDict["defense4"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense4DropPin)
                    }
                }
                if self.spybot1Region.contains(self.defense5Coordinates) || self.spybot2Region.contains(self.defense5Coordinates) || self.spybot3Region.contains(self.defense5Coordinates) {
                    self.mapView.removeAnnotation(self.defense5DropPin)
                    self.mapView.removeAnnotation(self.defense5XDropPin)
                    if playerStateDict["defense5"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.defense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense5DropPin)
                    }
                }
            }
            if globalIsOffense == false {
                if self.spybot1Region.contains(self.offense1Coordinates) || self.spybot2Region.contains(self.offense1Coordinates) || self.spybot3Region.contains(self.offense1Coordinates) {
                    self.mapView.removeAnnotation(self.offense1DropPin)
                    self.mapView.removeAnnotation(self.offense1XDropPin)
                    self.mapView.removeAnnotation(self.offense1flagDropPin)
                    if playerCapturingPoint == "offense1" {
                        self.mapView.addAnnotation(self.offense1flagDropPin)
                    }
                    else if playerStateDict["offense1"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense1DropPin)
                    }
                }
                if self.spybot1Region.contains(self.offense2Coordinates) || self.spybot2Region.contains(self.offense2Coordinates) || self.spybot3Region.contains(self.offense2Coordinates) {
                    self.mapView.removeAnnotation(self.offense2DropPin)
                    self.mapView.removeAnnotation(self.offense2XDropPin)
                    self.mapView.removeAnnotation(self.offense2flagDropPin)
                    if playerCapturingPoint == "offense2" {
                        self.mapView.addAnnotation(self.offense2flagDropPin)
                    }
                    else if playerStateDict["offense2"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense2DropPin)
                    }
                }
                if self.spybot1Region.contains(self.offense3Coordinates) || self.spybot2Region.contains(self.offense3Coordinates) || self.spybot3Region.contains(self.offense3Coordinates) {
                    self.mapView.removeAnnotation(self.offense3DropPin)
                    self.mapView.removeAnnotation(self.offense3XDropPin)
                    self.mapView.removeAnnotation(self.offense3flagDropPin)
                    if playerCapturingPoint == "offense3" {
                        self.mapView.addAnnotation(self.offense3flagDropPin)
                    }
                    else if playerStateDict["offense3"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense3DropPin)
                    }
                }
                if self.spybot1Region.contains(self.offense4Coordinates) || self.spybot2Region.contains(self.offense4Coordinates) || self.spybot3Region.contains(self.offense4Coordinates) {
                    self.mapView.removeAnnotation(self.offense4DropPin)
                    self.mapView.removeAnnotation(self.offense4XDropPin)
                    self.mapView.removeAnnotation(self.offense4flagDropPin)
                    if playerCapturingPoint == "offense4" {
                        self.mapView.addAnnotation(self.offense4flagDropPin)
                    }
                    else if playerStateDict["offense4"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense4DropPin)
                    }
                }
                if self.spybot1Region.contains(self.offense5Coordinates) || self.spybot2Region.contains(self.offense5Coordinates) || self.spybot3Region.contains(self.offense5Coordinates) {
                    self.mapView.removeAnnotation(self.offense5DropPin)
                    self.mapView.removeAnnotation(self.offense5XDropPin)
                    self.mapView.removeAnnotation(self.offense5flagDropPin)
                    if playerCapturingPoint == "offense5" {
                        self.mapView.addAnnotation(self.offense5flagDropPin)
                    }
                    else if playerStateDict["offense5"]!["status"] as! Int == 0 {
                        self.mapView.addAnnotation(self.offense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense5DropPin)
                    }
                }
            }
        }
    }
    
    func heal() {
        if localPlayerStatus != 2 {
            localPlayerStatus = 1
            self.alertIconImageView.isHidden = true
            self.iconLabel.isHidden = true
            self.lifeMeterImageView.isHidden = false
            self.lifeMeterImageView.image = UIImage(named:"5life.png")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
        }
    }
    
    func showItemView() {
        self.entersoundlow?.play()
        self.itemViewHidden = false
        self.targetImageView.isHidden = true
        self.itemButtonBackdropImageView.isHidden = false
        self.itemLabelIconImageView.isHidden = false
        self.itemLabel.isHidden = false
        self.useButtonOutlet.isHidden = false
        self.helpButtonOutlet.isHidden = false
        self.cancelButtonOutlet.isHidden = false
        self.exitItemMapView()
    }
    
    func hideItemView() {
        self.itemViewHidden = true
        self.targetImageView.isHidden = true
        self.itemButtonBackdropImageView.isHidden = true
        self.itemLabelIconImageView.isHidden = true
        self.itemLabel.isHidden = true
        self.useButtonOutlet.isHidden = true
        self.helpButtonOutlet.isHidden = true
        self.cancelButtonOutlet.isHidden = true
    }
    
    func showTargetItemView() {
        self.showtargetimageview?.play()
        let center = mapView.camera.centerCoordinate
        let mapCamera2 = MKMapCamera(lookingAtCenter: center, fromDistance: 225, pitch: 0, heading: (self.locationManager.heading?.trueHeading)!)
        self.mapView.setCamera(mapCamera2, animated: true)
        self.enterItemMapView()
        self.targetImageView.image = UIImage(named:"target.png")
        self.itemViewHidden = false
        self.targetImageView.isHidden = false
        self.itemButtonBackdropImageView.isHidden = false
        self.itemLabelIconImageView.isHidden = false
        self.itemLabel.isHidden = false
        self.useButtonOutlet.isHidden = false
        self.helpButtonOutlet.isHidden = false
        self.cancelButtonOutlet.isHidden = false
    }
    
    func showRadarItemView() {
        self.showtargetimageview?.play()
        let center = mapView.camera.centerCoordinate
        let heading = mapView.camera.heading
        let mapCamera2 = MKMapCamera(lookingAtCenter: center, fromDistance: 225, pitch: 0, heading: (self.locationManager.heading?.trueHeading)!)
        self.mapView.setCamera(mapCamera2, animated: true)
        self.enterItemMapView()
        self.targetImageView.image = UIImage(named:"radar.png")
        self.itemViewHidden = false
        self.targetImageView.isHidden = false
        self.itemButtonBackdropImageView.isHidden = false
        self.itemLabelIconImageView.isHidden = false
        self.itemLabel.isHidden = false
        self.useButtonOutlet.isHidden = false
        self.helpButtonOutlet.isHidden = false
        self.cancelButtonOutlet.isHidden = false
    }
    
    func showSpybotItemView() {
        self.showtargetimageview?.play()
        let center = mapView.camera.centerCoordinate
        let heading = mapView.camera.heading
        let mapCamera2 = MKMapCamera(lookingAtCenter: center, fromDistance: 225, pitch: 0, heading: (self.locationManager.heading?.trueHeading)!)
        self.mapView.setCamera(mapCamera2, animated: true)
        self.enterItemMapView()
        self.targetImageView.image = UIImage(named:"spybotoverlay.png")
        self.itemViewHidden = false
        self.targetImageView.isHidden = false
        self.itemButtonBackdropImageView.isHidden = false
        self.itemLabelIconImageView.isHidden = false
        self.itemLabel.isHidden = false
        self.useButtonOutlet.isHidden = false
        self.helpButtonOutlet.isHidden = false
        self.cancelButtonOutlet.isHidden = false
    }
    
    func clearAfterUse() {
        self.exitItemMapView()
        self.itemViewHidden = true
        self.targetImageView.isHidden = true
        self.itemButtonBackdropImageView.isHidden = true
        self.itemLabelIconImageView.isHidden = true
        self.itemLabel.isHidden = true
        self.useButtonOutlet.isHidden = true
        self.helpButtonOutlet.isHidden = true
        self.cancelButtonOutlet.isHidden = true
        if self.activePowerupSlot == 1 {
            self.powerup1ButtonOutlet.setImage(UIImage(named: "emptyBox.png") as UIImage?, for: UIControlState())
            slot1Powerup = 0
        }
        if self.activePowerupSlot == 2 {
            self.powerup2ButtonOutlet.setImage(UIImage(named: "emptyBox.png") as UIImage?, for: UIControlState())
            slot2Powerup = 0
        }
        if self.activePowerupSlot == 3 {
            self.powerup3ButtonOutlet.setImage(UIImage(named: "emptyBox.png") as UIImage?, for: UIControlState())
            slot3Powerup = 0
        }
        self.activePowerupSlot = 0
        activePowerup = 0
    }
    
    func showCapturer() {
        if playerCapturingPoint == "offense1" {
            self.mapView.addAnnotation(self.offense1flagDropPin)
        }
        if playerCapturingPoint == "offense2" {
            self.mapView.addAnnotation(self.offense2flagDropPin)
        }
        if playerCapturingPoint == "offense3" {
            self.mapView.addAnnotation(self.offense3flagDropPin)
        }
        if playerCapturingPoint == "offense4" {
            self.mapView.addAnnotation(self.offense4flagDropPin)
        }
        if playerCapturingPoint == "offense5" {
            self.mapView.addAnnotation(self.offense5flagDropPin)
        }
    }
    
    func refreshItems() {
        self.fundsLabel.text = "\(currentFunds)"
        print("SLOT ! PO", slot1Powerup)
        if slot1Powerup == 0 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"emptyBox.png"), for: UIControlState())
        }
        self.powerup1ButtonOutlet.setImage(UIImage(named: getPowerupImage(powerup: slot1Powerup)), for: UIControlState())
        self.powerup2ButtonOutlet.setImage(UIImage(named: getPowerupImage(powerup: slot2Powerup)), for: UIControlState())
        self.powerup3ButtonOutlet.setImage(UIImage(named: getPowerupImage(powerup: slot3Powerup)), for: UIControlState())
    }
    
    func weightedDropRoll() {
        var itemAbundance = defenseAbundance
        if globalIsOffense {
            itemAbundance = offenseAbundance
        }
        if self.drop1Dropped == false || self.drop2Dropped == false || self.drop3Dropped == false || self.drop4Dropped == false || self.drop5Dropped == false {
                //item abundance 1 -  ~5.8min av
            if itemAbundance == 1 {
                dropRoll(odds: 600 / STATE_TIMER_INTERVAL)
            }
                //item abundance 2 -  ~2.9min av
            else if itemAbundance == 2 {
                dropRoll(odds: 300 / STATE_TIMER_INTERVAL)
            }
                //item abundance 3 -  ~1.9min av
            else if itemAbundance == 3 {
                dropRoll(odds: 192 / STATE_TIMER_INTERVAL)
            }
                //item abundance 4 -  ~1.1 min av
            else if itemAbundance == 4 {
                dropRoll(odds: 120 / STATE_TIMER_INTERVAL)
            }
                //item abundance 5 -  ~.65 min av
            else if itemAbundance == 5 {
                dropRoll(odds: 72 / STATE_TIMER_INTERVAL)
            }
        } else {
                //item abundance 1
            if itemAbundance == 1 {
                dropRoll(odds: 720 / STATE_TIMER_INTERVAL)
            }
                //item abundance 2
            else if itemAbundance == 2 {
                dropRoll(odds: 530 / STATE_TIMER_INTERVAL)
            }
                //item abundance 3
            else if itemAbundance == 3 {
                dropRoll(odds: 480 / STATE_TIMER_INTERVAL)
            }
                //item abundance 4
            else if itemAbundance == 4 {
                dropRoll(odds: 360 / STATE_TIMER_INTERVAL)
            }
                //item abundance 5
            else if itemAbundance == 5 {
                dropRoll(odds: 360 / STATE_TIMER_INTERVAL)
            }
        }
    }
    
    func dropRoll(odds: Int) {
        let odds2 = UInt32(odds)
        let roll = Int(arc4random_uniform(odds2) + 1)
        if roll == 2  && itemModeOn == true {
            let roll2 = Int(arc4random_uniform(15) + 1)
            if roll2 == 5 {
                genItem()
                self.directitem?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            } else {
                rollItemLocation()
            }
        }
        if roll == 2  && itemModeOn == false {
            genItem()
            self.directitem?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func genItem() {
        let roll = Int(arc4random_uniform(55) + 1)
        if roll >= 1 && roll <= 8 {
            if itemsDisabled[0] == false {
                placeItem(1) }
            else { genItem() }
        }
        if roll >= 7 && roll <= 10  {
            if itemsDisabled[1] == false {
                placeItem(2) }
            else { genItem() }
        }
        if roll >= 11 && roll <= 14  {
            if itemsDisabled[2] == false {
                placeItem(3) }
            else { genItem() }
        }
        if roll >= 15 && roll <= 16 {
            if itemsDisabled[3] == false {
                placeItem(4) }
            else { genItem() }
        }
        if roll >= 17 && roll <= 20 {
            if itemsDisabled[4] == false {
                placeItem(5) }
            else { genItem() }
        }
        if roll >= 21 && roll <= 22 {
            if itemsDisabled[5] == false {
                placeItem(6) }
            else { genItem() }
        }
        if roll >= 23 && roll <= 25 {
            if itemsDisabled[6] == false {
                placeItem(7) }
            else { genItem() }
        }
        if roll >= 26 && roll <= 29 {
            if itemsDisabled[7] == false {
                placeItem(8) }
            else { genItem() }
        }
        if globalIsOffense == true {
            if roll >= 30 && roll <= 33 {
                if itemsDisabled[8] == false {
                    placeItem(9) }
                else { genItem() }
            }
            if roll >= 34 && roll <= 35 {
                if itemsDisabled[9] == false {
                    placeItem(10) }
                else { genItem() }
            }
            if roll >= 36 && roll <= 38 {
                if itemsDisabled[10] == false {
                    placeItem(11) }
                else { genItem() }
            }
            if roll == 39 {
                if itemsDisabled[11] == false {
                    placeItem(12) }
                else { genItem() }
            }
        }
        if globalIsOffense == false {
            if roll >= 30 && roll <= 32 {
                if itemsDisabled[12] == false {
                    placeItem(13) }
                else { genItem() }
            }
            if roll >= 33 && roll <= 35 {
                if itemsDisabled[13] == false {
                    placeItem(14) }
                else { genItem() }
            }
            if roll >= 36 && roll <= 37 {
                if itemsDisabled[14] == false {
                    placeItem(15) }
                else { genItem() }
            }
            if roll == 38 {
                if itemsDisabled[15] == false {
                    placeItem(16) }
                else { genItem() }
            }
            if roll == 39 {
                self.logEvent("Got cash!")
                let roll = Int(arc4random_uniform(10) + 1)
                currentFunds = currentFunds + roll
            }
        }
        if roll >= 40 && roll <= 49 {
            self.logEvent("Got cash!")
            let roll = Int(arc4random_uniform(8) + 1)
            currentFunds = currentFunds + roll
        }
        if roll >= 50 && roll <= 55 {
            self.logEvent("Got cash!")
            let roll = Int(arc4random_uniform(20) + 1)
            currentFunds = currentFunds + roll
        }
    }
    
    func placeItem(_ item: Int) {
        if slot1Powerup == 0 {
            self.logEvent("Got an item!")
            slot1Powerup = item
            self.refreshItems()
        }
        else if slot2Powerup == 0 {
            self.logEvent("Got an item!")
            slot2Powerup = item
            self.refreshItems()
        }
        else if slot3Powerup == 0 {
            self.logEvent("Got an item!")
            slot3Powerup = item
            self.refreshItems()
        }
        else {
            self.logEvent("Items full, got cash!")
            let roll = Int(arc4random_uniform(10) + 1)
            currentFunds = currentFunds + roll
            self.refreshItems()
        }
    }

    func rollItemLocation() {
        var xx = drand48()
        let yy = Int(arc4random_uniform(2) + 1)
        if yy == 1 {
            xx = xx * -1
        }
        var aa = drand48()
        let bb = Int(arc4random_uniform(2) + 1)
        if bb == 1 {
            aa = aa * -1
        }
        let randLat: Double = Double((xx * self.basePointDistance) + self.mapCenterPointLat)
        let randLatTruncated = String(randLat).trunc(15)
        let randLatTDouble = Double(randLatTruncated)
        let randLong: Double = Double((aa * self.basePointDistance) + self.mapCenterPointLong)
        let randLongTruncated = String(randLong).trunc(15)
        let randLongTDouble = Double(randLongTruncated)
        if globalIsOffense == false && self.baseRegion.contains(CLLocationCoordinate2D(latitude: randLatTDouble!, longitude: randLongTDouble!)) {
            self.rollItemLocation()
        } else {
            self.postItem(lat: randLatTDouble!, long: randLongTDouble!)
        }
    }
    
    func updateDropOrder(droppedItem: Int) {
        self.fourthDropped = self.thirdDropped
        self.thirdDropped = self.secondDropped
        self.secondDropped = self.firstDropped
        self.firstDropped = droppedItem
    }
    
    func isReplaceCandidate(dropSlot: Int) -> Bool {
        return (self.firstDropped != dropSlot && self.secondDropped != dropSlot && self.thirdDropped != dropSlot && self.fourthDropped != dropSlot)
    }
    
    func mapItem(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.itemdrop?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if self.drop1Dropped == false || self.isReplaceCandidate(dropSlot: 1) {
            self.drop1Dropped = true
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.remove(self.drop1Circle)
            self.drop1DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop1Coordinates = coord
            self.mapView.addAnnotation(self.drop1DropPin)
            self.drop1Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop1Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            self.mapView.add(self.drop1Circle)
            self.updateDropOrder(droppedItem: 1)
        }
        else if self.drop2Dropped == false || self.isReplaceCandidate(dropSlot: 2) {
            self.drop2Dropped = true
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.remove(self.drop2Circle)
            self.drop2DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop2Coordinates = coord
            self.mapView.addAnnotation(self.drop2DropPin)
            self.drop2Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop2Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            self.mapView.add(self.drop2Circle)
            self.updateDropOrder(droppedItem: 2)
        }
        else if self.drop3Dropped == false || self.isReplaceCandidate(dropSlot: 3) {
            self.drop3Dropped = true
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.remove(self.drop3Circle)
            self.drop3DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop3Coordinates = coord
            self.mapView.addAnnotation(self.drop3DropPin)
            self.drop3Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop3Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            self.mapView.add(self.drop3Circle)
            self.updateDropOrder(droppedItem: 3)
        }
        else if self.drop4Dropped == false || self.isReplaceCandidate(dropSlot: 4) {
            self.drop4Dropped = true
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.remove(self.drop4Circle)
            self.drop4DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop4Coordinates = coord
            self.mapView.addAnnotation(self.drop4DropPin)
            self.drop4Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop4Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            self.mapView.add(self.drop4Circle)
            self.updateDropOrder(droppedItem: 4)
        }
        else if self.drop5Dropped == false || self.isReplaceCandidate(dropSlot: 5) {
            self.drop5Dropped = true
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.remove(self.drop5Circle)
            self.drop5DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop5Coordinates = coord
            self.mapView.addAnnotation(self.drop5DropPin)
            self.drop5Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop5Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            self.mapView.add(self.drop5Circle)
            self.updateDropOrder(droppedItem: 5)
        }
    }
    
    func dropMine(latitude: Double, longitude: Double, isSuper: Bool) {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if self.mine1Dropped == false || (self.firstMineDropped != 1 && self.secondMineDropped != 1) {
            self.mine1Dropped = true
            self.secondMineDropped = self.firstMineDropped
            self.firstMineDropped = 1
            self.mine1isSuper = isSuper
            if isSuper == false {
                self.mine1DropPin.coordinate = coord
                self.mine1DropPin.title = "Mine"
                self.mapView.addAnnotation(self.mine1DropPin)
                self.mine1region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "mine1region")
                self.mine1Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.supermine1DropPin.coordinate = coord
                self.supermine1DropPin.title = "Supermine"
                self.mapView.addAnnotation(self.supermine1DropPin)
                self.mine1region = CLCircularRegion(center: coord, radius: CLLocationDistance(9), identifier: "supermine1region")
                self.mine1Circle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine1Circle)
        }
        
        else if self.mine2Dropped == false || (self.firstMineDropped != 2 && self.secondMineDropped != 2) {
            self.mine2Dropped = true
            self.secondMineDropped = self.firstMineDropped
            self.firstMineDropped = 2
            self.mine2isSuper = isSuper
            if isSuper == false {
                self.mine2DropPin.coordinate = coord
                self.mine2DropPin.title = "Mine"
                self.mapView.addAnnotation(self.mine2DropPin)
                self.mine2region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "mine2region")
                self.mine2Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.supermine2DropPin.coordinate = coord
                self.supermine2DropPin.title = "Supermine"
                self.mapView.addAnnotation(self.supermine2DropPin)
                self.mine2region = CLCircularRegion(center: coord, radius: CLLocationDistance(9), identifier: "supermine2region")
                self.mine2Circle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine2Circle)
        }
        
        else if self.mine3Dropped == false || (self.firstMineDropped != 3 && self.secondMineDropped != 3) {
            self.mine3Dropped = true
            self.secondMineDropped = self.firstMineDropped
            self.firstMineDropped = 3
            self.mine3isSuper = isSuper
            if isSuper == false {
                self.mine3DropPin.coordinate = coord
                self.mine3DropPin.title = "Mine"
                self.mapView.addAnnotation(self.mine3DropPin)
                self.mine3region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "mine3region")
                self.mine3Circle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.supermine3DropPin.coordinate = coord
                self.supermine3DropPin.title = "Supermine"
                self.mapView.addAnnotation(self.supermine3DropPin)
                self.mine3region = CLCircularRegion(center: coord, radius: CLLocationDistance(9), identifier: "supermine3region")
                self.mine3Circle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine3Circle)
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.setmine?.play()
    }
    
    func dropMineView(latitude: Double, longitude: Double, isSuper: Bool, player: String) {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if self.mine1VDropped == false || (self.firstMineVDropped != 1 && self.secondMineVDropped != 1 && self.thirdMineVDropped != 1 && self.fourthMineVDropped != 1) {
            self.mine1VDropped = true
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine1VDropPin)
            self.mapView.removeAnnotation(self.supermine1VDropPin)
            self.mapView.remove(self.mine1VCircle)
            if isSuper == false {
                self.mine1VisSuper = false
                self.mine1VDropPin.coordinate = coord
                self.mine1VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine1VDropPin)
                self.mine1VCircle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            else {
                self.mine1VisSuper = true
                self.supermine1VDropPin.coordinate = coord
                self.supermine1VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine1VDropPin)
                self.mine1VCircle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine1VCircle)
        }
        else if self.mine2VDropped == false || (self.firstMineVDropped != 2 && self.secondMineVDropped != 2 && self.thirdMineVDropped != 2 && self.fourthMineVDropped != 2) {
            self.mine2VDropped = true
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine2VDropPin)
            self.mapView.removeAnnotation(self.supermine2VDropPin)
            self.mapView.remove(self.mine2VCircle)
            if isSuper == false {
                self.mine2VisSuper = false
                self.mine2VDropPin.coordinate = coord
                self.mine2VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine2VDropPin)
                self.mine2VCircle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.mine2VisSuper = true
                self.supermine2VDropPin.coordinate = coord
                self.supermine2VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine2VDropPin)
                self.mine2VCircle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine2VCircle)
        }
        else if self.mine3VDropped == false || (self.firstMineVDropped != 3 && self.secondMineVDropped != 3 && self.thirdMineVDropped != 3 && self.fourthMineVDropped != 3) {
            self.mine3VDropped = true
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine3VDropPin)
            self.mapView.removeAnnotation(self.supermine3VDropPin)
            self.mapView.remove(self.mine3VCircle)
            if isSuper == false {
                self.mine3VisSuper = false
                self.mine3VDropPin.coordinate = coord
                self.mine3VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine3VDropPin)
                self.mine3VCircle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.mine3VisSuper = true
                self.supermine3VDropPin.coordinate = coord
                self.supermine3VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine3VDropPin)
                self.mine3VCircle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine3VCircle)
        }
        else if self.mine4VDropped == false || (self.firstMineVDropped != 4 && self.secondMineVDropped != 4 && self.thirdMineVDropped != 4 && self.fourthMineVDropped != 4) {
            self.mine4VDropped = true
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine4VDropPin)
            self.mapView.removeAnnotation(self.supermine4VDropPin)
            self.mapView.remove(self.mine4VCircle)
            if isSuper == false {
                self.mine4VisSuper = false
                self.mine4VDropPin.coordinate = coord
                self.mine4VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine4VDropPin)
                self.mine4VCircle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.mine4VisSuper = true
                self.supermine4VDropPin.coordinate = coord
                self.supermine4VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine4VDropPin)
                self.mine4VCircle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine4VCircle)
        }
        else if self.mine5VDropped == false || (self.firstMineVDropped != 5 && self.secondMineVDropped != 5 && self.thirdMineVDropped != 5 && self.fourthMineVDropped != 5) {
            self.mine5VDropped = true
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine5VDropPin)
            self.mapView.removeAnnotation(self.supermine5VDropPin)
            self.mapView.remove(self.mine5VCircle)
            if isSuper == false {
                self.mine5VisSuper = false
                self.mine5VDropPin.coordinate = coord
                self.mine5VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine5VDropPin)
                self.mine5VCircle = MKCircle(center: coord, radius: CLLocationDistance(5))
            }
            if isSuper == true {
                self.mine5VisSuper = true
                self.supermine5VDropPin.coordinate = coord
                self.supermine5VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine5VDropPin)
                self.mine5VCircle = MKCircle(center: coord, radius: CLLocationDistance(9))
            }
            self.mapView.add(self.mine5VCircle)
        }
        else {
            return
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.setmine?.play()
    }
    
    func postItem(lat: Double, long: Double) {
        var recipient = "offense"
        if globalIsOffense == false {
            recipient = "defense"
        }
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "item_post", sender: localPlayerPosition, recipient: recipient, latitude: lat, longitude: long, extra: "", timingOut: 10, completionHandler: { (didPost) -> Void in
        })
    }
    
    func unpostItem(lat: Double) {
        var recipient = "offense"
        if globalIsOffense == false {
            recipient = "defense"
        }
        SocketIOManager.sharedInstance.postGameEvent(
            gameID: globalGameID, eventName: "item_unpost", sender: localPlayerPosition, recipient: recipient, latitude: lat, longitude: 0, extra: "", timingOut: 25, completionHandler: { (didPost) -> Void in
        })
    }
    
    func logEvent(_ event: String) {
        self.eventsLabel.text = event
        eventsArray.insert(event, at: 0)
        eventsArray.insert(String(gameTimerCount), at: 0)
        if eventsArray.count >= 25 {
            eventsArray.remove(at: 25)
            eventsArray.remove(at: 24)
        }
    }
    
    func revealTagee(_ tagee: String) {
        if tagee == globalPlayerNamesDict["defense1"]! {
            self.mapView.removeAnnotation(self.defense1DropPin)
            self.mapView.removeAnnotation(self.defense1XDropPin)
            self.mapView.addAnnotation(self.defense1XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 6
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 6
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 6
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["defense2"]! {
            self.mapView.removeAnnotation(self.defense2DropPin)
            self.mapView.removeAnnotation(self.defense2XDropPin)
            self.mapView.addAnnotation(self.defense2XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 7
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 7
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 7
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["defense3"]! {
            self.mapView.removeAnnotation(self.defense3DropPin)
            self.mapView.removeAnnotation(self.defense3XDropPin)
            self.mapView.addAnnotation(self.defense3XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 8
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 8
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 8
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["defense4"]! {
            self.mapView.removeAnnotation(self.defense4DropPin)
            self.mapView.removeAnnotation(self.defense4XDropPin)
            self.mapView.addAnnotation(self.defense4XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 9
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 9
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 9
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["defense5"]! {
            self.mapView.removeAnnotation(self.defense5DropPin)
            self.mapView.removeAnnotation(self.defense5XDropPin)
            self.mapView.addAnnotation(self.defense5XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 10
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 10
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 10
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["offense1"]! {
            self.mapView.removeAnnotation(self.offense1DropPin)
            self.mapView.removeAnnotation(self.offense1XDropPin)
            self.mapView.removeAnnotation(self.offense1flagDropPin)
            self.mapView.addAnnotation(self.offense1XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 1
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 1
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 1
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["offense2"]! {
            self.mapView.removeAnnotation(self.offense2DropPin)
            self.mapView.removeAnnotation(self.offense2XDropPin)
            self.mapView.removeAnnotation(self.offense2flagDropPin)
            self.mapView.addAnnotation(self.offense2XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 2
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 2
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 2
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["offense3"]! {
            self.mapView.removeAnnotation(self.offense3DropPin)
            self.mapView.removeAnnotation(self.offense3XDropPin)
            self.mapView.removeAnnotation(self.offense3flagDropPin)
            self.mapView.addAnnotation(self.offense3XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 3
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 3
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 3
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["offense4"]! {
            self.mapView.removeAnnotation(self.offense4DropPin)
            self.mapView.removeAnnotation(self.offense4XDropPin)
            self.mapView.removeAnnotation(self.offense4flagDropPin)
            self.mapView.addAnnotation(self.offense4XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 4
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 4
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 4
                self.revealTagee3Count = 1
            }
        }
        else if tagee == globalPlayerNamesDict["offense5"]! {
            self.mapView.removeAnnotation(self.offense5DropPin)
            self.mapView.removeAnnotation(self.offense5XDropPin)
            self.mapView.removeAnnotation(self.offense5flagDropPin)
            self.mapView.addAnnotation(self.offense5XDropPin)
            if self.revealTagee1Count == 0 {
                self.revealTagee1 = 5
                self.revealTagee1Count = 1
            }
            else if self.revealTagee2Count == 0 {
                self.revealTagee2 = 5
                self.revealTagee2Count = 1
            }
            else if self.revealTagee3Count == 0 {
                self.revealTagee3 = 5
                self.revealTagee3Count = 1
            }
        }
    }
    
    func revealTageeRefire(_ tageeInt: Int) {
        if tageeInt == 6 {
            self.mapView.removeAnnotation(self.defense1DropPin)
            self.mapView.removeAnnotation(self.defense1XDropPin)
            self.mapView.addAnnotation(self.defense1XDropPin)
        }
        else if tageeInt == 7 {
            self.mapView.removeAnnotation(self.defense2DropPin)
            self.mapView.removeAnnotation(self.defense2XDropPin)
            self.mapView.addAnnotation(self.defense2XDropPin)
        }
        else if tageeInt == 8 {
            self.mapView.removeAnnotation(self.defense3DropPin)
            self.mapView.removeAnnotation(self.defense3XDropPin)
            self.mapView.addAnnotation(self.defense3XDropPin)
        }
        else if tageeInt == 9 {
            self.mapView.removeAnnotation(self.defense4DropPin)
            self.mapView.removeAnnotation(self.defense4XDropPin)
            self.mapView.addAnnotation(self.defense4XDropPin)
        }
        else if tageeInt == 10 {
            self.mapView.removeAnnotation(self.defense5DropPin)
            self.mapView.removeAnnotation(self.defense5XDropPin)
            self.mapView.addAnnotation(self.defense5XDropPin)
        }
        
        else if tageeInt == 1 {
            self.mapView.removeAnnotation(self.offense1DropPin)
            self.mapView.removeAnnotation(self.offense1XDropPin)
            self.mapView.removeAnnotation(self.offense1flagDropPin)
            self.mapView.addAnnotation(self.offense1XDropPin)
        }
        else if tageeInt == 2 {
            self.mapView.removeAnnotation(self.offense2DropPin)
            self.mapView.removeAnnotation(self.offense2XDropPin)
            self.mapView.removeAnnotation(self.offense2flagDropPin)
            self.mapView.addAnnotation(self.offense2XDropPin)
        }
        else if tageeInt == 3 {
            self.mapView.removeAnnotation(self.offense3DropPin)
            self.mapView.removeAnnotation(self.offense3XDropPin)
            self.mapView.removeAnnotation(self.offense3flagDropPin)
            self.mapView.addAnnotation(self.offense3XDropPin)
        }
        else if tageeInt == 4 {
            self.mapView.removeAnnotation(self.offense4DropPin)
            self.mapView.removeAnnotation(self.offense4XDropPin)
            self.mapView.removeAnnotation(self.offense4flagDropPin)
            self.mapView.addAnnotation(self.offense4XDropPin)
        }
        else if tageeInt == 5 {
            self.mapView.removeAnnotation(self.offense5DropPin)
            self.mapView.removeAnnotation(self.offense5XDropPin)
            self.mapView.removeAnnotation(self.offense5flagDropPin)
            self.mapView.addAnnotation(self.offense5XDropPin)
        }
    }
    
    func addActiveItemImageView(_ item: Int) {
        if activeItemImageView.isHidden {
            if item == 7 {
                self.activeItemImageView.image = UIImage(named:"jammer.png")
                self.activeItemImageView.isHidden = false
            }
            else if item == 12 {
                self.activeItemImageView.image = UIImage(named:"ghost.png")
                self.activeItemImageView.isHidden = false
            }
            else if item == 13 {
                self.activeItemImageView.image = UIImage(named:"reach.png")
                self.activeItemImageView.isHidden = false
            }
            else if item == 14 {
                self.activeItemImageView.image = UIImage(named:"fist.png")
                self.activeItemImageView.isHidden = false
            }
        } else if activeItemImageView2.isHidden {
            if item == 7 {
                self.activeItemImageView2.image = UIImage(named:"jammer.png")
                self.activeItemImageView2.isHidden = false
            }
            else if item == 12 {
                self.activeItemImageView2.image = UIImage(named:"ghost.png")
                self.activeItemImageView2.isHidden = false
            }
            else if item == 13 {
                self.activeItemImageView2.image = UIImage(named:"reach.png")
                self.activeItemImageView2.isHidden = false
            }
            else if item == 14 {
                self.activeItemImageView2.image = UIImage(named:"fist.png")
                self.activeItemImageView2.isHidden = false
            }
        } else if activeItemImageView3.isHidden {
            if item == 7 {
                self.activeItemImageView3.image = UIImage(named:"jammer.png")
                self.activeItemImageView3.isHidden = false
            }
            else if item == 12 {
                self.activeItemImageView3.image = UIImage(named:"ghost.png")
                self.activeItemImageView3.isHidden = false
            }
            else if item == 13 {
                self.activeItemImageView3.image = UIImage(named:"reach.png")
                self.activeItemImageView3.isHidden = false
            }
            else if item == 14 {
                self.activeItemImageView3.image = UIImage(named:"fist.png")
                self.activeItemImageView3.isHidden = false
            }
        }
    }
    
    func removeActiveItemImageView(_ item: Int) {
        if item == 7 {
            if self.activeItemImageView.isHidden == false && self.activeItemImageView.image == UIImage(named:"jammer.png") {
                self.activeItemImageView.isHidden = true
            }
            if self.activeItemImageView2.isHidden == false && self.activeItemImageView2.image == UIImage(named:"jammer.png") {
                self.activeItemImageView2.isHidden = true
            }
            if self.activeItemImageView3.isHidden == false && self.activeItemImageView3.image == UIImage(named:"jammer.png") {
                self.activeItemImageView3.isHidden = true
            }
        }
        else if item == 12 {
            if self.activeItemImageView.isHidden == false && self.activeItemImageView.image == UIImage(named:"ghost.png") {
                self.activeItemImageView.isHidden = true
            }
            if self.activeItemImageView2.isHidden == false && self.activeItemImageView2.image == UIImage(named:"ghost.png") {
                self.activeItemImageView2.isHidden = true
            }
            if self.activeItemImageView3.isHidden == false && self.activeItemImageView3.image == UIImage(named:"ghost.png") {
                self.activeItemImageView3.isHidden = true
            }
        }
        else if item == 13 {
            if self.activeItemImageView.isHidden == false && self.activeItemImageView.image == UIImage(named:"reach.png") {
                self.activeItemImageView.isHidden = true
            }
            if self.activeItemImageView2.isHidden == false && self.activeItemImageView2.image == UIImage(named:"reach.png") {
                self.activeItemImageView2.isHidden = true
            }
            if self.activeItemImageView3.isHidden == false && self.activeItemImageView3.image == UIImage(named:"reach.png") {
                self.activeItemImageView3.isHidden = true
            }
        }
        else if item == 14 {
            if self.activeItemImageView.isHidden == false && self.activeItemImageView.image == UIImage(named:"fist.png") {
                self.activeItemImageView.isHidden = true
            }
            if self.activeItemImageView2.isHidden == false && self.activeItemImageView2.image == UIImage(named:"fist.png") {
                self.activeItemImageView2.isHidden = true
            }
            if self.activeItemImageView3.isHidden == false && self.activeItemImageView3.image == UIImage(named:"fist.png") {
                self.activeItemImageView3.isHidden = true
            }
        }
        
        if self.activeItemImageView.isHidden == true && self.activeItemImageView2.isHidden == false {
            self.activeItemImageView.image = self.activeItemImageView2.image
            self.activeItemImageView.isHidden = false
            self.activeItemImageView2.isHidden = true
        }
        if self.activeItemImageView2.isHidden == true && self.activeItemImageView3.isHidden == false {
            self.activeItemImageView2.image = self.activeItemImageView3.image
            self.activeItemImageView2.isHidden = false
            self.activeItemImageView3.isHidden = true
        }
        if self.activeItemImageView.isHidden == true && self.activeItemImageView2.isHidden == true && self.activeItemImageView3.isHidden == false {
            self.activeItemImageView.image = self.activeItemImageView3.image
            self.activeItemImageView.isHidden = false
            self.activeItemImageView3.isHidden = true
        }
    }

    @IBOutlet var testButton2Outlet: UIButton!
    @IBAction func testButton2(_ sender: AnyObject) {
        let screenCoordinate = mapView.centerCoordinate
        print(screenCoordinate)
        if testAnnType == "if" {
          let tempdroppin = CustomPinDrop(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(tempdroppin)
            self.tempdroppinlast = tempdroppin
            self.tempdropcircle = MKCircle(center: screenCoordinate, radius: CLLocationDistance(5))
            self.mapView.add(self.tempdropcircle)
        }
        else if testAnnType == "uif" {
            self.mapView.removeAnnotation(self.tempdroppinlast)
            self.mapView.remove(self.tempdropcircle)
        }
        else if testAnnType == "i" {
            self.postItem(lat: screenCoordinate.latitude, long: screenCoordinate.longitude)
        }
        else if testAnnType == "ci" {
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.remove(self.drop1Circle)
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.remove(self.drop2Circle)
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.remove(self.drop3Circle)
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.remove(self.drop4Circle)
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.remove(self.drop5Circle)
        }
        else if testAnnType == "o" {
            self.offensedroptemp = CustomPinBlueperson(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.offensedroptemp)
        }
        else if testAnnType == "uo" {
            self.mapView.removeAnnotation(self.offensedroptemp)
        }
        else if testAnnType == "ox" {
            self.offensedroptempx = CustomPinBluepersonX(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.offensedroptempx)
        }
        else if testAnnType == "uox" {
            self.mapView.removeAnnotation(self.offensedroptempx)
        }
        else if testAnnType == "of" {
            self.offensedroptempflag = CustomPinBluepersonflag(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.offensedroptempflag)
        }
        else if testAnnType == "uof" {
            self.mapView.removeAnnotation(self.offensedroptempflag)
        }
        else if testAnnType == "d" {
            self.defensedroptemp = CustomPinRedperson(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.defensedroptemp)
        }
        else if testAnnType == "ud" {
            self.mapView.removeAnnotation(self.defensedroptemp)
        }
        else if testAnnType == "hf" {
            self.mapView.removeAnnotation(self.pointDropPin)
            self.mapView?.remove(self.pointCircle)
        }
        else if testAnnType == "sf" {
            self.mapView.addAnnotation(self.pointDropPin)
            self.mapView?.add(self.pointCircle)
        }
        else if testAnnType == "gt" {
            gameTimerCount = Int(testAnnCaption)!
        }
        else if testAnnType == "tr" {
            self.circletemp = MKCircle(center: screenCoordinate, radius: CLLocationDistance(Int(testAnnCaption)!))
            self.mapView?.add(self.circletemp)
        }
        else if testAnnType == "utr" {
            self.mapView?.remove(self.circletemp)
        }
    }
    
    func hideTestView(_ hide: Bool) {
        if hide == true {
            self.thresholdLabel.isHidden = true
            self.RSSILabel.isHidden = true
            self.testButton.isHidden = true
            self.testButton2Outlet.isHidden = true
        }
        else if hide == false {
            self.thresholdLabel.isHidden = false
            self.RSSILabel.isHidden = false
            self.testButton.isHidden = false
            self.testButton2Outlet.isHidden = false
        }
    }
    
    func rejoinLoad() {
        currentFunds = 0
        self.fundsLabel.text = "\(currentFunds)"
    }
    
    func getSecondsOfDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute, .second], from: date)
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        let secondsOfDay = (hour!*3600) + (minute!*60) + second!
        return secondsOfDay
    }
    
    func hideUIElements() {
        self.flagImageView.isHidden = true
        self.targetImageView.isHidden = true
        self.itemButtonBackdropImageView.isHidden = true
        self.itemLabelIconImageView.isHidden = true
        self.itemLabel.isHidden = true
        self.useButtonOutlet.isHidden = true
        self.helpButtonOutlet.isHidden = true
        self.cancelButtonOutlet.isHidden = true
        self.activeItemImageView.isHidden = true
        self.activeItemImageView2.isHidden = true
        self.activeItemImageView3.isHidden = true
        self.lifeMeterImageView.isHidden = true
    }
    
    func loadSounds() {
        if let logicGamestart2 = self.setupAudioPlayerWithFile("logicGamestart2", type:"mp3") {
            self.logicGamestart2 = logicGamestart2
        }
        self.logicGamestart2?.volume = 0.8
        if let logicPowerUp = self.setupAudioPlayerWithFile("logicPowerUp", type:"mp3") {
            self.logicPowerUp = logicPowerUp
        }
        self.logicPowerUp?.volume = 0.8
        if let logicScan = self.setupAudioPlayerWithFile("logicScan", type:"mp3") {
            self.logicScan = logicScan
        }
        self.logicScan?.volume = 0.8
        if let logicLoseLife = self.setupAudioPlayerWithFile("logicLoseLife", type:"mp3") {
            self.logicLoseLife = logicLoseLife
        }
        self.logicLoseLife?.volume = 0.8
        if let logicCapture = self.setupAudioPlayerWithFile("logicCapture", type:"mp3") {
            self.logicCapture = logicCapture
        }
        self.logicCapture?.volume = 0.8
        if let logicCapturing2 = self.setupAudioPlayerWithFile("logicCapturing2", type:"mp3") {
            self.logicCapturing2 = logicCapturing2
        }
        self.logicCapturing2?.volume = 0.8
        if let logicCancel = self.setupAudioPlayerWithFile("logicCancel", type:"mp3") {
            self.logicCancel = logicCancel
        }
        self.logicCancel?.volume = 0.8
        if let logicReign = self.setupAudioPlayerWithFile("logicReign", type:"mp3") {
            self.logicReign = logicReign
        }
        self.logicReign?.volume = 0.8
        if let logicSFX1 = self.setupAudioPlayerWithFile("logicSFX1", type:"mp3") {
            self.logicSFX1 = logicSFX1
        }
        self.logicSFX1?.volume = 0.8
        if let logicSFX3 = self.setupAudioPlayerWithFile("logicSFX3", type:"mp3") {
            self.logicSFX3 = logicSFX3
        }
        self.logicSFX3?.volume = 0.8
        if let logicSFX4 = self.setupAudioPlayerWithFile("logicSFX4", type:"mp3") {
            self.logicSFX4 = logicSFX4
        }
        self.logicSFX4?.volume = 0.8
        if let logicGotTag = self.setupAudioPlayerWithFile("logicGotTag", type:"mp3") {
            self.logicGotTag = logicGotTag
        }
        self.logicGotTag?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        if let bomb = self.setupAudioPlayerWithFile("bomb", type:"mp3") {
            self.bomb = bomb
        }
        self.bomb?.volume = 0.8
        if let chaching = self.setupAudioPlayerWithFile("chaching", type:"mp3") {
            self.chaching = chaching
        }
        self.chaching?.volume = 0.8
        if let coin = self.setupAudioPlayerWithFile("coin", type:"mp3") {
            self.coin = coin
        }
        self.coin?.volume = 0.8
        if let directitem = self.setupAudioPlayerWithFile("directitem", type:"mp3") {
            self.directitem = directitem
        }
        self.directitem?.volume = 0.8
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
        self.entersound?.volume = 0.8
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let ghost = self.setupAudioPlayerWithFile("ghost", type:"mp3") {
            self.ghost = ghost
        }
        self.ghost?.volume = 0.8
        if let itemdrop = self.setupAudioPlayerWithFile("itemdrop", type:"mp3") {
            self.itemdrop = itemdrop
        }
        self.itemdrop?.volume = 0.6
        if let jammer = self.setupAudioPlayerWithFile("jammer", type:"mp3") {
            self.jammer = jammer
        }
        self.jammer?.volume = 0.8
        if let lightning = self.setupAudioPlayerWithFile("lightning", type:"mp3") {
            self.lightning = lightning
        }
        self.lightning?.volume = 0.8
        if let reach = self.setupAudioPlayerWithFile("reach", type:"mp3") {
            self.reach = reach
        }
        self.reach?.volume = 0.8
        if let scansound = self.setupAudioPlayerWithFile("scansound", type:"mp3") {
            self.scansound = scansound
        }
        self.scansound?.volume = 0.8
        if let setmine = self.setupAudioPlayerWithFile("setmine", type:"mp3") {
            self.setmine = setmine
        }
        self.setmine?.volume = 0.8
        if let shield = self.setupAudioPlayerWithFile("shield", type:"mp3") {
            self.shield = shield
        }
        self.shield?.volume = 0.8
        if let showtargetimageview = self.setupAudioPlayerWithFile("showtargetimageview", type:"mp3") {
            self.showtargetimageview = showtargetimageview
        }
        self.showtargetimageview?.volume = 0.8
        if let sickle = self.setupAudioPlayerWithFile("sickle", type:"mp3") {
            self.sickle = sickle
        }
        self.sickle?.volume = 0.8
        if let spybotsound = self.setupAudioPlayerWithFile("spybotsound", type:"mp3") {
            self.spybotsound = spybotsound
        }
        self.spybotsound?.volume = 0.8
        if let superbomb = self.setupAudioPlayerWithFile("superbomb", type:"mp3") {
            self.superbomb = superbomb
        }
        self.superbomb?.volume = 0.8
        if let bombtag = self.setupAudioPlayerWithFile("bombtag", type:"mp3") {
            self.bombtag = bombtag
        }
        self.bombtag?.volume = 0.8
        if let superbombtag = self.setupAudioPlayerWithFile("superbombtag", type:"mp3") {
            self.superbombtag = superbombtag
        }
        self.superbombtag?.volume = 0.8
        if let sickletag = self.setupAudioPlayerWithFile("sickletag", type:"mp3") {
            self.sickletag = sickletag
        }
        self.sickletag?.volume = 0.8
        if let lightningtag = self.setupAudioPlayerWithFile("lightningtag", type:"mp3") {
            self.lightningtag = lightningtag
        }
        self.lightningtag?.volume = 0.8
    }
    
    func stateUpdate() {
        if bluetoothOn == false  && localPlayerStatus == 1 && globalTestModeEnabled == false {
            self.tagLocalPlayer()
            self.logicLoseLife?.play()
            displayAlert("Bluetooth disabled", message: "You automatically get tagged when you disable bluetooth! Enable bluetooth to continue playing. Make sure airplane mode is disabled.")
        }
        if self.networkFailedCount == NETWORK_FAILURE_MAX {
            self.networkFailedCount = 0
            self.tagLocalPlayer()
            self.logicLoseLife?.play()
            displayAlert("Network failure", message: "To prevent cheating, you are automatically tagged when your internet connection fails for an extended period.  Make sure airpline mode is disabled.")
        }
        SocketIOManager.sharedInstance.updateGameState(gameID: globalGameID,
                                                       position: localPlayerPosition,
                                                       status: localPlayerStatus,
                                                       latitude: self.currentLatitude,
                                                       longitude: self.currentLongitude,
                                                       completionHandler: { (playerState, otherState) -> Void in
            pointCaptureState = otherState["capture_state"] as! String
            playerCapturingPoint = otherState["capturer"] as! String
            playerStateDict = playerState
            self.updateFlagState()
            if globalIsOffense == true {
                self.offenseStateUpdate()
            } else {
                self.defenseStateUpdate()
            }
            if globalItemsOn {
                self.itemStateUpdate()
            }
        })
    }
    
    func offenseStateUpdate() {
        //update teammates' locations on map, and statuses
        if playerStateDict["offense1"] != nil  && localPlayerPosition != "offense1"  {
            self.offense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense1"]!["latitude"] as! Double,
                longitude: playerStateDict["offense1"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.offense1DropPin)
            self.mapView.removeAnnotation(self.offense1XDropPin)
            self.mapView.removeAnnotation(self.offense1flagDropPin)
            if playerCapturingPoint == "offense1" {
                self.offense1flagDropPin.coordinate = self.offense1Coordinates
                self.offense1flagDropPin.title = globalPlayerNamesDict["offense1"]!
                self.mapView.addAnnotation(self.offense1flagDropPin)
            }
            else if playerStateDict["offense1"]!["status"] as! Int == 0 {
                self.offense1XDropPin.coordinate = self.offense1Coordinates
                self.offense1XDropPin.title = globalPlayerNamesDict["offense1"]!
                self.mapView.addAnnotation(self.offense1XDropPin)
            }
            else {
                self.offense1DropPin.coordinate = self.offense1Coordinates
                self.offense1DropPin.title = globalPlayerNamesDict["offense1"]!
                self.mapView.addAnnotation(self.offense1DropPin)
            }
        }
        if playerStateDict["offense2"] != nil  && localPlayerPosition != "offense2"  {
            self.offense2Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense2"]!["latitude"] as! Double,
                longitude: playerStateDict["offense2"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.offense2DropPin)
            self.mapView.removeAnnotation(self.offense2XDropPin)
            self.mapView.removeAnnotation(self.offense2flagDropPin)
            if playerCapturingPoint == "offense2" {
                self.offense2flagDropPin.coordinate = self.offense2Coordinates
                self.offense2flagDropPin.title = globalPlayerNamesDict["offense2"]!
                self.mapView.addAnnotation(self.offense2flagDropPin)
            }
            else if playerStateDict["offense2"]!["status"] as! Int == 0 {
                self.offense2XDropPin.coordinate = self.offense2Coordinates
                self.offense2XDropPin.title = globalPlayerNamesDict["offense2"]!
                self.mapView.addAnnotation(self.offense2XDropPin)
            }
            else {
                self.offense2DropPin.coordinate = self.offense2Coordinates
                self.offense2DropPin.title = globalPlayerNamesDict["offense2"]!
                self.mapView.addAnnotation(self.offense2DropPin)
            }
        }
        if playerStateDict["offense3"] != nil  && localPlayerPosition != "offense3"  {
            self.offense3Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense3"]!["latitude"] as! Double,
                longitude: playerStateDict["offense3"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.offense3DropPin)
            self.mapView.removeAnnotation(self.offense3XDropPin)
            self.mapView.removeAnnotation(self.offense3flagDropPin)
            if playerCapturingPoint == "offense3" {
                self.offense3flagDropPin.coordinate = self.offense3Coordinates
                self.offense3flagDropPin.title = globalPlayerNamesDict["offense3"]!
                self.mapView.addAnnotation(self.offense3flagDropPin)
            }
            else if playerStateDict["offense3"]!["status"] as! Int == 0 {
                self.offense3XDropPin.coordinate = self.offense3Coordinates
                self.offense3XDropPin.title = globalPlayerNamesDict["offense3"]!
                self.mapView.addAnnotation(self.offense3XDropPin)
            }
            else {
                self.offense3DropPin.coordinate = self.offense3Coordinates
                self.offense3DropPin.title = globalPlayerNamesDict["offense3"]!
                self.mapView.addAnnotation(self.offense3DropPin)
            }
        }
        if playerStateDict["offense4"] != nil  && localPlayerPosition != "offense4"  {
            self.offense4Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense4"]!["latitude"] as! Double,
                longitude: playerStateDict["offense4"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.offense4DropPin)
            self.mapView.removeAnnotation(self.offense4XDropPin)
            self.mapView.removeAnnotation(self.offense4flagDropPin)
            if playerCapturingPoint == "offense4" {
                self.offense4flagDropPin.coordinate = self.offense4Coordinates
                self.offense4flagDropPin.title = globalPlayerNamesDict["offense4"]!
                self.mapView.addAnnotation(self.offense4flagDropPin)
            }
            else if playerStateDict["offense4"]!["status"] as! Int == 0 {
                self.offense4XDropPin.coordinate = self.offense4Coordinates
                self.offense4XDropPin.title = globalPlayerNamesDict["offense4"]!
                self.mapView.addAnnotation(self.offense4XDropPin)
            }
            else {
                self.offense4DropPin.coordinate = self.offense4Coordinates
                self.offense4DropPin.title = globalPlayerNamesDict["offense4"]!
                self.mapView.addAnnotation(self.offense4DropPin)
            }
        }
        if playerStateDict["offense5"] != nil  && localPlayerPosition != "offense5"  {
            self.offense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense5"]!["latitude"] as! Double,
                longitude: playerStateDict["offense5"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.offense5DropPin)
            self.mapView.removeAnnotation(self.offense5XDropPin)
            self.mapView.removeAnnotation(self.offense5flagDropPin)
            if playerCapturingPoint == "offense5" {
                self.offense5flagDropPin.coordinate = self.offense5Coordinates
                self.offense5flagDropPin.title = globalPlayerNamesDict["offense5"]!
                self.mapView.addAnnotation(self.offense5flagDropPin)
            }
            else if playerStateDict["offense5"]!["status"] as! Int == 0 {
                self.offense5XDropPin.coordinate = self.offense5Coordinates
                self.offense5XDropPin.title = globalPlayerNamesDict["offense5"]!
                self.mapView.addAnnotation(self.offense5XDropPin)
            }
            else {
                self.offense5DropPin.coordinate = self.offense5Coordinates
                self.offense5DropPin.title = globalPlayerNamesDict["offense5"]!
                self.mapView.addAnnotation(self.offense5DropPin)
            }
        }
        
        //update opponents' locations (for scan etc), but don't display, and get status
        if playerStateDict["defense1"] != nil  {
            self.defense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense1"]!["latitude"] as! Double,
                longitude: playerStateDict["defense1"]!["longitude"] as! Double
            )
            self.defense1DropPin.coordinate = self.defense1Coordinates
            self.defense1XDropPin.coordinate = self.defense1Coordinates
            self.defense1DropPin.title = globalPlayerNamesDict["defense1"]!
            self.defense1XDropPin.title = globalPlayerNamesDict["defense1"]!
        }
        if playerStateDict["defense2"] != nil  {
            self.defense2Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense2"]!["latitude"] as! Double,
                longitude: playerStateDict["defense2"]!["longitude"] as! Double
            )
            self.defense2DropPin.coordinate = self.defense2Coordinates
            self.defense2XDropPin.coordinate = self.defense2Coordinates
            self.defense2DropPin.title = globalPlayerNamesDict["defense2"]!
            self.defense2XDropPin.title = globalPlayerNamesDict["defense2"]!
        }
        if playerStateDict["defense3"] != nil  {
            self.defense3Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense3"]!["latitude"] as! Double,
                longitude: playerStateDict["defense3"]!["longitude"] as! Double
            )
            self.defense3DropPin.coordinate = self.defense3Coordinates
            self.defense3XDropPin.coordinate = self.defense3Coordinates
            self.defense3DropPin.title = globalPlayerNamesDict["defense3"]!
            self.defense3XDropPin.title = globalPlayerNamesDict["defense3"]!
        }
        if playerStateDict["defense4"] != nil  {
            self.defense4Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense4"]!["latitude"] as! Double,
                longitude: playerStateDict["defense4"]!["longitude"] as! Double
            )
            self.defense4DropPin.coordinate = self.defense4Coordinates
            self.defense4XDropPin.coordinate = self.defense4Coordinates
            self.defense4DropPin.title = globalPlayerNamesDict["defense4"]!
            self.defense4XDropPin.title = globalPlayerNamesDict["defense4"]!
        }
        if playerStateDict["defense5"] != nil  {
            self.defense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense5"]!["latitude"] as! Double,
                longitude: playerStateDict["defense5"]!["longitude"] as! Double
            )
            self.defense5DropPin.coordinate = self.defense5Coordinates
            self.defense5XDropPin.coordinate = self.defense5Coordinates
            self.defense5DropPin.title = globalPlayerNamesDict["defense5"]!
            self.defense5XDropPin.title = globalPlayerNamesDict["defense5"]!
        }
        
        //determine whether player is in the offense base region
        let currentCoordinate = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
        if self.baseRegion.contains(currentCoordinate) {
            self.localPlayerRegion = 1
            
            //offense player enters their base at beginning of game to "power up", or tagged offense player enters base to power up
            if globalIsOffense == true && (localPlayerStatus == 2 || localPlayerStatus == 0) {
                localPlayerStatus = 1
                self.alertIconImageView.isHidden = true
                self.iconLabel.isHidden = true
                self.lifeMeterImageView.isHidden = false
                self.lifeMeterImageView.image = UIImage(named:"5life.png")
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicPowerUp?.play()
            }
            //offense player enters their base with the point, win game
            if localPlayerStatus == 1 && playerCapturingPoint == localPlayerPosition {
                SocketIOManager.sharedInstance.postGameEvent(gameID: globalGameID, eventName: "game_over", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: localPlayerPosition, completionHandler: { (didSend) -> Void in
                })
            }
        }
        
        //determine wether player is in the point region
        if self.pointRegion.contains(currentCoordinate) == true {
            self.localPlayerRegion = 2
            
            //untagged offense player enters point region, start capture timer if nobody else is capturing
            if localPlayerStatus == 1 && playerCapturingPoint == "" {
                SocketIOManager.sharedInstance.postGameEvent(gameID: globalGameID, eventName: "capturing", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: "", completionHandler: { (passedCheck) -> Void in
                    if passedCheck {
                        self.localPlayerCapturingPointEvent()
                    } else {
                        self.displayAlert("Error", message: "You were unable to capture the flag.  Please make sure you have an active network connection.")
                    }
                })
            } else if pointCaptureState == "capturing" && playerCapturingPoint != localPlayerPosition && self.eventsLabel.text != "Flag not in base.."  {
                self.logEvent("Flag not in base..")
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicReign?.play()
            }
        }
            
        else if self.pointRegion.contains(currentCoordinate) == false {
            self.localPlayerRegion = 0
            self.captureTimer.invalidate()
            self.logicCapturing2?.stop()
            self.logicCapturing2?.currentTime = 0
            
            //if player capturing point exits region before timer expires, cancel/reset timer
            if playerCapturingPoint == localPlayerPosition && pointCaptureState == "capturing" {
                SocketIOManager.sharedInstance.postGameEvent(gameID: globalGameID, eventName: "stopCapturing", sender: localPlayerPosition, recipient: "all", latitude: 0, longitude: 0, extra: "", timingOut: 10, completionHandler: { (didSend) -> Void in
                    self.localPlayerStopCapturingPointEvent()
                })
            }
        }
        
        if self.baseRegion.contains(currentCoordinate) == false {
            self.localPlayerRegion = 1
        }
        
        //if player is in opponent's base, change background color
        if self.pointRegion.contains(currentCoordinate) == true {
            self.view.backgroundColor = UIColor(red:1.0,green:0.503,blue:0.281,alpha:1.0)
        }
        else {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        //clear all defense annotations (they will be re-added if still needed)
        self.mapView.removeAnnotation(self.defense1DropPin)
        self.mapView.removeAnnotation(self.defense2DropPin)
        self.mapView.removeAnnotation(self.defense3DropPin)
        self.mapView.removeAnnotation(self.defense4DropPin)
        self.mapView.removeAnnotation(self.defense5DropPin)
        self.mapView.removeAnnotation(self.defense1XDropPin)
        self.mapView.removeAnnotation(self.defense2XDropPin)
        self.mapView.removeAnnotation(self.defense3XDropPin)
        self.mapView.removeAnnotation(self.defense4XDropPin)
        self.mapView.removeAnnotation(self.defense5XDropPin)
        
        //refresh/clear offense annotations (scan, super scan, and spybot)
        if self.spybot1Count > 0 {
            self.spybot()
            self.spybot1Count += 1
            if self.spybot1Count == SPYBOT_DURATION {
                self.mapView.removeAnnotation(self.spybot1DropPin)
                self.mapView.remove(self.spybot1Circle)
                self.spybot1Count = 0
            }
        }
        if self.spybot2Count > 0 {
            self.spybot()
            self.spybot2Count += 1
            if self.spybot2Count == SPYBOT_DURATION {
                self.mapView.removeAnnotation(self.spybot2DropPin)
                self.mapView.remove(self.spybot2Circle)
                self.spybot2Count = 0
            }
        }
        if self.spybot3Count > 0 {
            self.spybot()
            self.spybot3Count += 1
            if self.spybot3Count == SPYBOT_DURATION {
                self.mapView.removeAnnotation(self.spybot3DropPin)
                self.mapView.remove(self.spybot3Circle)
                self.spybot3Count = 0
            }
        }
        if self.regScanCount > 0 {
            self.scan(region: self.scanRegion, circle: self.scanCircle)
            self.regScanCount += 1
            if self.regScanCount == SCAN_DURATION {
                self.regScanCount = 0
            }
        }
        if self.scanCount > 0 {
            self.superscan()
            self.scanCount += 1
            if self.scanCount == SUPER_SCAN_DURATION {
                self.scanCount = 0
            }
        }
        if self.revealTagee1Count != 0 {
            self.revealTagee1Count += 1
            self.revealTageeRefire(self.revealTagee1)
            if self.revealTagee1Count == REVEAL_TAGEE_DURATION {
                self.revealTagee1Count = 0
            }
        }
        if self.revealTagee2Count != 0 {
            self.revealTagee2Count += 1
            self.revealTageeRefire(self.revealTagee2)
            if self.revealTagee2Count == REVEAL_TAGEE_DURATION {
                self.revealTagee2Count = 0
            }
        }
        if self.revealTagee3Count != 0 {
            self.revealTagee3Count += 1
            self.revealTageeRefire(self.revealTagee3)
            if self.revealTagee3Count == REVEAL_TAGEE_DURATION {
                self.revealTagee3Count = 0
            }
        }
        
        if playerCapturingPoint == localPlayerPosition {
            SocketIOManager.sharedInstance.postCaptureHeartbeat(gameID: globalGameID)
        }
    }
    
    func defenseStateUpdate() {
        //update teammates' locations on map, and statuses
        if playerStateDict["defense1"] != nil  && localPlayerPosition != "defense1"  {
            self.defense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense1"]!["latitude"] as! Double,
                longitude: playerStateDict["defense1"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.defense1DropPin)
            self.mapView.removeAnnotation(self.defense1XDropPin)
            if playerStateDict["defense1"]!["status"] as! Int == 0 {
                self.defense1XDropPin.coordinate = self.defense1Coordinates
                self.defense1XDropPin.title = globalPlayerNamesDict["defense1"]!
                self.mapView.addAnnotation(self.defense1XDropPin)
            }
            else {
                self.defense1DropPin.coordinate = self.defense1Coordinates
                self.defense1DropPin.title = globalPlayerNamesDict["defense1"]!
                self.mapView.addAnnotation(self.defense1DropPin)
            }
        }

        if playerStateDict["defense2"] != nil  && localPlayerPosition != "defense2"  {
            self.defense2Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense2"]!["latitude"] as! Double,
                longitude: playerStateDict["defense2"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.defense2DropPin)
            self.mapView.removeAnnotation(self.defense2XDropPin)
            if playerStateDict["defense2"]!["status"] as! Int == 0 {
                self.defense2XDropPin.coordinate = self.defense2Coordinates
                self.defense2XDropPin.title = globalPlayerNamesDict["defense2"]!
                self.mapView.addAnnotation(self.defense2XDropPin)
            }
            else {
                self.defense2DropPin.coordinate = self.defense2Coordinates
                self.defense2DropPin.title = globalPlayerNamesDict["defense2"]!
                self.mapView.addAnnotation(self.defense2DropPin)
            }
        }
        if playerStateDict["defense3"] != nil  && localPlayerPosition != "defense3"  {
            self.defense3Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense3"]!["latitude"] as! Double,
                longitude: playerStateDict["defense3"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.defense3DropPin)
            self.mapView.removeAnnotation(self.defense3XDropPin)
            if playerStateDict["defense3"]!["status"] as! Int == 0 {
                self.defense3XDropPin.coordinate = self.defense3Coordinates
                self.defense3XDropPin.title = globalPlayerNamesDict["defense3"]!
                self.mapView.addAnnotation(self.defense3XDropPin)
            }
            else {
                self.defense3DropPin.coordinate = self.defense3Coordinates
                self.defense3DropPin.title = globalPlayerNamesDict["defense3"]!
                self.mapView.addAnnotation(self.defense3DropPin)
            }
        }
        if playerStateDict["defense4"] != nil  && localPlayerPosition != "defense4"  {
            self.defense4Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense4"]!["latitude"] as! Double,
                longitude: playerStateDict["defense4"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.defense4DropPin)
            self.mapView.removeAnnotation(self.defense4XDropPin)
            if playerStateDict["defense4"]!["status"] as! Int == 0 {
                self.defense4XDropPin.coordinate = self.defense4Coordinates
                self.defense4XDropPin.title = globalPlayerNamesDict["defense4"]!
                self.mapView.addAnnotation(self.defense4XDropPin)
            }
            else {
                self.defense4DropPin.coordinate = self.defense4Coordinates
                self.defense4DropPin.title = globalPlayerNamesDict["defense4"]!
                self.mapView.addAnnotation(self.defense4DropPin)
            }
        }
        if playerStateDict["defense5"] != nil  && localPlayerPosition != "defense5"  {
            self.defense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["defense5"]!["latitude"] as! Double,
                longitude: playerStateDict["defense5"]!["longitude"] as! Double
            )
            self.mapView.removeAnnotation(self.defense5DropPin)
            self.mapView.removeAnnotation(self.defense5XDropPin)
            if playerStateDict["defense5"]!["status"] as! Int == 0 {
                self.defense5XDropPin.coordinate = self.defense5Coordinates
                self.defense5XDropPin.title = globalPlayerNamesDict["defense5"]!
                self.mapView.addAnnotation(self.defense5XDropPin)
            }
            else {
                self.defense5DropPin.coordinate = self.defense5Coordinates
                self.defense5DropPin.title = globalPlayerNamesDict["defense5"]!
                self.mapView.addAnnotation(self.defense5DropPin)
            }
        }
        print("DEFENSE STATE UPDATE FIRED 3")
        //download opponents' locations (but don't display)
        if playerStateDict["offense1"] != nil  {
            self.offense1Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense1"]!["latitude"] as! Double,
                longitude: playerStateDict["offense1"]!["longitude"] as! Double
            )
            self.offense1DropPin.coordinate = self.offense1Coordinates
            self.offense1XDropPin.coordinate = self.offense1Coordinates
            self.offense1flagDropPin.coordinate = self.offense1Coordinates
            self.offense1DropPin.title = globalPlayerNamesDict["offense1"]!
            self.offense1XDropPin.title = globalPlayerNamesDict["offense1"]!
            self.offense1flagDropPin.title = globalPlayerNamesDict["offense1"]!
        }

        if playerStateDict["offense2"] != nil  {
            self.offense2Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense2"]!["latitude"] as! Double,
                longitude: playerStateDict["offense2"]!["longitude"] as! Double
            )
            self.offense2DropPin.coordinate = self.offense2Coordinates
            self.offense2XDropPin.coordinate = self.offense2Coordinates
            self.offense2flagDropPin.coordinate = self.offense2Coordinates
            self.offense2DropPin.title = globalPlayerNamesDict["offense2"]!
            self.offense2XDropPin.title = globalPlayerNamesDict["offense2"]!
            self.offense2flagDropPin.title = globalPlayerNamesDict["offense2"]!
        }
        if playerStateDict["offense3"] != nil  {
            self.offense3Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense3"]!["latitude"] as! Double,
                longitude: playerStateDict["offense3"]!["longitude"] as! Double
            )
            self.offense3DropPin.coordinate = self.offense3Coordinates
            self.offense3XDropPin.coordinate = self.offense3Coordinates
            self.offense3flagDropPin.coordinate = self.offense3Coordinates
            self.offense3DropPin.title = globalPlayerNamesDict["offense3"]!
            self.offense3XDropPin.title = globalPlayerNamesDict["offense3"]!
            self.offense3flagDropPin.title = globalPlayerNamesDict["offense3"]!
        }
        if playerStateDict["offense4"] != nil  {
            self.offense4Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense4"]!["latitude"] as! Double,
                longitude: playerStateDict["offense4"]!["longitude"] as! Double
            )
            self.offense4DropPin.coordinate = self.offense4Coordinates
            self.offense4XDropPin.coordinate = self.offense4Coordinates
            self.offense4flagDropPin.coordinate = self.offense4Coordinates
            self.offense4DropPin.title = globalPlayerNamesDict["offense4"]!
            self.offense4XDropPin.title = globalPlayerNamesDict["offense4"]!
            self.offense4flagDropPin.title = globalPlayerNamesDict["offense4"]!
        }
        if playerStateDict["offense5"] != nil  {
            self.offense5Coordinates = CLLocationCoordinate2D(
                latitude: playerStateDict["offense5"]!["latitude"] as! Double,
                longitude: playerStateDict["offense5"]!["longitude"] as! Double
            )
            self.offense5DropPin.coordinate = self.offense5Coordinates
            self.offense5XDropPin.coordinate = self.offense5Coordinates
            self.offense5flagDropPin.coordinate = self.offense5Coordinates
            self.offense5DropPin.title = globalPlayerNamesDict["offense5"]!
            self.offense5XDropPin.title = globalPlayerNamesDict["offense5"]!
            self.offense5flagDropPin.title = globalPlayerNamesDict["offense5"]!
        }
        
        if localPlayerStatus == 1 && (self.iconLabel.text != "Flag in place" || self.iconLabel.text != "Flag captured!" || self.iconLabel.text != "Intruder alert!") {
            if playerCapturingPoint == "" {
                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                self.iconLabel.text = "Flag in place"
            }
            if playerCapturingPoint != "" {
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
        }
        else if localPlayerStatus == 0 && self.iconLabel.text != "Return to base" {
            self.alertIconImageView.image = UIImage(named:"walkIcon.png")
            self.iconLabel.text = "Return to base"
        }

        //clear "intruder alert" iconlabel if it's been that way for 4 cycles
        if String(describing: self.iconLabel) == "Intruder alert!" {
            self.intruderAlertResetCount += 1
            if self.intruderAlertResetCount == INTRUDER_ALERT_DURATION {
                self.intruderAlertResetCount = 0
                if playerCapturingPoint == "" {
                    self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                    self.iconLabel.text = "Flag in place"
                }
                if playerCapturingPoint != "" {
                    self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                    self.iconLabel.text = "Flag captured!"
                }
            }
        }
        else {
            self.intruderAlertResetCount = 0
        }

        //defense player enters offense base region, tag them
        let currentCoordinate = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
        if self.baseRegion.contains(currentCoordinate) == true {
            self.localPlayerRegion = 1
            if localPlayerStatus == 1 {
                self.tagLocalPlayer()
                self.logicLoseLife?.play()
                self.logEvent("Entered opponents' base")
            }
        }
        
        //defense player enters point region
        if self.pointRegion.contains(currentCoordinate) == true {
            self.localPlayerRegion = 2
            
            //defense player enters their base at beginning of game to "power up", or tagged defense player enters base to power up
            if localPlayerStatus == 2 {
                localPlayerStatus = 1
                
                //set the alert icon and label
                if playerCapturingPoint == "" {
                    self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                    self.iconLabel.text = "Flag in place"
                }
                if playerCapturingPoint != "" {
                    self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                    self.iconLabel.text = "Flag captured!"
                }
                
                //enable beacon emitter
                self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
                
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicPowerUp?.play()
                
            }
            if localPlayerStatus == 0 && self.defenseRechargeTimer.isValid == false {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.entersound?.play()
                self.defenseRechargeTimerCount = 10
                self.defenseRechargeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.defenseRechargeTimerUpdate), userInfo: nil, repeats: true)
                self.defenseRechargeTimer.tolerance = 0.3
            }
        }
        //update icon label and warning (for flag status) - e.g. in case where player drops and flag resets
        if playerCapturingPoint == ""  && localPlayerStatus == 1 {
            self.alertIconImageView.image = UIImage(named:"greenIcon.png")
            self.iconLabel.text = "Flag in place"
        }
        if playerCapturingPoint != "" && localPlayerStatus == 1 {
            self.alertIconImageView.image = UIImage(named:"warningIcon.png")
            self.iconLabel.text = "Flag captured!"
        }

        //clear all offense annotations (they will be replaced immediately if needed)
        self.mapView.removeAnnotation(self.offense1DropPin)
        self.mapView.removeAnnotation(self.offense2DropPin)
        self.mapView.removeAnnotation(self.offense3DropPin)
        self.mapView.removeAnnotation(self.offense4DropPin)
        self.mapView.removeAnnotation(self.offense5DropPin)
        self.mapView.removeAnnotation(self.offense1XDropPin)
        self.mapView.removeAnnotation(self.offense2XDropPin)
        self.mapView.removeAnnotation(self.offense3XDropPin)
        self.mapView.removeAnnotation(self.offense4XDropPin)
        self.mapView.removeAnnotation(self.offense5XDropPin)
        self.mapView.removeAnnotation(self.offense1flagDropPin)
        self.mapView.removeAnnotation(self.offense2flagDropPin)
        self.mapView.removeAnnotation(self.offense3flagDropPin)
        self.mapView.removeAnnotation(self.offense4flagDropPin)
        self.mapView.removeAnnotation(self.offense5flagDropPin)

        //refresh/clear offense annotations (scan, super scan, and spybot)
        if self.spybot1Count > 0 {
            self.spybot()
            self.spybot1Count += 1
            if self.spybot1Count == SPYBOT_DURATION {
                self.mapView.removeAnnotation(self.spybot1DropPin)
                self.mapView.remove(self.spybot1Circle)
                self.spybot1Count = 0
            }
        }
        if self.spybot2Count > 0 {
            self.spybot()
            self.spybot2Count += 1
            if self.spybot2Count == SPYBOT_DURATION {
                self.mapView.removeAnnotation(self.spybot2DropPin)
                self.mapView.remove(self.spybot2Circle)
                self.spybot2Count = 0
            }
        }
        if self.spybot3Count > 0 {
            self.spybot()
            self.spybot3Count += 1
            if self.spybot3Count == SPYBOT_DURATION {
                self.mapView.removeAnnotation(self.spybot3DropPin)
                self.mapView.remove(self.spybot3Circle)
                self.spybot3Count = 0
            }
        }
        if self.regScanCount > 0 {
            self.scan(region: self.scanRegion, circle: self.scanCircle)
            self.regScanCount += 1
            if self.regScanCount == SCAN_DURATION {
                self.regScanCount = 0
            }
        }
        if self.senseCount > 0 {
            self.scan(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), radius: CLLocationDistance(20), identifier: "sense region"), circle: MKCircle())
            self.senseCount += 1
            print("sense fired - count \(self.senseCount)")
            if self.senseCount == SENSE_DURATION {
                self.removeActiveItemImageView(14)
                self.senseCount = 0
            }
        }

        if self.scanCount > 0 {
            self.superscan()
            self.scanCount += 1
            if self.scanCount == SUPER_SCAN_DURATION {
                self.scanCount = 0
            }
        }
        if self.captureClearMapCycleCount > 0 {
            self.captureClearMapCycleCount += 1
            self.showCapturer()
            if self.captureClearMapCycleCount == CAPTURE_ALERT_DURATION {
                self.captureClearMapCycleCount = 0
            }
        }
        
        if self.revealTagee1Count != 0 {
            self.revealTageeRefire(self.revealTagee1)
            self.revealTagee1Count += 1
            if self.revealTagee1Count == REVEAL_TAGEE_DURATION {
                self.revealTagee1Count = 0
            }
        }
        if self.revealTagee2Count != 0 {
            self.revealTageeRefire(self.revealTagee2)
            self.revealTagee2Count += 1
            if self.revealTagee2Count == REVEAL_TAGEE_DURATION {
                self.revealTagee2Count = 0
            }
        }
        if self.revealTagee3Count != 0 {
            self.revealTageeRefire(self.revealTagee3)
            self.revealTagee3Count += 1
            if self.revealTagee3Count == REVEAL_TAGEE_DURATION {
                self.revealTagee3Count = 0
            }
        }
        if self.lightningScanCount > 0 {
            self.lightningScan()
            self.lightningScanCount += 1
            if self.lightningScanCount == SUPER_SCAN_DURATION {
                self.lightningScanCount = 0
            }
        }
    }
    
    func localPlayerCapturingPointEvent() {
        pointCaptureState = "capturing"
        playerCapturingPoint = localPlayerPosition
        self.flagImageView.isHidden = true
        self.captureTimerCount = globalCaptureTime
        self.captureTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.captureTimerUpdate), userInfo: nil, repeats: true)
        self.captureTimer.tolerance = 0.2
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.logicCapturing2?.play()
    }
    
    func localPlayerStopCapturingPointEvent() {
        self.logEvent("Left before flag captured")
        pointCaptureState = ""
        playerCapturingPoint = ""
        self.flagImageView.isHidden = true
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.logicSFX3?.play()
    }
    
    func otherPlayerCapturingPointEvent(isOffense: Bool) {
        if !isOffense {
            if localPlayerStatus == 1 {
                self.iconLabel.text = "Intruder alert!"
                self.alertIconImageView.image = UIImage(named:"yellowExclaimation.png") }
            self.logEvent("Somebody in the flag zone!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicSFX4?.play()
        }
    }
    
    func otherPlayerCapturedPointEvent(isOffense: Bool) {
        if !isOffense {
            self.logEvent("\(playerCapturingPoint) captured the flag!")
            if localPlayerStatus == 1 {
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicCapture?.play()
            self.showCapturer()
            self.captureClearMapCycleCount = 1
        }
    }
    
    func updateFlagState() {
        if pointCaptureState == "" {
            //self.pointDropPin = CustomPin(coordinate: self.pointCoordinates, title: "Flag", subtitle: "Not captured")
            self.mapView.addAnnotation(self.pointDropPin)
        }
        else if pointCaptureState == "captured" {
            self.mapView.removeAnnotation(self.pointDropPin)
        }
    }
    
    func endGame() {
        SocketIOManager.sharedInstance.stopListeningForGameEvents()
        self.captureTimer.invalidate()
        self.itemTimer.invalidate()
        self.gameTimer.invalidate()
        self.stateTimer.invalidate()
        self.mapViewCameraTimer.invalidate()
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.stopRangingBeacons(in: self.detectionRegion)
        self.locationManager.stopUpdatingLocation()
        if quittingGame {
            self.performSegue(withIdentifier: "showFirstViewControllerFromGameViewController", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showGameResultsViewController", sender: nil)
        }
        sleep(1)
    }
}
