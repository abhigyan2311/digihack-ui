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
        
        determineMyCurrentLocation()
        
        return true
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
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startMonitoringSignificantLocationChanges()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
//        PFCloud.callFunction(inBackground: "geo", withParameters: ["lat":userLocation.coordinate.latitude, "long":userLocation.coordinate.longitude]) { (result, error) in
//            if error == nil {
//                print(result!)
//            } else {
//                print(error)
//            }
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }


}

