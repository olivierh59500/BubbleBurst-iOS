//
//  GameScene.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-09-30.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var bubbles = [Bubble]()
    var bubbleTimer:Timer!
    
    var gameTimer:Timer!

    var score = 0
    var lives = 10
    var time = 30
    var gameOver = false
    var gameEnded = false
    
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var timeLabel: SKLabelNode!

    var powerUpLabel: SKLabelNode!
    
    var oneUpTimer: Timer!
    var slowMoTimer: Timer!
    var freezeTimer: Timer!
    var superPopTimer: Timer!
    var autoPopTimer: Timer!
    
    var countdownTimer: Timer!
    
    var oneUp = 3
    var slowMo = 3
    var freeze = 5
    var superPop = 3
    var autoPop = 10
    
    var isOneUp = false
    var isSlowMo = false
    var isFreeze = false
    var isSuperPop = false
    var isAutoPop = false
    var beforeFreezeSpeed: Double = 0.0
    
    var oneUpIcon: SKSpriteNode!
    var slowMoIcon: SKSpriteNode!
    var freezeIcon: SKSpriteNode!
    var superPopIcon: SKSpriteNode!
    var autoPopIcon: SKSpriteNode!
    var timerIcon: SKSpriteNode!
    
    var pausedOverlay: SKSpriteNode!
    
    var pathEmitter: SKEmitterNode?
    
    let sizeUp = SKAction.scale(to: 1, duration: 1)
    let wait = SKAction.wait(forDuration: 2)
    let sizeDown = SKAction.scale(to: 0, duration: 1)
    
    let disappear = SKAction.scale(to: 1, duration: 0)
    
    var reveal: SKAction!
    
    var countdownAction: SKAction!
    
    static var gamePaused = false
    
    var startsIn = 3
    var gameMode: String!
    var player: AVAudioPlayer?

    override func sceneDidLoad() {
        let bg = SKSpriteNode(imageNamed: "BG (750x1334)")
        
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = -1
        self.addChild(bg)
        
        pausedOverlay = SKSpriteNode(imageNamed: "paused")
        
        pausedOverlay.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        pausedOverlay.zPosition = 2
        pausedOverlay.isHidden = true
        self.addChild(pausedOverlay)
        
        oneUpIcon = SKSpriteNode(imageNamed: "1Up")
        slowMoIcon = SKSpriteNode(imageNamed: "slowMo")
        freezeIcon = SKSpriteNode(imageNamed: "freeze")
        superPopIcon = SKSpriteNode(imageNamed: "superPop")
        autoPopIcon = SKSpriteNode(imageNamed: "auto")
        timerIcon = SKSpriteNode(imageNamed: "stopwatch")
        pathEmitter = SKEmitterNode(fileNamed: "MyParticle")
        
        timerIcon.position = CGPoint(x: 250,y: self.frame.height - 100)
        timerIcon.xScale = 0.07
        timerIcon.yScale = 0.07
        timerIcon.isHidden = true
        self.addChild(timerIcon)
        
        autoPopIcon.position = CGPoint(x: timerIcon.position.x + 100,y: self.frame.height - 100)
        autoPopIcon.xScale = 0.07
        autoPopIcon.yScale = 0.07
        autoPopIcon.isHidden = true
        self.addChild(autoPopIcon)
        
        slowMoIcon.position = CGPoint(x: autoPopIcon.position.x + autoPopIcon.size.width * 1.1,y: self.frame.height - 100)
        slowMoIcon.xScale = 0.07
        slowMoIcon.yScale = 0.07
        slowMoIcon.isHidden = true
        self.addChild(slowMoIcon)
        
        oneUpIcon.position = CGPoint(x: slowMoIcon.position.x + slowMoIcon.size.width * 1.1,y: self.frame.height - 100)
        oneUpIcon.xScale = 0.07
        oneUpIcon.yScale = 0.07
        oneUpIcon.isHidden = true
        self.addChild(oneUpIcon)
        
        freezeIcon.position = CGPoint(x: oneUpIcon.position.x + oneUpIcon.size.width * 1.1,y: self.frame.height - 100)
        freezeIcon.xScale = 0.07
        freezeIcon.yScale = 0.07
        freezeIcon.isHidden = true
        self.addChild(freezeIcon)
        
        superPopIcon.position = CGPoint(x: freezeIcon.position.x + freezeIcon.size.width * 1.1,y: self.frame.height - 100)
        superPopIcon.xScale = 0.07
        superPopIcon.yScale = 0.07
        superPopIcon.isHidden = true
        self.addChild(superPopIcon)
        
        reveal = SKAction.sequence([sizeUp, wait, sizeDown])
        countdownAction = SKAction.sequence([sizeUp, wait, disappear])
    }
    
    override func didMove(to view: SKView) {
        Bubble.gameMode = gameMode
        bubbleTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)
        bubbleTimer.invalidate()
        
        scoreLabel = SKLabelNode(fontNamed: "Bubblegum")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: 150,y: self.frame.height - 100)
        self.addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "Bubblegum")
        livesLabel.text = "\(lives)"
        livesLabel.fontSize = 40
        livesLabel.position = CGPoint(x: 150,y: self.frame.height - 200)
        
        if (gameMode == "Classic") {
            self.addChild(livesLabel)
        }
        
        timeLabel = SKLabelNode(fontNamed: "Bubblegum")
        timeLabel.text = "\(time)"
        timeLabel.fontSize = 40
        timeLabel.position = CGPoint(x: 150,y: self.frame.height - 200)
        if (gameMode == "Timed"){
            self.addChild(timeLabel)
        }
        
        timerLabel = SKLabelNode(fontNamed: "Bubblegum")
        timerLabel.text = "10"
        timerLabel.fontSize = 25
        timerLabel.position = CGPoint(x: 250,y: self.frame.height - 115)
        self.addChild(timerLabel)
        
        powerUpLabel = SKLabelNode(fontNamed: "Bubblegum")
        powerUpLabel.text = "SLOW-MO"
        powerUpLabel.fontSize = 60
        powerUpLabel.position = CGPoint(x: self.frame.width / 2,y: self.frame.height / 2)
        powerUpLabel.setScale(0)
        powerUpLabel.alpha = 60
        powerUpLabel.zPosition = 1
        self.addChild(powerUpLabel)
        
        startCountdown()
        
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        self.addChild(pathEmitter!)
        pathEmitter?.targetNode = self
    }
    
    func playPop() {
        
        guard let url = Bundle.main.url(forResource: "pop", withExtension: "wav") else {
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
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func startCountdown(){
        if startsIn >= 0 {
            powerUpLabel.text = "\(startsIn)"
            if (startsIn == 0){
                powerUpLabel.text = "START!"
            }
            powerUpLabel.run(countdownAction)
            startsIn -= 1
            let when = DispatchTime.now() + 1 // change 1 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.startCountdown()
            }
        }
        else {
            powerUpLabel.text = ""
            powerUpLabel.setScale(0)
            startBubbles()
            if (gameMode == "Timed") {
                gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    @objc func stopWatch(){
        if (time > 0){
            time -= 1
        }
        else {
            gameOver = true
            gameTimer.invalidate()
        }
        timeLabel.text = "\(time)"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //GameScene.gamePaused = false
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self)
        pathEmitter?.position = touchLocation
        
        if touch == touches.first {
            
            let touch = touches.first!
            for (i,bubble) in bubbles.enumerated().reversed() {
                if bubble.contains(touch.location(in: self)) {
                    //playPop()
                    if bubble.ifGreen() {
                        if (gameMode == "Classic"){
                            powerUp(bubble: bubble)
                        }
                        else if (gameMode == "Endless"){
                            endlessPowerUp(bubble: bubble)
                        }
                        else {
                            timedPowerUp(bubble: bubble)
                        }
                        if bubbles.count == 0 {
                            break
                        }
                    }
                    
                    if bubble.ifRed() {
                        if (gameMode == "Classic") {
                            lives = 0
                            gameOver = true
                        }
                        else {
                            if (score > 5){
                                score -= 6
                            }
                            else {
                                score = 0
                                gameOver = true
                            }
                        }
                    }
                    
                    bubble.removeFromParent()
                    bubbles.remove(at: i)
                    score += 1
                }
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self)
        pathEmitter?.position = touchLocation
        
        for touch in touches {
            //let position = touch.location(in: view)
            for (i,bubble) in bubbles.enumerated().reversed() {
                if bubble.contains(touch.location(in: self)) {
                    //playPop()
                    if bubble.ifGreen() {
                        if (gameMode == "Classic"){
                            powerUp(bubble: bubble)
                        }
                        else if (gameMode == "Endless"){
                            endlessPowerUp(bubble: bubble)
                        }
                        else {
                            timedPowerUp(bubble: bubble)
                        }
                        if bubbles.count == 0 {
                            break
                        }
                    }
                    
                    if bubble.ifRed() {
                        if (gameMode == "Classic") {
                            lives = 0
                            gameOver = true
                        }
                        else {
                            if (score > 5){
                                score -= 6
                            }
                            else {
                                score = 0
                                gameOver = true
                            }
                        }
                    }
                    bubble.removeFromParent()
                    bubbles.remove(at: i)
                    score += 1
                    //playPop()
                    
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        if !(isAutoPop || startsIn != -1) {
            //GameScene.gamePaused = true
        }
    }
    func timedPowerUp(bubble: Bubble){
        let powerUp = Int(arc4random_uniform(10))
        
        if powerUp <= 1 {
            timerIcon.isHidden = false
            isAutoPop = true
            autoPopIcon.isHidden = false
            autoPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(autoPopCountdown), userInfo: nil, repeats: true)
            powerUpLabel.text = "Auto Pop"
            powerUpLabel.run(reveal)
        }
            
        else if powerUp < 8 {
            
                freezeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(freezeCountdown), userInfo: nil, repeats: true)
                isFreeze = true
                Bubble.frozen = true
                beforeFreezeSpeed = Bubble.riseSpeed
                Bubble.riseSpeed = 0.0
                freezeIcon.isHidden = false
                powerUpLabel.text = "Freeze"
                powerUpLabel.run(reveal)
                if (gameMode == "Timed") {
                    gameTimer.invalidate()
                }
            
        }
        else if powerUp < 10 {
            superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
            isSuperPop = true
            score += bubbles.capacity
            for bubble in bubbles {
                bubble.removeFromParent()
            }
            bubbles.removeAll()
            superPopIcon.isHidden = false
            powerUpLabel.text = "Super Pop"
            powerUpLabel.run(reveal)
            //break
        }
        
    }
    
    func endlessPowerUp(bubble: Bubble){
        let powerUp: Int!
        if (Bubble.riseSpeed > 5){
            powerUp = Int(arc4random_uniform(30))
            
            if powerUp <= 3 {
                timerIcon.isHidden = false
                isAutoPop = true
                autoPopIcon.isHidden = false
                autoPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(autoPopCountdown), userInfo: nil, repeats: true)
                powerUpLabel.text = "Auto Pop"
                powerUpLabel.run(reveal)
            }
                
            else if powerUp < 10 {
                if (Bubble.riseSpeed > 15){
                    freezeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(freezeCountdown), userInfo: nil, repeats: true)
                    isFreeze = true
                    Bubble.frozen = true
                    beforeFreezeSpeed = Bubble.riseSpeed
                    Bubble.riseSpeed = 0.0
                    freezeIcon.isHidden = false
                    powerUpLabel.text = "Freeze"
                    powerUpLabel.run(reveal)
                }
                else {
                    slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                    isSlowMo = true
                    Bubble.riseSpeed = Bubble.riseSpeed / 2.0
                    slowMoIcon.isHidden = false
                    powerUpLabel.text = "Slow-mo"
                    powerUpLabel.run(reveal)
                }
            }
            else if powerUp < 20 {
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                superPopIcon.isHidden = false
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
                //break
            }
                
            else if powerUp <= 30 {
                slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                isSlowMo = true
                Bubble.riseSpeed = Bubble.riseSpeed / 2.0
                slowMoIcon.isHidden = false
                powerUpLabel.text = "Slow-mo"
                powerUpLabel.run(reveal)
            }
        }
            
        else {
            
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                superPopIcon.isHidden = false
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
                //break
            
        }
    }
    
    func powerUp(bubble: Bubble){
        let powerUp: Int!
        if (Bubble.riseSpeed > 5){
            powerUp = Int(arc4random_uniform(33))
            
            if powerUp <= 3 {
                timerIcon.isHidden = false
                isAutoPop = true
                autoPopIcon.isHidden = false
                autoPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(autoPopCountdown), userInfo: nil, repeats: true)
                powerUpLabel.text = "Auto Pop"
                powerUpLabel.run(reveal)
            }
                
            else if powerUp < 10 {
                if (Bubble.riseSpeed > 15){
                    freezeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(freezeCountdown), userInfo: nil, repeats: true)
                    isFreeze = true
                    Bubble.frozen = true
                    beforeFreezeSpeed = Bubble.riseSpeed
                    Bubble.riseSpeed = 0.0
                    freezeIcon.isHidden = false
                    powerUpLabel.text = "Freeze"
                    powerUpLabel.run(reveal)
                }
                else {
                    slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                    isSlowMo = true
                    Bubble.riseSpeed = Bubble.riseSpeed / 2.0
                    slowMoIcon.isHidden = false
                    powerUpLabel.text = "Slow-mo"
                    powerUpLabel.run(reveal)
                }
            }
            else if powerUp < 20 {
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                superPopIcon.isHidden = false
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
                //break
            }
                
            else if powerUp < 30 {
                slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                isSlowMo = true
                Bubble.riseSpeed = Bubble.riseSpeed / 2.0
                slowMoIcon.isHidden = false
                powerUpLabel.text = "Slow-mo"
                powerUpLabel.run(reveal)
            }
                
            else if powerUp <= 33 {
                lives += 1
                oneUpTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneUpCountdown), userInfo: nil, repeats: true)
                isOneUp = true
                oneUpIcon.isHidden = false
                powerUpLabel.text = "1 Up"
                powerUpLabel.run(reveal)
            }
        }
            
        else {
            let powerUp = Int(arc4random_uniform(10))
            if powerUp == 0 {
                lives += 1
                oneUpTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneUpCountdown), userInfo: nil, repeats: true)
                isOneUp = true
                oneUpIcon.isHidden = false
                powerUpLabel.text = "1 Up"
                powerUpLabel.run(reveal)
            }
            else if powerUp <= 10 {
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                superPopIcon.isHidden = false
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
                //break
            }
        }
    }
    
    @objc func oneUpCountdown(){
        if isOneUp {
            oneUp -= 1
        }
        if (oneUp == 0) {
            isOneUp = false
            oneUp = 3
            oneUpIcon.isHidden = true
            oneUpTimer.invalidate()
        }
    }
    
    @objc func slowMoCountdown(){
        if isSlowMo {
            slowMo -= 1
        }
        if (slowMo == 0) {
            isSlowMo = false
            slowMo = 3
            slowMoIcon.isHidden = true
            slowMoTimer.invalidate()
        }
    }
    
    @objc func freezeCountdown(){
        if isFreeze {
            freeze -= 1
        }
        if (freeze == 0) {
            isFreeze = false
            Bubble.frozen = false
            Bubble.riseSpeed = beforeFreezeSpeed / 2
            startBubbles()
            freeze = 5
            freezeIcon.isHidden = true
            freezeTimer.invalidate()
            if (gameMode == "Timed") {
                gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func superPopCountdown(){
        if isSuperPop {
            superPop -= 1
        }
        if (superPop == 0) {
            isSuperPop = false
            superPop = 3
            superPopIcon.isHidden = true
            superPopTimer.invalidate()
        }
    }
    
    @objc func autoPopCountdown() {
        if isAutoPop {
            autoPop -= 1
        }
        
        if (autoPop == 0) {
            isAutoPop = false
            autoPop = 10
            autoPopIcon.isHidden = true
            timerIcon.isHidden = true
            autoPopTimer.invalidate()
        }
    }
    
    func playAgain(){
        if (bubbleTimer != nil) {
            bubbleTimer.invalidate()
            bubbleTimer = nil
        }
        time = 30
        startsIn = 3
        lives = 10
        score = 0
        scoreLabel.text = ""
        livesLabel.text = "10"
        timeLabel.text = "30"
        startCountdown()
        for (i,bubble) in bubbles.enumerated().reversed() {
            bubbles.remove(at: i)
            bubble.removeFromParent()
        }
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        Bubble.riseSpeed = 4.0
        Bubble.frozen = false
        gameEnded = false
        gameOver = false
        GameScene.gamePaused = false
        
        isOneUp = false
        isSlowMo = false
        isFreeze = false
        isSuperPop = false
        isAutoPop = false
        
        oneUp = 3
        slowMo = 3
        freeze = 5
        superPop = 3
        autoPop = 10
        oneUpIcon.isHidden = true
        slowMoIcon.isHidden = true
        freezeIcon.isHidden = true
        superPopIcon.isHidden = true
        autoPopIcon.isHidden = true
        timerIcon.isHidden = true
    }
    
    func reset(){
        if (gameMode == "Timed") {
            gameTimer.invalidate()
        }
        bubbleTimer.invalidate()
        slowMoTimer?.invalidate()
        freezeTimer?.invalidate()
        autoPopTimer?.invalidate()
        superPopTimer?.invalidate()
        oneUpTimer?.invalidate()
    }
    
    func endGame(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "seguetoGameOver"), object: nil)
        //reset()
    }
    
    @objc func addBubble() {
        if (!(isFreeze || GameScene.gamePaused || gameOver)) {
            let bubble = Bubble()
            bubbles.append(bubble)
            bubble.name = "bubble"
            bubble.isUserInteractionEnabled = false
            self.addChild(bubble)
        }
    }
    
    /*func stopBubbles(){
     if (bubbleTimer.isValid) {
     bubbleTimer.invalidate()
     }
     }*/
    
    func startBubbles(){
        var timeInterval: Double!
        
        if gameMode == "Timed" {
            timeInterval = 0.1
        }
        else {
            timeInterval = 0.5
        }
        if (bubbleTimer != nil) {
            if (!bubbleTimer.isValid) {
                bubbleTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)
            }
        }
        else {
            bubbleTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)

        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if (gameOver && !gameEnded) {
            endGame()
            gameEnded = true
        }
        if (GameScene.gamePaused) {
            pausedOverlay.isHidden = false
            //stopBubbles()
        }
        else {
            pausedOverlay.isHidden = true
            //if (startsIn < 0){
            //    countdownTimer.invalidate()
            //    startBubbles()
            //}
            //else if (!bubbleTimer.isValid && !gameOver){
            //   startBubbles()
            //}
        }
        for (i,bubble) in bubbles.enumerated().reversed() {
            bubble.update()
            if (gameMode == "Classic") {
                if (bubble.getY() > 1400){
                    bubbles.remove(at: i)
                    bubble.removeFromParent()
                    if lives > 0 && bubble.ifBlue(){
                        lives -= 1
                    }
                }
                if lives <= 0 {
                    gameOver = true
                }
            }
            
        }
        
        
        livesLabel.text = "\(lives)"
        scoreLabel.text = "\(score)"
        
        if (isAutoPop) {
            timerLabel.text = "\(autoPop)"
            for (i,bubble) in bubbles.enumerated().reversed() {
                if (bubble.getY() >= self.frame.height / 2 && bubble.ifBlue()){
                    //playPop()
                    bubbles.remove(at: i)
                    bubble.removeFromParent()
                    score += 1
                }
            }
        }
        else {
            timerLabel.text = ""
        }
    }
}

