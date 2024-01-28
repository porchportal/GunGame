//
//  IceShared.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 23/12/2566 BE.
//

import SwiftUI
import SpriteKit
import GameplayKit

class Ice_Shard: SKSpriteNode{
    let shard_particle = SKEmitterNode(fileNamed: "IceShard")
    let shardFadeTime: Double = 0.1
    
    let shardRange: CGFloat = 600.0
    let shardSpeed: CGFloat = 600.0
    var shardDuration: CGFloat = 0.0
    
    var shardEndPoint = CGPoint()
    
    init(startPos: CGPoint, endPos: CGPoint){
        super.init(texture: SKTexture(), color: .white, size: CGSize(width: 0, height: 0))
        position = startPos
        
        let x = endPos.x - position.x
        let y = endPos.y - position.y
        
        let distance = sqrt(x * x + y * y)
        
        shardDuration = distance / shardSpeed
        shardEndPoint = endPos
        
        AddShardParticle()
        AddShardAction()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func AddShardParticle(){
        shard_particle?.targetNode = self
        shard_particle?.emissionAngle = CGFloat(-atan2(shardEndPoint.x - position.x, 
                                                       shardEndPoint.y - position.y) - .pi/2)
        addChild(shard_particle!)
    }
    func AddShardAction(){
        let shardMove = SKAction.move(to: shardEndPoint, duration: Double(shardFadeTime))
        let shardFade = SKAction.fadeOut(withDuration: shardFadeTime)
        let rand = Int.random(in: 1...3)
        let shardSound = SKAction.playSoundFileNamed("icespike\(rand)", waitForCompletion: false)
        
        run(SKAction.sequence([shardSound, shardMove, shardFade, .removeFromParent()]))
    }
}
class Testing1: SKScene {
    private var spinnyNode: SKShapeNode?

    var player: SKSpriteNode = SKSpriteNode()

    var shardParticle: SKEmitterNode = SKEmitterNode()

    var sceneCamera: SKCameraNode = SKCameraNode()

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.clear
        camera = sceneCamera

        player = SKSpriteNode(imageNamed: "Player3.001")
        player.size = CGSize(width: 100, height: 100)
        player.position = CGPoint(x: 50, y: 50)
        self.addChild(player)

        //shardParticle = SKEmitterNode(fileNamed: "IceShard")!
        //self.addChild(shardParticle)

        let w = (self.size.width + self.size.height) * 0.01
        self.spinnyNode = SKShapeNode(rectOf: CGSize(width: w, height: w), cornerRadius: w * 0.3)

        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 1), SKAction.removeFromParent()]))
        }
    }

    func touchDown(atPoint pos: CGPoint) {
        player.removeAllActions()

        let movementSpeed = 100.0 //200

        let x = pos.x - player.position.x
        let y = pos.y - player.position.y

        let distance = sqrt(x * x + y * y)

        player.run(SKAction.move(to: pos, duration: Double(distance) / movementSpeed))
        
        let angle = atan2(y, x)
            player.zRotation = angle - CGFloat(Double.pi / 2)
        
        if let n = self.spinnyNode?.copy() as? SKShapeNode {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    func rightDown1(atPoint pos: CGPoint) {
        let x = pos.x - player.position.x
        let y = pos.y - player.position.y

        // Calculate the angle and rotate the player
        let angle = atan2(y, x)
        player.zRotation = angle - CGFloat(Double.pi / 2)

        let iceShard = Ice_Shard(startPos: player.position, endPos: pos)
        addChild(iceShard)
    }
    func rightDown(atPoint pos: CGPoint) {
        let iceShard = Ice_Shard(startPos: player.position, endPos: pos)
        addChild(iceShard)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            self.touchDown(atPoint: touchLocation)
            self.rightDown(atPoint: touchLocation)
            self.rightDown1(atPoint: touchLocation)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Keep the camera centered on the player
        camera?.position.x = player.position.x
        camera?.position.y = player.position.y
    }
}

struct IceShared: View {
    var scene1 = Testing1()
    var body: some View {
        SpriteView(scene: setupScene())
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .edgesIgnoringSafeArea(.all)
    }
    func setupScene() -> SKScene {
        let scene = Testing1()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .aspectFill
        return scene
    }
}

#Preview {
    IceShared()
}

