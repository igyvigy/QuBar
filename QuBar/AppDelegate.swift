//
//  AppDelegate.swift
//  QuBar
//
//  Created by Andrii Narinian on 2/14/17.
//  Copyright © 2017 Andrii. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let vc = UINib(nibName: "MainVc", bundle: nil).instantiate(withOwner: nil, options: nil).filter({ $0 is MainVc }).first as? MainVc {
            window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        return true
    }
}