class Bubble: SKSpriteNode {
    var bubbleSize: Int
    var type: Int
    var x: Int
    var y = 0
    static var riseSpeed = 4.0
    static var frozen = false
    static var gameMode: String!
    
    var red = false
    var green = false
    
    init() {
        bubbleSize = Int(arc4random_uniform(3))
        if (Bubble.gameMode != "Timed") {
            type = Int(arc4random_uniform(100))
        }
        
        else {
            type = Int(arc4random_uniform(88))
            Bubble.riseSpeed = 17
        }
        
        var texture = SKTexture(imageNamed: "Bubble")
        
        if (type < 85){
            if (bubbleSize == 1) {
                texture = SKTexture(imageNamed: "Bubble2")
            }
                
            else if (bubbleSize == 2) {
                texture = SKTexture(imageNamed: "Bubble3")
            }
                
            else if (bubbleSize == 3) {
                texture = SKTexture(imageNamed: "Bubble4")
            }
        }
            
        else if (type <= 90) {
            green = true
            if (bubbleSize == 0) {
                texture = SKTexture(imageNamed: "BubbleG")
            }
                
            else if (bubbleSize == 1) {
                texture = SKTexture(imageNamed: "BubbleG2")
            }
                
            else if (bubbleSize == 2) {
                texture = SKTexture(imageNamed: "BubbleG3")
            }
                
            else if (bubbleSize == 3) {
                texture = SKTexture(imageNamed: "BubbleG4")
            }
        }
            
        else if (type < 100) {
            red = true
            if (bubbleSize == 0) {
                texture = SKTexture(imageNamed: "BubbleR")
            }
                
            else if (bubbleSize == 1) {
                texture = SKTexture(imageNamed: "BubbleR2")
            }
                
            else if (bubbleSize == 2) {
                texture = SKTexture(imageNamed: "BubbleR3")
            }
                
            else if (bubbleSize == 3) {
                texture = SKTexture(imageNamed: "BubbleR4")
            }
        }
            
        
        
        
        let randomBubbleX = GKRandomDistribution(lowestValue:Int(texture.size().width/2), highestValue: 750 - Int(texture.size().width/2))
        x = randomBubbleX.nextInt()
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        //self.isHidden = true
    }
    
    func ifBlue() -> Bool {
        return !(red || green)
    }
    func ifRed() -> Bool {
        return red
    }
    
    func ifGreen() -> Bool {
        return green
    }
    func getX() -> CGFloat {
        return CGFloat(x)
    }
    
    func getY() -> CGFloat {
        return CGFloat(y)
    }
    func getBubbleSize() -> CGSize {
        return self.frame.size
    }
    func update(){
        if !GameScene.gamePaused {
            if Bubble.frozen {
                Bubble.riseSpeed = 0.0
            }
            if (Bubble.gameMode != "Timed") {
                if (Bubble.riseSpeed < 20) {
                    Bubble.riseSpeed += 0.01
                }
            }
            y += Int(Bubble.riseSpeed)
            self.position = CGPoint(x: x, y: y)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
