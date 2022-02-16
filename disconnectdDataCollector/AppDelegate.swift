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
        registerBackgroundTasks()
        return true
    }
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        submitBackgroundTasks()
    }
    
    private func registerBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist

        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppDcDetectorTaskSchedulerIdentifier, using: nil) { (task) in
           print("BackgroundAppRefreshTaskScheduler is executed NOW!")
           print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)")
           task.expirationHandler = {
             task.setTaskCompleted(success: false)
           }

           // Do some data fetching and call setTaskCompleted(success:) asap!
           let isFetchingSuccess = true
           task.setTaskCompleted(success: isFetchingSuccess)
         }
       }
    
    private func submitBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        do {
          let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppDcDetectorTaskSchedulerIdentifier)
          backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: 0)
          try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
          print("Submitted task request")
        } catch {
          print("Failed to submit BGTask")
        }
        
      }
    
    private func runConnectionDetectTask() {
        if let vc = window?.rootViewController as? ViewController {
            if(!InternetConnection.isConnectedToNetwork()) {
                // Disconnect detected
                print("disconnect detected")
                //vc.addEvent(event: Event())
            }
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

