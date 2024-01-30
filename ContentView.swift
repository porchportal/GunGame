//
//  ContentView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 19/12/2566 BE.
//

import SwiftUI
import SpriteKit
import AVFAudio
import GameKit



struct CBitmask {
    static let None: UInt32 = 0
    static let player_Ship: UInt32 = 0b1            // 1
    static let player_Fire: UInt32 = 0b10           // 2
    static let enemy_Ship: UInt32 = 0b100           // 4
    static let bossOne: UInt32 = 0b1000             // 8
    static let bossOneFire: UInt32 = 0b10000        // 16
    static let bossTwo: UInt32 = 0b100000
    static let bossTwoFire: UInt32 = 0b1000000
    static let enemy_ShipTwo: UInt32 = 0b10000000
}
protocol GameViewModelUpdatable {
    var gameOver: Bool { get set }
    // Other state properties or methods
}
class Game_Scene: SKScene, SKPhysicsContactDelegate, ObservableObject, GameViewModelUpdatable{
    var backgroundMusicPlayer: AVAudioPlayer?
    var bossMusicPlayer: AVAudioPlayer?
    let fadeDuration: TimeInterval = 1.0
    var backgroundTimer = Timer()
    var backgroundActive = false
    var player = SKSpriteNode()
    @objc var PlayerFire = SKSpriteNode()
    var enemy = SKSpriteNode()
    
    var isShooting = false
    var fireRate = 0.3
    var lastTouchTime = TimeInterval()
    var tapCount = 0
    
    var bossOneFire = SKSpriteNode()
    
    
    
    @Published var gameOver: Bool = false
    
    @Published var score = 0
    var scoreLabel = SKLabelNode()
    var Live_Array = [SKSpriteNode]()
    
    
    var FireTimer = Timer()
    var enemyTimer = Timer()
    var enemyActive = false
    
    //BossOne
    var BossOneFireTimer = Timer()
    var BossOneFire_Type = 1
    var BossOneFire_Type2_Live = 2
    var BossOneFire_Type4_Live = 4
    var bossOneLives = 30
    var BossOneActive = false
    var bossyOne = SKSpriteNode()
    var SpawnCount: Double = 0
    var statusOfBossOne: Int = 0
    
    //BossTwo
    var BossyTwo = SKSpriteNode()
    var BossTwoFire = SKSpriteNode()
    var BossTwoFireTimer = Timer()
    var bossTwoLives = 30
    var BossTwoActive = false

    var enemyTwo = SKSpriteNode()
    
    var StatusCount = 0
    var SpeedOpposite = 2.0
    //@Published var NUM = 0
    let bossHealthLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    var bossOneHealthBar: SKSpriteNode?
    var bossTwoHealthBar: SKSpriteNode?
    
