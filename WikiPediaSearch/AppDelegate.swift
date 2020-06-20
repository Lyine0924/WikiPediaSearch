//
//  AppDelegate.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/04/30.
//  Copyright © 2020 Lyine. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initWindow()
        return true
    }
    
    private func initWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.window?.rootViewController = UINavigationController(rootViewController: MVVMViewController())
        self.window?.makeKeyAndVisible()
    }
}

