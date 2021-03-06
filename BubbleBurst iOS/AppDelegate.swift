//
//  AppDelegate.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-09-30.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit
import FirebaseAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let defaults = UserDefaults.standard
    
    var window: UIWindow?
    static var player: AVAudioPlayer?
    static var soundPlayer: AVAudioPlayer?
    
    static var musicisPlaying = false
    static var justLaunched = true
    
    static var firstLaunch = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        if (defaults.value(forKey: "firstLaunch") != nil){
            AppDelegate.firstLaunch = defaults.bool(forKey: "firstLaunch")
        }
        incrementAppRuns()
        return true
    }
    
    class func playMusic() {
        
        guard let url = Bundle.main.url(forResource: "bgMusic", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            AppDelegate.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = AppDelegate.player else { return }
            
            player.play()
            player.numberOfLoops = -1
            player.volume = 0.5
            AppDelegate.musicisPlaying = true
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    class func playClick(){
        if (Menu.sound){
            playSound(source: "pop", type: "wav")
        }
    }
    
    class func playMoney(){
        if (Menu.sound){
            playSound(source: "money", type: "mp3")
        }
    }
    
    class func playError(){
        if (Menu.sound){
            playSound(source: "error", type: "mp3")
        }
    }
    
    class func playSound(source: String, type: String) {
        
        guard let url = Bundle.main.url(forResource: source, withExtension: type) else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let soundPlayer = soundPlayer else { return }
            
            soundPlayer.play()
            soundPlayer.volume = 0.25
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func incrementAppRuns() {
        var runs = 0
        if (defaults.value(forKey: "timesRun") != nil){
            runs = defaults.integer(forKey: "timesRun")
        }
        runs += 1
        defaults.set(runs, forKey: "timesRun")
        
        if (runs % 3 == 0) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        if (Menu.music) {
            AppDelegate.player?.pause()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "inactive"), object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if (Menu.music) {
            AppDelegate.player?.pause()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "inactive"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if (Menu.music) {
            AppDelegate.player?.play()
        }
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "active"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "active"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (Menu.music) {
            AppDelegate.player?.play()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "active"), object: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

