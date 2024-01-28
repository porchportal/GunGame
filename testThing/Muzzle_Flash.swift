//
//  Muzzle_Flash.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 18/1/2567 BE.
//

import SwiftUI
import SpriteKit

class Muzzle_Flash: SKSpriteNode {
    private let muzzleFlashTexture = SKTexture(imageNamed: "spark")
    
    init(atPoint position: CGPoint) {
        super.init(texture: muzzleFlashTexture, color: .clear, size: muzzleFlashTexture.size())
        
        //self.position = position + CGPoint(x: size.width / 2, y: 0)

        isHidden = true
        zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flash() {
        let showMuzzleFlashAction = SKAction.run { [weak self] in
            self?.alpha = 0
            self?.isHidden = false
        }
        
        let hideMuzzleFlashAction = SKAction.run { [weak self] in
            self?.isHidden = true
        }
        let muzzleFlashFireAction = SKAction.sequence([
            showMuzzleFlashAction,
            SKAction.fadeAlpha(to: 1.0, duration: 0.05),
            SKAction.wait(forDuration: 0.05),
            SKAction.fadeOut(withDuration: 0.05),
            hideMuzzleFlashAction
        ])
        
        run(muzzleFlashFireAction)
    }
}
