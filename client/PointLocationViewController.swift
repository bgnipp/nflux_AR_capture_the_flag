//
//  PointLocationViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/22/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreBluetooth
import AudioToolbox
import AVFoundation

class PointLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    var pointLocationSystemTimer = Timer()
    var pointLocationSystemTimerCount: Int = 3
    
    var entersoundlow : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    
    //lock in portrait orientation
    override var shouldAutorotate : Bool {
        return false }

    @IBOutlet var mapView: MKMapView!
    
    var locationManager:CLLocationManager!
    var mapCamera = MKMapCamera()
    var initialMapSetup = false
    var initialMapSetup2 = false
    
    var baseLat: Double = 0
    var baseLon: Double = 0
    var baseRadius: Double = 0
    var pointLat: Double = 0
    var pointLon: Double = 0
    var pointRadius: Double = 0
    
    //point location submitted, 0 = none have been submitted, 1 = "point" has been, 2 = both "point" and base have been submitted
    var pointLocationSubmitted = 0
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    var pointCircle = MKCircle()
    var pointDropPin = MKPointAnnotation()
    var pointRegionRadius: Double = 0
    var pointCoordinate = CLLocationCoordinate2D()
    var baseCircle = MKCircle()
    var baseDropPin = CustomPinBase(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Offense's base")
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var feetLabel: UILabel!
    @IBOutlet var radiusTextField: UITextField!
    @IBOutlet var selectButtonText: UIButton!
    @IBOutlet var pin: UIImageView!
    @IBOutlet var helpButtonOutlet: UIButton!
    
    @IBAction func selectButton(_ sender: AnyObject) {
        if !checkIsConnected() {
            print("not connected")
        } else if self.radiusTextField.text == "" && self.pointLocationSubmitted != 2 {
            self.displayAlert("Error", message: "Enter radius")
        } else if self.pointLocationSubmitted == 2 {
            SocketIOManager.sharedInstance.postPointLocation(gameID: globalGameID,
                                                           point_lat: self.pointLat,
                                                           point_lon: self.pointLon,
                                                           point_radius: self.pointRadius,
                                                           base_lat: self.baseLat,
                                                           base_lon: self.baseLon,
                                                           base_radius: self.baseRadius,
                                                           completionHandler: { (canProceed) -> Void in
                if canProceed {
                    print("CAN PROCEED")
                    SocketIOManager.sharedInstance.joinGame(gameID: globalGameID, udid: UDID, completionHandler: { (canJoin) -> Void in
                        if canJoin {
                            SocketIOManager.sharedInstance.getGameConfig(gameID: globalGameID, completionHandler: { (gameConfig, playerConfig) -> Void in
                                self.loadGame(gameConfig: gameConfig, playerConfig: playerConfig)
                                self.pointLocationSystemTimer.invalidate()
                                self.performSegue(withIdentifier: "showWaitingViewController", sender: nil)
                            })
                        } else {
                            self.displayAlert("Couldn't set point location", message: "Either your network failed or some other shit happened. Please try again.")
                        }
                    })
                }
            })
        } else if self.pointLocationSubmitted == 1 && self.radiusTextField.text != "" {
            let screenCoordinate = mapView.centerCoordinate
            self.baseLat = screenCoordinate.latitude
            self.baseLon = screenCoordinate.longitude
            self.baseRadius = Double(self.radiusTextField.text!)!
            let baseCoordinate = CLLocationCoordinate2D(latitude: self.baseLat, longitude: self.baseLon)
            let radiusCheck: Double = self.pointRadius + self.baseRadius
            let checkRegion = CLCircularRegion(center: baseCoordinate, radius: radiusCheck, identifier: "temp")
            if checkRegion.contains(self.pointCoordinate) {
                self.displayAlert("Error", message: "Flag and base zones can't overlap!")
                self.backsound?.play()
            } else {
                self.pointLocationSubmitted = 2
                self.entersoundlow?.play()
                
                //add base annotation pin to map view
                self.baseDropPin.coordinate = baseCoordinate
                self.baseDropPin.title = "Offense's base"
                self.mapView.addAnnotation(self.baseDropPin)
                
                //set up circle overlay on base region
                self.baseCircle = MKCircle(center: baseCoordinate, radius: self.baseRadius)
                self.mapView.add(self.baseCircle)
                
                self.pin.isHidden = true
                self.selectButtonText.setTitle("begin", for: UIControlState())
                self.headerLabel.text = "ready to begin"
                self.radiusTextField.isHidden = true
                self.feetLabel.isHidden = true
            }
        } else if self.pointLocationSubmitted == 0 && self.radiusTextField.text != "" {
            self.entersoundlow?.play()
            let screenCoordinate = mapView.centerCoordinate
            self.pointLat = screenCoordinate.latitude
            self.pointLon = screenCoordinate.longitude
            self.pointRadius = Double(self.radiusTextField.text!)!
            self.pointCoordinate = CLLocationCoordinate2D(latitude: self.pointLat, longitude: self.pointLon)
            
            //add flag annotation pin to map view
            self.pointDropPin.coordinate = self.pointCoordinate
            self.pointDropPin.title = "Flag"
            self.mapView.addAnnotation(self.pointDropPin)
            
            //set up circle overlay on flag region
            self.pointCircle = MKCircle(center: self.pointCoordinate, radius: self.pointRadius)
            self.mapView.add(self.pointCircle)
            self.selectButtonText.setTitle("select", for: UIControlState())
            self.headerLabel.text = "select base zone"
            self.pin.contentMode = UIViewContentMode.scaleAspectFit
            self.pin.image = UIImage(named:"basePin.png")
            self.pointLocationSubmitted = 1
            self.radiusTextField.text = "40"
        }
    }
    
    @IBAction func clearButton(_ sender: AnyObject) {
        if pointLocationSubmitted == 1 {
            self.selectButtonText.setTitle("select", for: UIControlState())
            self.headerLabel.text = "select flag zone"
            self.pin.frame.size.height = 120
            self.pin.frame.size.width = 80
            self.pin.image = UIImage(named:"robotFlag.png")
            self.pin.isHidden = false
            self.mapView.removeAnnotation(self.pointDropPin)
            self.mapView.remove(self.pointCircle)
            self.backsound?.play()
            self.pointLocationSubmitted = 0
        } else if pointLocationSubmitted == 2 {
            self.selectButtonText.setTitle("select", for: UIControlState())
            self.headerLabel.text = "select base zone"
            self.pin.image = UIImage(named:"basePin.png")
            self.pin.frame.size.height = 80
            self.pin.frame.size.width = 29
            self.mapView.removeAnnotation(self.baseDropPin)
            self.mapView.remove(self.baseCircle)
            self.radiusTextField.isHidden = false
            self.feetLabel.isHidden = false
            self.pin.isHidden = false
            self.backsound?.play()
            self.pointLocationSubmitted = 1
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set radius field
        self.radiusTextField.text = "40"
        
        //sounds
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
        self.entersoundlow?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
        self.backsound?.volume = 0.8
        
        //hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PointLocationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.pointLocationSystemTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PointLocationViewController.pointLocationSystemTimerUpdate), userInfo: nil, repeats: true)
        self.pointLocationSystemTimer.tolerance = 0.3
        
        self.updateBackgroundColor(isOffense: globalIsOffense)
        
        //numpad keyboard
        self.radiusTextField.keyboardType = UIKeyboardType.numberPad
        
        //keyboard hide
        self.radiusTextField.delegate = self
        
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.mapView.mapType = MKMapType.hybrid
        self.mapView.showsBuildings = true

    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if self.initialMapSetup == false {
//            self.initialMapSetup = true
//        self.mapCamera = MKMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), fromDistance: 400, pitch: 0, heading: 45)
//        self.mapView.setCamera(self.mapCamera, animated: false)
//            self.mapView.setCamera(self.mapCamera, animated: false)
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.initialMapSetup2 == false {
            let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
            self.initialMapSetup2 = true
            self.mapView.setRegion(region, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location manager fired:)")
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        self.latitude = location.latitude
        self.longitude = location.longitude
        //self.mapView.setRegion(region, animated: false)
        
        if self.initialMapSetup == false {
            let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
            self.initialMapSetup = true
        self.mapView.setRegion(region, animated: false)
        }
        
    }
    
    //RADIUS OVERLAY ON POINT AND BASE PIN MAP ANNOTATIONS
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay as! MKCircle  == self.baseCircle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 3.0
            overlayRenderer.strokeColor = UIColor.blue
            return overlayRenderer
        }
            
        else {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 3.0
            overlayRenderer.strokeColor = UIColor.red
            return overlayRenderer
        }
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        //set offense pins to blue color
//        if annotation is CustomPinBlue {
//            let pin3 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin3")
//            pin3.pinTintColor = UIColor.blueColor()
//            pin3.canShowCallout = true
//            return pin3
//        }
        
        if annotation is CustomPinBase {
            let baseDropPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "baseDropPin")
            baseDropPin.canShowCallout = true
            baseDropPin.image = UIImage(named:"basePin.png")
            baseDropPin.frame.size.height = 110
            baseDropPin.frame.size.width = 37
            return baseDropPin
        }
        
        //set flag graphic
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        //pin.pinTintColor = UIColor.redColor()
        pin.canShowCallout = true
        pin.image = UIImage(named:"robotMapFlag.png")
        pin.frame.size.height = 120
        pin.frame.size.width = 80
        return pin
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pointLocationSystemTimerUpdate() {
        if pointLocationSystemTimerCount > 0 {
            pointLocationSystemTimerCount -= 1
        }
        if pointLocationSystemTimerCount == 0 {
            SocketIOManager.sharedInstance.postHeartbeat(gameID: globalGameID)
            pointLocationSystemTimerCount = 3
        }
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.backsound?.play()
        self.pointLocationSystemTimer.invalidate()
        if globalItemsOn == false {
            self.performSegue(withIdentifier: "showGameOptionsViewControllerFromPointLocationViewController", sender: nil)
        } else {
        self.performSegue(withIdentifier: "showItemOptionsViewControllerFromPointLocationViewController", sender: nil)
        }
    }
    
    @IBAction func helpButton(_ sender: AnyObject) {
        
        if self.pointLocationSubmitted == 0 {
        self.displayAlert("Select flag zone", message: "Enter radius")
        }
        else if self.pointLocationSubmitted == 1 {
            self.displayAlert("Select base zone", message: "Enter radius")
        }
        else if self.pointLocationSubmitted == 2 {
            self.displayAlert("Begin Game", message: "Allows other players to join the game.  The game begins when after everybody joins.")
        }
    }
    
//    
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
