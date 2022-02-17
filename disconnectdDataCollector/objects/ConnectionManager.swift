//
//  ConnectionManager.swift
//  disconnectdDataCollector
//
//  Created by user214504 on 2/16/22.
//

import Foundation
import Reachability

class ConnectionManager {
    
    static let shared = ConnectionManager()
    private var reachability : Reachability!
    private var isObserverInitated = false
    
    func observeReachability() {
        self.reachability = try! Reachability()
        if(!isObserverInitated) {
            NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
            isObserverInitated = true
        }
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }

    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            break
        case .wifi:
            print("Network available via WiFi.")
            notifyEvent()
            break
        case .unavailable:
            print("Network is  unavailable.")
            break
        }
    }
    
    func notifyEvent() {
        let name = Notification.Name(rawValue: DisconnectNotficationKey)
        NotificationCenter.default.post(name: name,object: nil)
    }
}
