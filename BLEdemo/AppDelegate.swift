//
//  AppDelegate.swift
//  BLEdemo
//
//  Created by Duncan on 2016/6/30.
//  Copyright © 2016年 Duncan. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if #available(iOS 10, *) {
            ///Notifications get posted to the function (delegate):  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)"
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                guard error == nil else {return}
                
                if granted {
                    //Do stuff here..
                }
                else {
                    //Handle user denying permissions..
                }
            }
        }else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(knowIdentifierArr, forKey: "knowPeripheral")
    }


}

func scheduleLocal(sender: AnyObject) {
    let settings = UIApplication.shared().currentUserNotificationSettings()
    /*
    if settings?.types == .none {
        let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        return
    }
    */
    
    let notification = UILocalNotification()
    notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
    notification.alertBody = "You Pressed" + "\(sender)"
    notification.alertAction = "be awesome!"
    notification.soundName = UILocalNotificationDefaultSoundName
    notification.userInfo = ["CustomField1": "w00t"]
    UIApplication.shared().scheduleLocalNotification(notification)
}


