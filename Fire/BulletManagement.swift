//
//  BulletManagement.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 18/1/2567 BE.
//

import SwiftUI
import SpriteKit

class BulletManagement {
    static let shared = BulletManagement()
    
    static let bulletAtlas = SKTextureAtlas(named: "32.001")
    
    static let sparkAtlas = SKTextureAtlas(named: "Spark")
    
    static let bulletTextureFrames: SKTexture = {
        let texture = bulletAtlas.textureNamed("buttel.001")
        print("Bullet texture size: \(texture.size())")
        texture.filteringMode = .nearest
        return texture
    }()
    
    static let sparkTextureFrames: SKTexture = {
        let texture = BulletManagement.sparkAtlas.textureNamed("Spark")
        texture.filteringMode = .nearest
        return texture
    }()
    
    func spawnBullet(level: Int) -> BulletFire {/*
        let textureName = level > 2 ? "Spark" : "32.001"
        let texture = SKTexture(imageNamed: textureName)
        texture.filteringMode = .nearest
        let bullet = BulletFire(texture: texture)
        bullet.damageMultiplier = level > 2 ? 1.2 : 1.0
        bullet.run(SKAction.scale(by: level > 2 ? 2 : 1, duration: 1.5))*/
        if level > 2 {
            print("Spawning spark bullet")
            return spawnSpark()
        } else {
            print("Spawning standard bullet")
            return spawnbullet()
        }
    }
    
    private func spawnbullet() -> BulletFire {
        let bullet = BulletFire(texture: BulletManagement.bulletTextureFrames)
        
        bullet.texture = BulletManagement.bulletTextureFrames
        //.size = BulletManagement.bulletTextureFrames.size()
        bullet.damageMultiplier = 1.0
        //bullet.setupPhysicsBody()
        bullet.run(SKAction.scale(by: 1, duration: 2.0))
        print("Standard bullet created with size: \(bullet.size)")
        return bullet
    }
    private func spawnSpark() -> BulletFire {
        let bullet = BulletFire(texture: BulletManagement.sparkTextureFrames)
        //bullet.setupAnimation(with: BulletManagement.sparkTextureFrames)
        bullet.texture = BulletManagement.sparkTextureFrames
        //bullet.size = BulletManagement.sparkTextureFrames.size()
        //bullet.setupPhysicsBody()
        bullet.damageMultiplier = 1.2
        bullet.run(SKAction.scale(by: 2, duration: 1.5))
        
        return bullet
    }
}
