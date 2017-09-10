//
//  SocketIOManager.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 7/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import SocketIO
//let serverAddress: URL = NSURL(string: "http://localhost:5000/")! as URL
let serverAddress: URL = NSURL(string: "http://34.212.243.222:5000/")! as URL


class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: serverAddress)
    
    override init() {
        super.init()
    }
    
    func establishConnection(namespace: String) {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func listenForWaitingUserUpdates(gameID: String, completionHandler: @escaping (_ userList: [String : [String : Any]], _ gameState: Int) -> Void) {
        socket.on("updateWaitingUsers") { (dataArray, ack) -> Void in
            print("YO")
            print(dataArray)
            let userDict = dataArray[0] as! [String : [String : Any]]
            let gameState = dataArray[1] as! Int
            completionHandler(userDict, gameState)
        }
        socket.emit("getWaitingUsers", gameID, true)
    }
    
    func stopListeningForWaitingUserUpdates() {
        socket.off("updateWaitingUsers")
    }
    
    func getWaitingUserUpdates(gameID: String) {
        socket.emit("getWaitingUsers", gameID, false)
    }
    
    func leaveQueuedGame(gameID: String) {
        stopListeningForWaitingUserUpdates()
        socket.emit("leaveGame", gameID, UDID)
    }
    
    func postHeartbeat(gameID: String) {
        socket.emit("postHeartbeat", gameID)
    }
    
    func switchTeams(gameID: String, udid: String, completionHandler: @escaping(_ success: Bool) -> Void) {
        socket.emitWithAck("switchTeams", gameID, udid).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    func createGame(gameID: String, udid: String, completionHandler: @escaping(_ canCreate: Bool) -> Void) {
        socket.emitWithAck("createGame", gameID, udid).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func stopCreatingGame(gameID: String, udid: String, completionHandler: @escaping(_ didStop: Bool) -> Void) {
        socket.emitWithAck("stopCreatingGame", gameID, udid).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func joinGame(gameID: String, udid: String, completionHandler: @escaping(_ canProceed: Bool) -> Void) {
        socket.emitWithAck("joinGame", gameID, udid).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func getGameConfig(gameID: String, completionHandler: @escaping(_ gameConfig: [String: Any],_ playerConfig: [String: [String: Any] ]) -> Void) {
        socket.emitWithAck("getGameConfig", gameID).timingOut(after: 3) {data in
            completionHandler(data[0] as! [String: Any], data[1] as! [String: [String: Any] ])
        }
    }
    
    func postGameOptions(gameID: String,
                         tagSensitivity: Int,
                         gameLength: Int,
                         captureTime: Int,
                         itemsEnabled: Bool,
                         testModeEnabled: Bool,
                         completionHandler: @escaping(_ canProceed: Bool) -> Void) {
        socket.emitWithAck("postGameOptions", gameID, tagSensitivity, gameLength, captureTime, itemsEnabled, testModeEnabled).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func postItemOptions(gameID: String,
                         offenseStartingFunds: Int,
                         defenseStartingFunds: Int,
                         itemAbundanceOffense: Int,
                         itemAbundanceDefense: Int,
                         itemPricesOffense: [Int],
                         itemPricesDefense: [Int],
                         itemsDisabledOffense: [Bool],
                         itemsDisabledDefense: [Bool],
                         itemModeOn: Bool,
                         completionHandler: @escaping(_ canProceed: Bool) -> Void) {
        socket.emitWithAck("postItemOptions", gameID, offenseStartingFunds, defenseStartingFunds, itemAbundanceOffense, itemAbundanceDefense, itemPricesOffense, itemPricesDefense, itemsDisabledOffense, itemsDisabledDefense, itemModeOn).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func postPointLocation(gameID: String,
                           point_lat: Double,
                           point_lon: Double,
                           point_radius: Double,
                           base_lat: Double,
                           base_lon: Double,
                           base_radius: Double,
                         completionHandler: @escaping(_ canProceed: Bool) -> Void) {
        socket.emitWithAck("postPointLocation", gameID, point_lat, point_lon, point_radius, base_lat, base_lon, base_radius).timingOut(after: 3) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func listenForGameStart(gameID: String, completionHandler: @escaping (_ gameStartTime: Int) -> Void) {
        socket.on("updateDidGameStart") { (dataArray, ack) -> Void in
            let gameStartTime = dataArray[0] as! Int
            completionHandler(gameStartTime)
        }
        socket.emit("getDidGameStart", gameID)
    }
    
    func stopListeningForGameStart() {
        socket.off("getDidGameStart")
    }
    
    func getDidGameStart(gameID: String) {
        socket.emit("getDidGameStart", gameID)
    }
    
    func updateGameState(gameID: String,
                         position: String,
                         status: Int,
                         latitude: Double,
                         longitude: Double,
                         completionHandler: @escaping(_ playerState: [String: [String: Any] ], _ otherState: [String: Any]) -> Void) {
        socket.emitWithAck("updateGameState", gameID, position, status, latitude, longitude).timingOut(after: 2) {data in
            if data[0] as? String != "NO ACK" {
                completionHandler(data[0] as! [String: [String: Any] ], data[1] as! [String: Any] )
            }
        }
    }
    
    func listenForGameEvents(completionHandler: @escaping (_ gameEvent: [String: Any]) -> Void) {
        socket.on("sendGameEvent") { (dataArray, ack) -> Void in
            completionHandler(dataArray[0] as! [String: Any] )
        }
    }
    
    func stopListeningForGameEvents() {
        socket.off("sendGameEvent")
    }
    
    func postGameEvent(gameID: String,
                       eventName: String,
                       sender: String,
                       recipient: String,
                       latitude: Double,
                       longitude: Double,
                       extra: String,
                       timingOut: Double = 3,
                       completionHandler: @escaping(_ didPost: Bool) -> Void) {
        socket.emitWithAck("postGameEvent", gameID, sender, eventName, recipient, latitude, longitude, extra).timingOut(after: timingOut) {data in
            if data[0] as? String == "NO ACK" {
                completionHandler(false)
            } else {
                completionHandler(data[0] as! Bool)
            }
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        SocketIOManager.sharedInstance.establishConnection(namespace: globalGameID)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
    }
    
}