    var originalPlayerRotation: CGFloat = 0
    var isGamePaused = false
    let defaultPlayerRotation: CGFloat = 0.0
    var isCollisionHandled = false
    var tapToStartLabel = SKLabelNode()
    var levelNumber : Int = 0
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    var currentGameState = gameState.preGame
    func random() -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random()*(max - min) + min
    }
    
    var gameArea: CGRect
    //var viewModel: GameViewModelUpdatable
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth)/2.0
        gameArea = CGRect(x: 0, y: margin, width: size.width, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){/*
        if background.parent != nil {
            background.removeFromParent()
        }*/
        if scoreLabel.parent != nil {
            scoreLabel.removeFromParent()
        }
        if bossHealthLabel.parent != nil {
            bossHealthLabel.removeFromParent()
        }
        
        if let existingPlayer = self.childNode(withName: "Player") {
            existingPlayer.removeFromParent()
        }
        setupAudioSession()
        physicsWorld.contactDelegate = self
        scene?.size = CGSize(width: 750, height: 1335)
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "LoopImage1")
            background.size = CGSize(width: 1024, height: 1792)
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: size.width/2,
                                          y: background.size.height*CGFloat(i)-60)
            background.zPosition = -4
            background.alpha = 0.4
            background.name = "Background"
            self.addChild(background)
        }
        
        makePlayer(playerCh: shipChoice.integer(forKey: "playerChoice"))
        playMusic("gameMain.mp3", isBossMusic: false)
        //enemyTimer = .scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 50
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontColor = .green
        scoreLabel.zPosition = 10
        scoreLabel.position = CGPoint(x: size.width/6, y: size.height*0.91)
        addChild(scoreLabel)
        
        bossHealthLabel.text = "Boss Health"
        bossHealthLabel.isHidden = true
        bossHealthLabel.fontSize = 30
        bossHealthLabel.alpha = 0.5
        bossHealthLabel.fontColor = .red
        bossHealthLabel.zPosition = 4
        bossHealthLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
        addChild(bossHealthLabel)
        
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontName = "Chalkduster"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(tapToStartLabel)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
        addLive(lives: 5)
    }
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amoutToMovePerSecond: CGFloat = 600
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amoutToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background"){background, stop in
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
    }
    func startGame(){
        currentGameState = gameState.inGame
        if let particles = SKEffectNode(fileNamed: "Space"){
            particles.position = CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height*1.7)
            particles.zPosition = 0
            addChild(particles)
        }
        backgroundTimer = .scheduledTimer(timeInterval: 5, target: self, selector: #selector(Background), userInfo: nil, repeats: true)
        if let fireThunderPath = Bundle.main.path(forResource: "Thunder", ofType: "sks"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: fireThunderPath)) {
            
            do {
                let fireThruster = try NSKeyedUnarchiver.unarchivedObject(ofClass: SKEmitterNode.self, from: data) as SKEmitterNode?
                fireThruster?.xScale = 1.5
                fireThruster?.yScale = 1.5
                fireThruster?.particleRotation = .pi
                let fireThrusterEffectNode = SKEffectNode()
                if let fireThruster = fireThruster {
                    fireThrusterEffectNode.addChild(fireThruster)
                }
                fireThrusterEffectNode.zPosition = 3
                fireThrusterEffectNode.position.y = -90
                player.addChild(fireThrusterEffectNode)
                
                let wait = SKAction.wait(forDuration: 1.0)
                let fadeout = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                fireThrusterEffectNode.run(SKAction.sequence([wait, fadeout, remove]))
            } catch {
                print("Error unarchiving file: \(error)")
            }
        }
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        tapToStartLabel.run(SKAction.sequence([fadeOutAction,delete]))
        let moveShipOntoScreen = SKAction.moveTo(y: size.height*0.2, duration: 1)
        
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreen,startLevelAction])
        player.run(startGameSequence)
    }
    func startNewLevel(){
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        levelNumber += 1
        var levelDuration = TimeInterval()
        switch levelNumber{
        case 1:
            levelDuration = 1.2
        case 2: 
            levelDuration = 1
        case 3: 
            levelDuration = 0.8
        case 4: 
            levelDuration = 0.5
        default:
            levelDuration = 0.3
            print("Cannot find level info")
        }
        //let spwn = SKAction.run(spawnEnemy)
        let spwn = SKAction.run{ [weak self] in
            guard let self = self, !self.isPaused else { return }
            if self.BossOneActive == false{
                self.spawnEnemy()
            } else if self.BossTwoActive == false{
                self.spawnEnemy()
            }
        }
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spwanSequence = SKAction.sequence([waitToSpawn, spwn])
        let spawnForever = SKAction.repeatForever(spwanSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    @objc func Background(){
        backgroundActive = true
        let randomXstart = random(min: 0, max: UIScreen.main.bounds.width*2)
        let randomXEnd = random(min: 0, max: UIScreen.main.bounds.width*2)
        let effectNode = SKEffectNode()
        
        let startPoint = CGPoint(x: randomXstart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        scene?.size = CGSize(width: 750, height: 1335)
        var backgroundObject = SKSpriteNode()
        let object1 = SKSpriteNode(imageNamed: "IMG_2001")
        let object2 = SKSpriteNode(imageNamed: "IMG_2002")
        let object3 = SKSpriteNode(imageNamed: "IMG_2003")
        
        effectNode.filter = CIFilter(name: "CIGaussianBlur")
        effectNode.shouldEnableEffects = true
        effectNode.addChild(backgroundObject)
        
        let objects = [object1, object2, object3]
        backgroundObject = objects[Int.random(in: 0..<objects.count)]
        backgroundObject.position = startPoint
        backgroundObject.zPosition = 0
        backgroundObject.alpha = 0.5
        let move = SKAction.move(to: endPoint, duration: 10)
        let delete = SKAction.removeFromParent()
        let rotation = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8)
        let groupActions = SKAction.group([SKAction.repeatForever(rotation), move])
        let Sequence = SKAction.sequence([groupActions, delete])
        backgroundObject.run(Sequence)
        self.addChild(backgroundObject)
    }
    // Music
    func playMusic(_ filename: String, isBossMusic: Bool) {
        // Fade out current music
        if let currentPlayer = isBossMusic ? backgroundMusicPlayer : bossMusicPlayer, currentPlayer.isPlaying {
            fadeOutMusic(player: currentPlayer)
        }
        
        // Load and play new music
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
            guard let url = resourceUrl else {
                print("Could not find file: \(filename)")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0 // Start with volume at 0 for fade in
                if isBossMusic {
                    self.bossMusicPlayer = player
                } else {
                    self.backgroundMusicPlayer = player
                    self.backgroundMusicPlayer?.numberOfLoops = -1 // Loop infinitely for background music
                }
                player.play()
                self.fadeInMusic(player: player)
            } catch {
                print("Could not create audio player: \(error)")
            }
        }
    }
    func fadeOutMusic(player: AVAudioPlayer) {
        // Reduce volume to 0 over the fade duration
        if player.volume > 0.1 {
            UIView.animate(withDuration: fadeDuration, animations: {
                player.volume = 0
            }) { completed in
                if completed {
                    player.stop()
                }
            }
        } else {
            player.stop()
        }
    }
    func fadeInMusic(player: AVAudioPlayer) {
        // Increase volume to 1 over the fade duration
        UIView.animate(withDuration: fadeDuration) {
            player.volume = 1
        }
    }
    func pauseGame() {
        self.isPaused = true
        isGamePaused = true
        backgroundMusicPlayer?.stop()
        bossMusicPlayer?.stop()
        if enemyActive{
            enemyTimer.invalidate()
        }
        if backgroundActive{
            backgroundTimer.invalidate()
        }
        //enemyTimer.invalidate()
        BossOneFireTimer.invalidate()
        BossTwoFireTimer.invalidate()
        BossOneActive = false
        BossTwoActive = false
        self.removeAction(forKey: "spawningEnemies")
    }
    func resumeGame() {
        self.isPaused = false

        if isGamePaused {
            if BossOneActive {
                BossOneFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            }
            if BossTwoActive {
                BossTwoFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossTwoFireFunc), userInfo: nil, repeats: true)
            }
            if enemyActive {
                enemyTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
            }
            if backgroundActive {
                backgroundTimer = .scheduledTimer(timeInterval: 6, target: self, selector: #selector(Background), userInfo: nil, repeats: true)
            }
            if BossOneActive && BossTwoActive {
                BossTwoFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossTwoFireFunc), userInfo: nil, repeats: true)
                BossOneFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            }
            startNewLevel()
            isGamePaused = false
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        } else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        // Player's fire hitting the enemy ship
        if (contactA.categoryBitMask == CBitmask.player_Fire && contactB.categoryBitMask == CBitmask.enemy_Ship) ||
           (contactB.categoryBitMask == CBitmask.player_Fire && contactA.categoryBitMask == CBitmask.enemy_Ship) {
            handleCollisionPlayerFireWithEnemy(contactA.node, contactB.node)
        }
        // Player's fire hitting the enemy 2 ship ++++
        if (contactA.categoryBitMask == CBitmask.player_Fire && contactB.categoryBitMask == CBitmask.enemy_ShipTwo) ||
           (contactB.categoryBitMask == CBitmask.player_Fire && contactA.categoryBitMask == CBitmask.enemy_ShipTwo) {
            handleCollisionPlayerFireWithEnemyTwo(contactA.node, contactB.node)
        }
        // Playership hitting the enemy ship ++++
        if (contactA.categoryBitMask == CBitmask.player_Ship && contactB.categoryBitMask == CBitmask.enemy_Ship) ||
           (contactB.categoryBitMask == CBitmask.player_Ship && contactA.categoryBitMask == CBitmask.enemy_Ship) {
            handleCollisionPlayerShipHitWithEnemy(contactA.node, contactB.node)
        }
        // Playership hitting the enemy2 ship ++++
        if (contactA.categoryBitMask == CBitmask.player_Ship && contactB.categoryBitMask == CBitmask.enemy_ShipTwo) ||
           (contactB.categoryBitMask == CBitmask.player_Ship && contactA.categoryBitMask == CBitmask.enemy_ShipTwo) {
            handleCollisionPlayerShipHitWithEnemyTwo(contactA.node, contactB.node)
        }

        // Player's fire hitting BossOne
        if (contactA.categoryBitMask == CBitmask.player_Fire && contactB.categoryBitMask == CBitmask.bossOne) ||
           (contactB.categoryBitMask == CBitmask.player_Fire && contactA.categoryBitMask == CBitmask.bossOne) {/*
            let fireNode = (contactA.categoryBitMask == CBitmask.player_Fire) ? contactA.node : contactB.node
            let bossOneNode = (contactA.categoryBitMask == CBitmask.bossOne) ? contactA.node : contactB.node
            handleCollisionPlayerFireWithBossOne(fireNode, bossOneNode)*/
            handleCollisionPlayerFireWithBossOne(contactA.node, contactB.node)
        }
        // ******  Player's fire hitting BossOnefire
        if (contactA.categoryBitMask == CBitmask.player_Fire && contactB.categoryBitMask == CBitmask.bossOneFire) ||
           (contactB.categoryBitMask == CBitmask.player_Fire && contactA.categoryBitMask == CBitmask.bossOneFire) {
            let fireNode = (contactA.categoryBitMask == CBitmask.player_Fire) ? contactA.node : contactB.node
            let bossOnefireNode = (contactA.categoryBitMask == CBitmask.bossOneFire) ? contactA.node : contactB.node
            handleCollisionPlayerFireWithBossOnefire(fireNode, bossOnefireNode)
            //handleCollisionPlayerFireWithBossOne(contactA.node, contactB.node)
        }

        // Player's fire hitting BossTwo
        if (contactA.categoryBitMask == CBitmask.player_Fire && contactB.categoryBitMask == CBitmask.bossTwo) ||
           (contactB.categoryBitMask == CBitmask.player_Fire && contactA.categoryBitMask == CBitmask.bossTwo) {
            let fireNode = (contactA.categoryBitMask == CBitmask.player_Fire) ? contactA.node : contactB.node
            let bossTwoNode = (contactA.categoryBitMask == CBitmask.bossTwo) ? contactA.node : contactB.node
            handleCollisionPlayerFireWithBossTwo(fireNode, bossTwoNode)
            //handleCollisionPlayerFireWithBossTwo(contactA.node, contactB.node)
        }
        // Player ship hitting BossOne's fire
        if (contactA.categoryBitMask == CBitmask.player_Ship && contactB.categoryBitMask == CBitmask.bossOneFire) ||
           (contactB.categoryBitMask == CBitmask.player_Ship && contactA.categoryBitMask == CBitmask.bossOneFire) {
            handleCollisionPlayerWithBossOneFire(contactA.node, contactB.node)
        }

        // Player hitting BossTwo's fire
        if (contactA.categoryBitMask == CBitmask.player_Ship && contactB.categoryBitMask == CBitmask.bossTwoFire) ||
           (contactB.categoryBitMask == CBitmask.player_Ship && contactA.categoryBitMask == CBitmask.bossTwoFire) {
            handleCollisionPlayerWithBossTwoFire(contactA.node, contactB.node)
        }
        // BossOne hitting the playership
        if (contactA.categoryBitMask == CBitmask.bossOne && contactB.categoryBitMask == CBitmask.player_Ship) ||
            (contactB.categoryBitMask == CBitmask.bossOne && contactA.categoryBitMask == CBitmask.player_Ship) {
            let bossOneNode = (contactA.categoryBitMask == CBitmask.bossOne) ? contactA.node : contactB.node
            let playerNode = (contactA.categoryBitMask == CBitmask.player_Ship) ? contactA.node : contactB.node
            handleCollisionBossOneWithPlayerShip(bossOneNode, playerNode)
        }
        // BossTwo hitting the playership
        if (contactA.categoryBitMask == CBitmask.bossTwo && contactB.categoryBitMask == CBitmask.player_Ship) ||
            (contactB.categoryBitMask == CBitmask.bossTwo && contactA.categoryBitMask == CBitmask.player_Ship) {
            let bossTwoNode = (contactA.categoryBitMask == CBitmask.bossTwo) ? contactA.node : contactB.node
            let playerNode = (contactA.categoryBitMask == CBitmask.player_Ship) ? contactA.node : contactB.node
            handleCollisionBossTwoWithPlayerShip(bossTwoNode, playerNode: playerNode)
        }
    }
    func LivesPlayer(){
        
        let fadeSequence = SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)])
        let repeatFade = SKAction.repeat(fadeSequence, count: 8)
        let delayAction = SKAction.wait(forDuration: 1.0)
        let resetRotation = SKAction.rotate(toAngle: defaultPlayerRotation, duration: 0.5)
        let fullSequence = SKAction.sequence([repeatFade, delayAction, resetRotation])
        player.run(fullSequence)
        
        if let live1 = childNode(withName: "live1"){
            //print(live1)
            live1.removeFromParent()
            particleEffect()
            Live_Array.remove(at: 1)
        } else if let live2 = childNode(withName: "live2"){
            //print(live2)
            live2.removeFromParent()
            particleEffect()
            Live_Array.remove(at: 1)
        } else if let live3 = childNode(withName: "live3"){
            //print(live3)
            live3.removeFromParent()
            particleEffect()
            Live_Array.remove(at: 1)
        }else if let live4 = childNode(withName: "live4"){
            //print(live4)
            live4.removeFromParent()
            particleEffect()
            Live_Array.remove(at: 1)
        }else if let live5 = childNode(withName: "live5"){
            //print(live5)
            live5.removeFromParent()
            player.removeFromParent()
            particleEffect()
            BossOneFireTimer.invalidate()
            BossTwoFireTimer.invalidate()
            enemyTimer.invalidate()
            gameOverFunc()
            //bossOneLives = 30
            //bossTwoLives = 30
        } else {
            if Live_Array.count <= 0 {
                print("Game Over")
            } else {
                print("Lives left: \(Live_Array.count)")
                print(Live_Array)
            }
        }
    }
    func SpawnExplosion(spawnPosition: CGPoint){
        let explo = SKEmitterNode(fileNamed: "MyParticle")
        explo?.position = spawnPosition
        explo?.zPosition = 3
        explo?.setScale(3)
        self.addChild(explo!)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.35)
        let FadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        explo?.run(SKAction.sequence([scaleIn,FadeOut,delete]))
    }
    func SpawnExplosionBullet(spawnPosition: CGPoint){
        let explo = SKEmitterNode(fileNamed: "BulletExpos")
        explo?.position = spawnPosition
        explo?.zPosition = 3
        explo?.setScale(3)
        self.addChild(explo!)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.45)
        let FadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        explo?.run(SKAction.sequence([scaleIn,FadeOut,delete]))
    }
    func addFireThunderEffect(to node: SKNode, yPosition: CGFloat) {
        if let fireThunderPath = Bundle.main.path(forResource: "Thunder", ofType: "sks"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: fireThunderPath)) {
            
            do {
                let fireThruster = try NSKeyedUnarchiver.unarchivedObject(ofClass: SKEmitterNode.self, from: data) as SKEmitterNode?
                fireThruster?.xScale = 0.5
                fireThruster?.yScale = 0.5
                fireThruster?.particleRotation = .pi
                let fireThrusterEffectNode = SKEffectNode()
                if let fireThruster = fireThruster {
                    fireThrusterEffectNode.addChild(fireThruster)
                }
                fireThrusterEffectNode.zPosition = 4
                fireThrusterEffectNode.position.y = yPosition
                node.addChild(fireThrusterEffectNode)
            } catch {
                print("Error unarchiving file: \(error)")
            }
        }
    }
    // Playership hitting the enemy ship
    func handleCollisionPlayerShipHitWithEnemy(_ playership: SKNode?, _ enemyNode: SKNode?){
        guard enemyNode?.name == "enemy" else { return }
        enemyNode?.removeFromParent()
        SpawnExplosion(spawnPosition: enemyNode?.position ?? CGPoint.zero)
        player.zRotation = defaultPlayerRotation
        LivesPlayer()
    }
    func handleCollisionPlayerShipHitWithEnemyTwo(_ playership: SKNode?, _ enemyTwoNode: SKNode?){
        guard enemyTwoNode?.name == "enemyTwo" else { return }
        enemyTwoNode?.removeFromParent()
        SpawnExplosion(spawnPosition: enemyTwoNode?.position ?? CGPoint.zero)
        player.zRotation = defaultPlayerRotation
        LivesPlayer()
    }
    func handleCollisionPlayerFireWithEnemyTwo(_ fireNode: SKNode?, _ enemyTwoNode: SKNode?){
        guard enemyTwoNode?.name == "enemyTwo" else { return }
        fireNode?.removeFromParent()
        enemyTwoNode?.removeFromParent()
        SpawnExplosion(spawnPosition: enemyTwoNode?.position ?? CGPoint.zero)
        UpdateScore(1)
    }
    func handleCollisionPlayerFireWithEnemy(_ fireNode: SKNode?, _ enemyNode: SKNode?) {
        guard enemyNode?.name == "enemy" else { return }
        fireNode?.removeFromParent()
        enemyNode?.removeFromParent()
        SpawnExplosion(spawnPosition: enemyNode?.position ?? CGPoint.zero)
        UpdateScore(1)
        
    }
    func handleCollisionPlayerFireWithBossOne(_ fireNode: SKNode?, _ bossOneNode: SKNode?) {
        guard let bossOne = bossOneNode, bossOne.name == "BossOne" else { return }
        //guard bossOneNode?.name == "BossOne" else {return}
                
        if bossOneLives <= 0 {
            bossOneNode?.removeFromParent()
            bossOneHealthBar?.removeFromParent()
            SpawnExplosion(spawnPosition: bossOneNode?.position ?? CGPoint.zero)
            //enemyTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
            enemyActive = true
            BossOneFireTimer.invalidate()
            bossHealthLabel.isHidden = true
            bossOneHealthBar?.isHidden = true
            StatusCount += 20
            //SpeedOpposite -= 0.25
            bossOneLives = 30 + StatusCount
            UpdateScore(10)
            updateHealthBar()
            BossOneActive = false
            SpeedOpposite = 2.0
            startNewLevel()
            //statusOfBossOne = 0
            playMusic("gameMain.mp3", isBossMusic: false)
            
            if statusOfBossOne >= 2 {
                let list2 = [1 , 2]
                statusOfBossOne = list2[Int.random(in: 0..<list2.count)]
            } else {
                statusOfBossOne += 1
            }
            
        } else if (bossOneLives <= (10 + StatusCount)) && (bossOneLives > 0) {
            SpawnExplosion(spawnPosition: bossOneNode?.position ?? CGPoint.zero)
            fireNode?.removeFromParent()
            bossOneLives -= 1
            updateHealthBar()
            SpeedOpposite -= 0.5
        } else {
            SpawnExplosion(spawnPosition: bossOneNode?.position ?? CGPoint.zero)
            fireNode?.removeFromParent()
            bossOneLives -= 1
            updateHealthBar()
            //let healthRatio = CGFloat(bossOneLives) / 30.0
            //bossOneHealthBar.size.width = 100 * healthRatio
            player.zRotation = defaultPlayerRotation
        }
    }
    //***** BossOneFire The bullet number 2
    func handleCollisionPlayerFireWithBossOnefire(_ fireNode: SKNode?, _ bossOnefireNode: SKNode?) {
        //bossOnefireNode?.removeFromParent()
        //fireNode?.removeFromParent()
        switch BossOneFire_Type{
        case 2:
            print("bullet active 2")
            fireNode?.removeFromParent()
            BossOneFire_Type2_Live -= 1
            SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
            if BossOneFire_Type2_Live < 0 {
                bossOnefireNode?.removeFromParent()
                SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
                BossOneFire_Type2_Live = 2
            }
        case 4:
            print("bullet active 4")
            fireNode?.removeFromParent()
            BossOneFire_Type4_Live -= 1
            SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
            if BossOneFire_Type4_Live < 0 {
                bossOnefireNode?.removeFromParent()
                SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
                BossOneFire_Type4_Live = 4
            }
        default:
            bossOnefireNode?.removeFromParent()
            fireNode?.removeFromParent()
            SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
        }
        /*
        if BossOneFire_Type == 2 {
            print("bullet active 2")
            fireNode?.removeFromParent()
            BossOneFire_Type2_Live -= 1
            SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
            if BossOneFire_Type2_Live < 0 {
                bossOnefireNode?.removeFromParent()
                SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
                BossOneFire_Type2_Live = 2
            }
        } else if BossOneFire_Type == 4 {
            print("bullet active 4")
            fireNode?.removeFromParent()
            BossOneFire_Type4_Live -= 1
            SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
            if BossOneFire_Type4_Live < 0 {
                bossOnefireNode?.removeFromParent()
                SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
                BossOneFire_Type4_Live = 4
            }
        } else {
            bossOnefireNode?.removeFromParent()
            fireNode?.removeFromParent()
            SpawnExplosionBullet(spawnPosition: bossOnefireNode?.position ??  CGPoint.zero)
            //SpawnExplosion(spawnPosition: fireNode?.position ??  CGPoint.zero)
        }*/
    }
    func handleCollisionPlayerFireWithBossTwo(_ fireNode: SKNode?, _ bossTwoNode: SKNode?) {

        if bossTwoLives <= 0 {
            bossTwoNode?.removeFromParent()
            bossTwoHealthBar?.removeFromParent()

            SpawnExplosion(spawnPosition: bossTwoNode?.position ?? CGPoint.zero)
            //enemyTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
            enemyActive = true
            BossTwoFireTimer.invalidate()
            bossHealthLabel.isHidden = true
            bossTwoHealthBar?.isHidden = true
            StatusCount += 10
            SpeedOpposite -= 0.25
            bossTwoLives = 30 + StatusCount
            UpdateScore(10)
            updateHealthBar()
            BossTwoActive = false
            SpeedOpposite = 1.0
            startNewLevel()
        } else {
            SpawnExplosion(spawnPosition: bossTwoNode?.position ?? CGPoint.zero)
            fireNode?.removeFromParent()
            bossTwoLives -= 1
            updateHealthBar()
            //let healthRatio = CGFloat(bossTwoLives) / 10.0
            //bossTwoHealthBar.size.width = 100 * healthRatio
            player.zRotation = defaultPlayerRotation
        }
    }
    func particleEffect(){
        let explo1 = SKEmitterNode(fileNamed: "Testing ")
        explo1?.position = player.position
        explo1?.zPosition = 5
        addChild(explo1!)
        let scaleIn = SKAction.scale(to: 1, duration: 0.3)
        let FadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        explo1?.run(SKAction.sequence([scaleIn,FadeOut,delete]))
    }
    func handleCollisionPlayerWithBossOneFire(_ playerNode: SKNode?, _ bossOneFireNode: SKNode?) {
        guard bossOneFireNode?.name == "bossOneFire" else { return }
        
        switch BossOneFire_Type{
        case 2:
            bossOneFireNode?.removeFromParent()
            if Live_Array.count < 2 {
                LivesPlayer()
            } else {
                LivesPlayer()
                LivesPlayer()
            }
        case 4:
            bossOneFireNode?.removeFromParent()
            BossOneFire_Type4_Live -= 1
            for _ in 1...(4 - min(Live_Array.count, 3)) {
                LivesPlayer()
            }
        default:
            bossOneFireNode?.removeFromParent()
            LivesPlayer()
        }/*
        if BossOneFire_Type == 2 {
            bossOneFireNode?.removeFromParent()
            if Live_Array.count < 2 {
                LivesPlayer()
            } else {
                LivesPlayer()
                LivesPlayer()
            }

        } else if BossOneFire_Type == 4 {
            bossOneFireNode?.removeFromParent()
            BossOneFire_Type4_Live -= 1
            for _ in 1...(4 - min(Live_Array.count, 3)) {
                LivesPlayer()
            }
        } else {
            bossOneFireNode?.removeFromParent()
            LivesPlayer()
        }*/
    }
    func handleCollisionPlayerWithBossTwoFire(_ playerNode: SKNode?, _ bossTwoFireNode: SKNode?) {
        guard bossTwoFireNode?.name == "BossTwoFire" else{ return }
        bossTwoFireNode?.removeFromParent()
        LivesPlayer()
    }
    func handleCollisionBossOneWithPlayerShip(_ bossOneNode: SKNode?, _ playerNode: SKNode?) {
        guard bossOneNode?.name == "BossOne" else{ return }
        playerNode?.zRotation = defaultPlayerRotation
        player.zRotation = defaultPlayerRotation
        LivesPlayer()
    }
    func handleCollisionBossTwoWithPlayerShip(_ bossTwoNode: SKNode?, playerNode: SKNode?){
        guard bossTwoNode?.name == "BossTwo" else{ return }
        LivesPlayer()
    }
    func addLive(lives: Int){
        for i in 1...lives{
            let live = SKSpriteNode(imageNamed: "Player3.001")
            live.setScale(0.5)
            live.size = CGSize(width: 30, height: 60)
            live.position = CGPoint(x: size.width - live.size.width/2 - 10 - CGFloat(i) * (live.size.width + 10),
                                    y: size.height - live.size.height - 30)
            live.zPosition = 10
            live.name = "live\(i)"
            Live_Array.append(live)
            
            addChild(live)
            
        }
    }
    func makePlayer(playerCh: Int){
        var ShipName = ""
        switch playerCh{
        case 1:
            ShipName = "Player.001"
        case 2:
            ShipName = "Player2.001"
        case 3:
            ShipName = "Boss"
        default:
            ShipName = "Player3.001"
        }
        player = .init(imageNamed: ShipName)
        player.name = "Player"
        player.position = CGPoint(x: size.width/2, y: 0 - size.height)
        player.zPosition = 10
        player.size = CGSize(width: 200, height: 200)
        originalPlayerRotation = player.zRotation
        
        let hitboxSize = CGSize(width: player.size.width * 0.5, height: player.size.height * 0.5)
        player.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = CBitmask.player_Ship
        player.physicsBody?.contactTestBitMask = CBitmask.enemy_Ship | CBitmask.bossOne
        //player.physicsBody?.collisionBitMask = CBitmask.enemy_Ship | CBitmask.bossOne
        player.physicsBody?.collisionBitMask = CBitmask.None
        addChild(player)
    }
    func makeBossOne(){
        
        BossOneActive = true
        //startNewLevel()
        bossyOne = .init(imageNamed: "Boss")
        //bossyOne = SKSpriteNode(imageNamed: "Boss")
        bossyOne.position = CGPoint(x: size.width / 2, y: size.height + bossyOne.size.height)
        //bossyOne.position = CGPoint(x: size.width / 2, y: randomAppearY)
        bossyOne.name = "BossOne"
        bossyOne.zPosition = 10
        bossyOne.setScale(1.6)
        bossyOne.alpha = 1
        bossyOne.size = CGSize(width: 300, height: 300)
        bossyOne.zRotation = .pi
        let sizeReduced = CGSize(width: bossyOne.size.width/2, height: bossyOne.size.height/2)
        
        bossyOne.physicsBody = SKPhysicsBody(rectangleOf: sizeReduced)
        bossyOne.physicsBody?.affectedByGravity = false
        bossyOne.physicsBody?.categoryBitMask = CBitmask.bossOne
        bossyOne.physicsBody?.contactTestBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        //bossyOne.physicsBody?.collisionBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        bossyOne.physicsBody?.collisionBitMask = CBitmask.None

        let move1 = SKAction.moveTo(y: size.height / 1.2, duration: 2)
        let move2 = SKAction.moveTo(x: size.width - bossyOne.size.width / 2, duration: 2)
        let move3 = SKAction.moveTo(x: 0 + bossyOne.size.width / 2, duration: 2)
        let move4 = SKAction.moveTo(x: CGFloat.random(in: (size.width/3.5) ... (size.width/1.5)), duration: 1.5)
        let move5 = SKAction.fadeOut(withDuration: 0.4)
        let move6 = SKAction.fadeIn(withDuration: 0.4)
        let move7 = SKAction.moveTo(y: 0 + bossyOne.size.height / 2, duration: 2)
        let move8 = SKAction.moveTo(y: size.height / 1.2, duration: 1)
        let action = SKAction.repeat(SKAction.sequence([move5, move6]), count: 0)
        
        let repearForever = SKAction.repeatForever (SKAction.sequence([move2,move3,move4,action,move7,move8,move3,move4,action,move7,move8]))
        let sequence = SKAction.sequence([move1,repearForever])
         bossyOne.run(sequence)
        
        addChild(bossyOne)
        
        // Health
        bossOneHealthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        bossOneHealthBar?.position = CGPoint(x: size.width * 0.5, y: bossHealthLabel.position.y - bossHealthLabel.frame.size.height - 30)
        bossOneHealthBar?.zPosition = 1
        bossOneHealthBar?.isHidden = true
        addChild(bossOneHealthBar!)
        //bossOneHealthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        //bossOneHealthBar.position = CGPoint(x: size.width * 0.75, y: bossyOne.size.height / 2 + 20)
        //bossOneHealthBar.zPosition = 1
        //bossyOne.addChild(bossOneHealthBar)
        //addChild(bossOneHealthBar)
    }
    @objc func bossOneFireFunc(){
        
        updateGameState()
        let randomAngle = CGFloat.random(in: 150...210) * (CGFloat.pi / 180)
        //let randomAngle = CGFloat.random(in: -45...45) * (CGFloat.pi / 180)
        bossOneFire = .init(imageNamed: "buttel.001")
        bossOneFire.size = CGSize(width: 80, height: 80)
        bossOneFire.position = bossyOne.position
        bossOneFire.name = "bossOneFire"
        //bossOneFire.zRotation = .pi + bossyOne.zRotation
        bossOneFire.zPosition = 5
        //bossOneFire.setScale(1.5)
        bossOneFire.physicsBody = SKPhysicsBody(rectangleOf: bossOneFire.size)
        bossOneFire.physicsBody?.affectedByGravity = false
        bossOneFire.physicsBody?.categoryBitMask = CBitmask.bossOneFire
        bossOneFire.physicsBody?.contactTestBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        bossOneFire.physicsBody?.collisionBitMask = CBitmask.player_Ship
        let rotationAction = SKAction.rotate(toAngle: randomAngle, duration: 0.5)
        bossyOne.run(rotationAction)
        //bossyOne.zRotation = randomAngle
        bossOneFire.zRotation = bossyOne.zRotation
        
        addFireThunderEffect(to: bossOneFire, yPosition: -40)
        
        let fireRotationAction = SKAction.rotate(toAngle: randomAngle, duration: 0.2)
        let bulletSpeed: CGFloat = 4000
        let moveAction = SKAction.run {
            let dx = bulletSpeed * cos(randomAngle + .pi / 2)
            let dy = bulletSpeed * sin(randomAngle + .pi / 2)
            let move1 = SKAction.moveTo(y: self.size.height/1.1, duration: 2)
            let move2 = SKAction.moveTo(x: CGFloat.random(in: self.size.width/2.5...self.size.width/1.5), duration: 2)
            let rotationS = SKAction.rotate(byAngle: .pi*4, duration: 2)
            let groupS = SKAction.group([move1, move2, rotationS])
            
            let wait = SKAction.wait(forDuration: 0.2)
            let moveByAction = SKAction.moveBy(x: dx, y: dy, duration: 2)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([groupS, wait,  moveByAction, removeAction])
            self.bossOneFire.run(sequence)
        }

        let fireSequence = SKAction.sequence([fireRotationAction, moveAction])
        bossOneFire.run(fireSequence)
        addChild(bossOneFire)
    }
    //boss 2
    func makeBossTwo(){
        //let randomAppearY = CGFloat.random(in: self.size.width/1.75...self.size.width/1.25)
        BossTwoActive = true
        BossyTwo = SKSpriteNode(imageNamed: "Boss")
        BossyTwo.name = "BossTwo"
        BossyTwo.zPosition = 15
        BossyTwo.setScale(1.6)
        BossyTwo.color = SKColor.red
        BossyTwo.colorBlendFactor = 1.0
        BossyTwo.size = CGSize(width: 300, height: 300)
        BossyTwo.zRotation = .pi
        
        BossyTwo.physicsBody = SKPhysicsBody(rectangleOf: BossyTwo.size)
        BossyTwo.physicsBody?.affectedByGravity = false
        BossyTwo.physicsBody?.categoryBitMask = CBitmask.bossTwo
        BossyTwo.physicsBody?.contactTestBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        BossyTwo.physicsBody?.collisionBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        //let moveAction = SKAction.move(to: endPosition, duration: 10)
        //BossyTwo.position = CGPoint(x: randomAppearY, y: size.height / 1.2)
        BossyTwo.position = CGPoint(x: size.width, y: size.height / 1.2)
        let moveUp = SKAction.moveTo(x: size.width / 6, duration: 3)
        let moveDown = SKAction.moveTo(x: size.width, duration: 3)
        //let sequence = SKAction.sequence([actionForBossTwo])
        let repeatAction = SKAction.repeatForever(SKAction.sequence([moveUp, moveDown]))
        BossyTwo.run(repeatAction)
        addChild(BossyTwo)
        
        // Health
        bossTwoHealthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        bossTwoHealthBar?.position = CGPoint(x: size.width * 0.5, y: bossHealthLabel.position.y - bossHealthLabel.frame.size.height - 10)
        bossTwoHealthBar?.zPosition = 1
        bossTwoHealthBar?.isHidden = true
        addChild(bossTwoHealthBar!)
    }
    @objc func bossTwoFireFunc() {
        let RandomAngle = CGFloat.random(in: 135...225) * CGFloat.pi / 180
        BossyTwo.zRotation = RandomAngle
        BossTwoFire = SKSpriteNode(imageNamed: "buttel.001")
        BossTwoFire.position = BossyTwo.position
        BossTwoFire.zRotation = BossyTwo.zRotation
        BossTwoFire.name = "BossTwoFire"
        BossTwoFire.zPosition = 3
        BossTwoFire.color = SKColor.red
        BossTwoFire.size = CGSize(width: 200, height: 200)
        BossTwoFire.physicsBody = SKPhysicsBody(rectangleOf: BossTwoFire.size)
        BossTwoFire.physicsBody?.affectedByGravity = false
        BossTwoFire.physicsBody?.categoryBitMask = CBitmask.bossTwoFire
        BossTwoFire.physicsBody?.contactTestBitMask = CBitmask.player_Ship
        BossTwoFire.physicsBody?.collisionBitMask = CBitmask.player_Ship
        
        addFireThunderEffect(to: BossTwoFire, yPosition: -40)
        let bulletSpeed: CGFloat = 1400
        let Dx = bulletSpeed * cos(BossTwoFire.zRotation + .pi/2)
        let Dy = bulletSpeed * sin(BossTwoFire.zRotation + .pi/2)
        let moveAction = SKAction.moveBy(x: Dx, y: Dy, duration: 1)
        let deleteAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, deleteAction])
        
        BossTwoFire.run(sequence)
        addChild(BossTwoFire)
    }
    
    @objc func makeEnemys(){
        let randomNumber = GKRandomDistribution(lowestValue: 100, highestValue: 700)
        
        enemy = .init(imageNamed: "ship")
        enemy.position = CGPoint(x: randomNumber.nextInt(), y: Int(size.height) + 100)
        enemy.name = "enemy"
        enemy.zPosition = 5
        enemy.setScale(0.7)
        enemy.zRotation = .pi
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = CBitmask.enemy_Ship
        enemy.physicsBody?.contactTestBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        enemy.physicsBody?.collisionBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        addChild(enemy)
        
        let explo = SKEmitterNode(fileNamed: "Testing ")
        explo?.position = enemy.position
        explo?.zPosition = 3
        explo?.setScale(3)
        self.addChild(explo!)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 5)
        //let combine = SKAction.group([ex])
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction,deleteAction])
        enemy.run(combine)
    }
    func spawnEnemy(){
        let randomXstart = random(min: 0, max: UIScreen.main.bounds.width*2)
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXstart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        enemyTwo = .init(imageNamed: "ship")
        enemyTwo.name = "enemyTwo"
        enemyTwo.zPosition = 5
        enemyTwo.position = startPoint
        enemyTwo.setScale(0.7)
        //enemyTwo.zRotation = .pi
        enemyTwo.physicsBody = SKPhysicsBody(rectangleOf: enemyTwo.size)
        enemyTwo.physicsBody?.affectedByGravity = false
        enemyTwo.physicsBody?.categoryBitMask = CBitmask.enemy_ShipTwo
        enemyTwo.physicsBody?.contactTestBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        enemyTwo.physicsBody?.collisionBitMask = CBitmask.player_Ship | CBitmask.player_Fire
        self.addChild(enemyTwo)
        
        addFireThunderEffect(to: enemyTwo, yPosition: -40)
        
        let move = SKAction.move(to: endPoint, duration: 2)
        let delete = SKAction.removeFromParent()
        let Sequence = SKAction.sequence([move, delete])
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let ARotation = atan2(dy, dx)
        enemyTwo.zRotation = ARotation - .pi/2
        if currentGameState == gameState.inGame{
            enemyTwo.run(Sequence)
            enemyTwo.zRotation = ARotation - .pi/2
        }
    }
    func updateHealthBar() {
        let healthRatio1 = CGFloat(bossOneLives) / 30.0
        bossOneHealthBar?.size.width = 200 * healthRatio1
        let healthRatio2 = CGFloat(bossTwoLives) / 30.0
        bossTwoHealthBar?.size.width = 200 * healthRatio2
    }
    func UpdateScore(_  Num: Int){
        score += Num
        scoreLabel.text = "Score: \(score)"
        
        let bossOneSpawnProbability = 0.4
        let bossTwoSpawnProbability = 0.4
        let EnemyProbability = 0.1
        
        let randomValue = Double.random(in: 0...1)

        if !BossOneActive && !BossTwoActive {
            
            if score >= 5 && randomValue < bossOneSpawnProbability {
                if SpawnCount >= 0.4 {
                    SpawnCount = 0.4
                } else {
                    SpawnCount += 0.05
                }
                //SpawnCount += 0.05
                spawnBossOne()
                playMusic("evil-boss.mp3", isBossMusic: true)
            } else if score >= 10 && randomValue < (bossTwoSpawnProbability + SpawnCount) {
                spawnBossTwo()
                playMusic("evil-boss.mp3", isBossMusic: true)
            }
        }
        if score >= 20 && randomValue < EnemyProbability{
            enemyTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
        }
        //BossOne
        /*
        if score == 10 || score == 15 || score == 25 || score == 35 || score == 45 {
            makeBossOne()
            enemyTimer.invalidate()
            BossOneFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            //StatusCount += 1
            BossOneActive = true
            self.removeAction(forKey: "spawningEnemies")
            bossHealthLabel.isHidden = false
            bossOneHealthBar?.isHidden = false
        }
        else if score == 200 || score == 400 || score == 650{
            makeBossTwo()
            enemyTimer.invalidate()
            BossTwoFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossTwoFireFunc), userInfo: nil, repeats: true)
            //StatusCount += 1
            self.removeAction(forKey: "spawningEnemies")
            bossHealthLabel.isHidden = false
            bossTwoHealthBar?.isHidden = false
        }
        else if score == 300 || score == 450 || score == 750{
            makeBossOne()
            makeBossTwo()
            enemyTimer.invalidate()
            self.removeAction(forKey: "spawningEnemies")
            BossOneFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            BossTwoFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossTwoFireFunc), userInfo: nil, repeats: true)
            //StatusCount += 1
            bossHealthLabel.isHidden = false
            bossOneHealthBar?.isHidden = false
            bossTwoHealthBar?.isHidden = false
        }*/
    }
    func spawnBossOne() {
        makeBossOne()
        enemyTimer.invalidate()
        BossOneFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
        BossOneActive = true
        self.removeAction(forKey: "spawningEnemies")
        bossHealthLabel.isHidden = false
        bossOneHealthBar?.isHidden = false
    }
    func spawnBossTwo() {
        makeBossTwo()
        enemyTimer.invalidate()
        BossTwoFireTimer = Timer.scheduledTimer(timeInterval: SpeedOpposite, target: self, selector: #selector(bossTwoFireFunc), userInfo: nil, repeats: true)
        BossTwoActive = true
        self.removeAction(forKey: "spawningEnemies")
        bossHealthLabel.isHidden = false
        bossTwoHealthBar?.isHidden = false
    }
    
    func updateGameState(){/*
        if statusOfBossOne == 1{
            bossOneFire.texture = SKTexture(imageNamed: "Number2.001")
            bossyOne.removeChildren(in: [bossyOne.childNode(withName: "TheNumber")].compactMap { $0 })
            activateTheNumberSpecial(imageName: "Number2.001")
            BossOneFire_Type = 2
            print("statusOfBossOne == 1")
            //bulletDamage = 20
            //Damage.text = "Damage \(bulletDamage)"
        }
        else if statusOfBossOne == 2{
            bossOneFire.texture = SKTexture(imageNamed: "Number4.001")
            bossyOne.removeChildren(in: [bossyOne.childNode(withName: "TheNumber")].compactMap { $0 })
            activateTheNumberSpecial(imageName: "Number4.001")
            BossOneFire_Type = 4
            //bulletDamage = 30
        } else {
            BossOneFire_Type = 1
            bossOneFire.texture = SKTexture(imageNamed: "buttel.001")
            bossyOne.childNode(withName: "TheNumber")?.removeFromParent()
            //bulletDamage = 1
            //Damage.text = "Damage \(bulletDamage)"
        }*/
        switch statusOfBossOne {
        case 1:
            bossOneFire.texture = SKTexture(imageNamed: "Number2.001")
            bossyOne.removeChildren(in: [bossyOne.childNode(withName: "TheNumber")].compactMap { $0 })
            activateTheNumberSpecial(imageName: "Number2.001")
            BossOneFire_Type = 2
        case 2:
            bossOneFire.texture = SKTexture(imageNamed: "Number4.001")
            bossyOne.removeChildren(in: [bossyOne.childNode(withName: "TheNumber")].compactMap { $0 })
            activateTheNumberSpecial(imageName: "Number4.001")
            BossOneFire_Type = 4
        default:
            BossOneFire_Type = 1
            bossOneFire.texture = SKTexture(imageNamed: "buttel.001")
            bossyOne.childNode(withName: "TheNumber")?.removeFromParent()
        }
    }
    func activateTheNumberSpecial(imageName: String) {
        if bossyOne.childNode(withName: "TheNumber") == nil {
            //let TheNumber = SKSpriteNode(imageNamed: "Number2.001")
            let TheNumber = SKSpriteNode(imageNamed: imageName)
            TheNumber.name = "TheNumber"
            TheNumber.size = CGSize(width: 100, height: 100)
            TheNumber.zPosition = 6
            TheNumber.position = CGPoint(x: 6, y: bossyOne.size.height / 3 + TheNumber.size.height / 8)
            TheNumber.zRotation = .pi
            bossyOne.addChild(TheNumber)
            print("Image: \(imageName)")
        }
    }
    func startShooting(){
        isShooting = true
        //print("startShooting called")
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run {
                [weak self] in self?.fireBullet()
            }, SKAction.wait(forDuration: self.fireRate)])), withKey: "shooting")
    }
    func stopShooting(){
        isShooting = false
        removeAction(forKey: "shooting")
        
    }
    private func fireBullet() {
        //let bullet = BulletManagement.shared.spawnBullet(level: level)
        let bullet = SKSpriteNode(imageNamed: "32.001")
        bullet.position = player.position
        bullet.zPosition = 3
        bullet.size = CGSize(width: 100, height: 100)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = CBitmask.player_Fire
        bullet.physicsBody?.contactTestBitMask = CBitmask.enemy_Ship | CBitmask.bossTwo | CBitmask.bossOne | CBitmask.bossOneFire | CBitmask.bossTwoFire
        //bullet.physicsBody?.collisionBitMask = CBitmask.bossOne | CBitmask.bossTwo | CBitmask.bossOneFire | CBitmask.bossTwoFire
        bullet.physicsBody?.collisionBitMask = CBitmask.None
        bullet.physicsBody?.affectedByGravity = false
        
        let moveAction = SKAction.moveTo(y: 1400, duration: 1)
        let deleteAction = SKAction.removeFromParent()
        
        let bulletSound = SKAction.playSoundFileNamed("blaster-2-81267.mp3", waitForCompletion: false)
        let volume = SKAction.changeVolume(by: 0.03, duration: 0.1)
        let groupSound = SKAction.group([bulletSound, volume])
        bullet.run(groupSound)
        //bullet.run(SKAction.sequence([bulletSound,moveAction, deleteAction]))
        bullet.run(SKAction.sequence([moveAction, deleteAction]))
        self.addChild(bullet)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        for touch in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDraggedX = pointOfTouch.x - previousPointOfTouch.x
            let amountDraggedY = pointOfTouch.y - previousPointOfTouch.y
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDraggedX
                player.position.y += amountDraggedY
            }
            
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width/2{
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2{
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }
            if player.position.y > CGRectGetMaxY(gameArea) - player.size.height / 2 {
                player.position.y = CGRectGetMaxY(gameArea) - player.size.height / 2
            }
            if player.position.y < CGRectGetMinY(gameArea) + player.size.height / 2 {
                player.position.y = CGRectGetMinY(gameArea) + player.size.height / 2
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let now = Date().timeIntervalSince1970
        if now - lastTouchTime < 0.3 { // Threshold for rapid tapping
            tapCount += 1
        } else {
            tapCount = 1
        }
        // If rapid taps exceed a certain number, consider it as spam
        if tapCount >= 3 { // Threshold for considering as spam
            fireRate = max(fireRate - 0.1, 0.05) // Increase fire rate
        } else {
            fireRate = 0.3 // Reset to default fire rate
        }

        lastTouchTime = now
        
        if currentGameState == gameState.preGame {
            startGame()
            //spawnEnemy()
        } //else if currentGameState == gameState.inGame{
            //startShooting()
            //spawnEnemy()
        //}
        else if currentGameState == gameState.inGame{
            tapCount = 0
            fireRate = 0.3
            
            startShooting()
            //spawnEnemy()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopShooting()
    }
    func resetGame(){
        //score = 0
        SpeedOpposite = 2.0
        bossOneLives = 30
        bossTwoLives = 30
        scoreLabel.text = "Score: \(score)"
        removeAllChildren()
        removeAllActions()
        Live_Array.removeAll()
        enemyTimer.invalidate()
        BossOneActive = false
        BossTwoActive = false
        BossOneFireTimer.invalidate()
        BossTwoFireTimer.invalidate()
    }
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    func changeScene(){
        let sceneToMoveTo = ScoreBoardScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        sceneToMoveTo.score = score
        let Transition = SKTransition.fade(withDuration: 0.3)
        self.view!.presentScene(sceneToMoveTo, transition: Transition)
    }
    func gameOverFunc(){
        currentGameState = gameState.afterGame
        updateHighScore(with: score)
        backgroundTimer.invalidate()
        resetGame()
        backgroundMusicPlayer?.stop()
        bossMusicPlayer?.stop()
        gameOver = true
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Enemy"){bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Bullet"){enemy, stop in
            enemy.removeAllActions()
        }
        /*
        let gameOverScene = ScoreBoardScene()
        gameOverScene.scaleMode = .aspectFill
        self.view?.presentScene(gameOverScene)*/
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene,changeSceneAction])
        self.run(changeSceneSequence)
    }
}

