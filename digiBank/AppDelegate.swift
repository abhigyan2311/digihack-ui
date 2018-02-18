//
//  AppDelegate.swift
//  digiBank
//
//  Created by Abhigyan Singh on 15/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Bolts
import Parse
import CoreLocation
import IQKeyboardManagerSwift
import UserNotifications

@available(iOS 11, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager:CLLocationManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let config = ParseClientConfiguration(block: {
            (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "appKey231195";
            ParseMutableClientConfiguration.server = "http://ec2-13-127-176-156.ap-south-1.compute.amazonaws.com:1337/parse";
            ParseMutableClientConfiguration.isLocalDatastoreEnabled = true;
        });
        Parse.initialize(with: config);
        
        let defaultACL = PFACL();
        PFACL.setDefault(defaultACL, withAccessForCurrentUser:true)
        
        registerForPushNotifications()
        determineMyCurrentLocation()
        
        IQKeyboardManager.sharedManager().enable = true
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation!.setDeviceTokenFrom(deviceToken)
        installation!.channels = ["global","ios"]
        installation!.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let user = PFUser.current()
        if user != nil {
            PFCloud.callFunction(inBackground: "geo", withParameters: ["sessionToken": user!.sessionToken!, "lat":userLocation.coordinate.latitude, "long":userLocation.coordinate.longitude]) { (result, error) in
                if error == nil {
                    print(result!)
                } else {
                    print(error)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func registerForPushNotifications() {
        // iOS 10 support
        if #available(iOS 11, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
                guard granted else { return }
                self.getNotificationSettings()
            }
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            if UIApplication.shared.isRegisteredForRemoteNotifications == false {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }


}

