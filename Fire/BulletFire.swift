//
//  BulletFire.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 18/1/2567 BE.
//

import SwiftUI
import SpriteKit

protocol Updatable: AnyObject {
    func update(deltaTime: TimeInterval)
}

class BulletFire: SKSpriteNode{

    var damageMultiplier: CGFloat = 1.0
    private let bulletSpeed: CGFloat = 1000.0
    
    init(texture: SKTexture) {
        //let bullet = SKSpriteNode(imageNamed: "32.001")
        //let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "Bullet"
        //setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: TimeInterval) {
        position.x += bulletSpeed * deltaTime
        
        guard let maxX = parent?.frame.maxX else { return }
                
        if position.x > maxX + size.width {
            removeFromParent()
        }
    }
    
    func fire(from position: CGPoint, direction: CGVector) {
        self.position = position
    }
    
    func setupAnimation(with frames: [SKTexture]) {
        if frames.isEmpty {
            print("Error: The texture array is empty. Animation cannot be created.")
            return
        }
        let animationAction = SKAction.animate(with: frames, timePerFrame: 0.1)
        run(SKAction.repeatForever(animationAction))
    }
}
