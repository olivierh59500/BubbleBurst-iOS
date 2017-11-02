//
//  AppDelegate.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-09-30.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var player: AVAudioPlayer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //playMusic()
        return true
    }
    
    class func playMusic() {
        
        guard let url = Bundle.main.url(forResource: "bgMusic", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        /*var backgroundaudio = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource( "seve", ofType: "mp3")!), error: nil)*/
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            //player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            /* iOS 10 and earlier require the following line:*/
            AppDelegate.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = AppDelegate.player else { return }
            
            player.play()
            player.numberOfLoops = -1
            player.volume = 0.5
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        GameScene.gamePaused = true
        if (Menu.music) {
            AppDelegate.player?.pause()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GameScene.gamePaused = true
        if (Menu.music) {
            AppDelegate.player?.pause()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        GameScene.gamePaused = false
        if (Menu.music) {
            AppDelegate.player?.play()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        GameScene.gamePaused = false
        if (Menu.music) {
            AppDelegate.player?.play()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