struct ContentView: View {
    //@ObservedObject var scene = Game_Scene(size: CGSize(width: 750, height: 1335))
    @ObservedObject var scene : Game_Scene
    @Binding var status : Int
    @Binding var ContentActive : Bool
    @State private var showingSettings = false
    //@StateObject var viewModel = GameViewModel()
    //@State private var shouldShowScoreboard = false
    var body: some View {
        HStack{
            ZStack{
                SpriteView(scene: scene, debugOptions: [.showsFPS, .showsNodeCount])
                    .ignoresSafeArea()
                VStack{
                    if !scene.gameOver {
                        pauseBotton
                            .padding(.top, 40)
                            .padding(.horizontal)
                            .position(CGPoint(x: UIScreen.main.bounds.width/1.1, y: UIScreen.main.bounds.height/(15)))
                    }
                }
                if showingSettings{
                    SettingsView(showingSettings: $showingSettings, status: $status)
                }/*
                if shouldShowScoreboard {
                    EndingScene1()
                }*/
            }
            .onChange(of: scene.gameOver){
                //scene.NUM += 1
                /*
                if scene.gameOver {
                    if scene.score >= 50 {
                        scene.gameOver = false
                        status = 5
                    } else {
                        scene.gameOver = false
                        status = 3
                    }
                    scene.gameOver = false
                    //shouldShowScoreboard = true
                }*/
            }
        }
    }
    private var pauseBotton: some View{
        Button(action: togglePause){
            Image(systemName: scene.isPaused ? "play.circle" : "pause.circle")
                .resizable()
                .frame(width: 40, height: 40)
                .padding()
                .background(Color.clear)
        }
        .accessibilityLabel(scene.isPaused ? "Resume Game" : "Pause Game")
        
    }
    private func togglePause(){
        if scene.isPaused {
            scene.resumeGame()
        } else {
            scene.pauseGame()
            showingSettings = true
        }
    }
}

#Preview {
    ContentView(scene: Game_Scene(size: CGSize(width: 750, height: 1335)),status: .constant(0), ContentActive: .constant(false))
}
