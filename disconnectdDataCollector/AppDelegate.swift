//
//  AppDelegate.swift
//  disconnectdDataCollector
//
//  Created by user214504 on 2/13/22.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let backgroundAppDcDetectorTaskSchedulerIdentifier = "com.example.apple-samplecode.disconnectedDataCollector.dc_detector"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkBackgroundRefreshStatus()
        registerBackgroundFetch()
        return true
    }
    
    private func registerBackgroundFetch() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppDcDetectorTaskSchedulerIdentifier, using: nil) { (task) in
            print("BackgroundAppRefreshTaskScheduler is executed NOW!")
            task.expirationHandler = {
                print("Task expired")
                task.setTaskCompleted(success: false)
            }
            print("Refreshing app in background. Time remaining: \(UIApplication.shared.backgroundTimeRemaining) s")
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
        
    func submitBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        do {
            let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppDcDetectorTaskSchedulerIdentifier)
            backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: 5)
            try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
            print("Submitted task request")
        } catch {
            print("Failed to submit BGTask: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        if let vc = window?.rootViewController as? ViewController {
            if(!InternetConnection.isConnectedToNetwork()) {      
                // Disconnect detected
                print("disconnect detected")
                task.setTaskCompleted(success: true)
                vc.addEvent(event: Event())
            } else {
                task.setTaskCompleted(success: false)
            }
            submitBackgroundTasks()
        }
    }
    
    private func checkBackgroundRefreshStatus() {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            print("Background fetch is enabled")
        case .denied:
            print("Background fetch is explicitly disabled")
            
            // Redirect user to Settings page only once; Respect user's choice is important
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        case .restricted:
            // Should not redirect user to Settings since he / she cannot toggle the settings
            print("Background fetch is restricted, e.g. under parental control")
        default:
            print("Unknown property")
        }
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

