//
//  AppDelegate.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let def = UserDefaults.standard
        let is_authenticated = def.bool(forKey: "is_authenticated") // return false if not found or stored value
        let window = UIWindow()
        
        if is_authenticated {
            window.rootViewController = UINavigationController(rootViewController: MainViewController())
            window.makeKeyAndVisible()
            self.window = window
        } else {
            window.rootViewController = UINavigationController(rootViewController: LoginViewController())
            window.makeKeyAndVisible()
            self.window = window
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        } catch let error as NSError {
            print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
        
        
        return true
    }


}

