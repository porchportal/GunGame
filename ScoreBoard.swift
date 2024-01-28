//
//  ScoreBoard.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 22/1/2567 BE.
//

import SwiftUI
import SpriteKit

class ScoreBoardScene: SKScene {
    var score: Int = 0
    let scores = loadScore()
    let background = SKSpriteNode(imageNamed: "image")
    var delay : Float = 0.0
    override func didMove(to view: SKView) {
        var height = UIScreen.main.bounds.height
        scene?.size = CGSize(width: 750, height: 1335)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.setScale(1.3)
        background.zPosition = -1
        background.alpha = 0.6
        
        addChild(background)
        //scores.indices
        for index in scores.indices {
            let rank = "Rank \(index + 1) : \(scores[index])"
            let ScoreNode: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
            delay += 0.15
            ScoreNode.text = rank
            ScoreNode.zPosition = 1
            ScoreNode.fontColor = .white
            //ScoreNode.fontColor = index % 2 == 0 ? .cyan : .blue
            ScoreNode.alpha = 10
            ScoreNode.fontSize = 50
            
            let scoreNodeSize = ScoreNode.frame.size
            let textBox = SKShapeNode(rectOf: CGSize(width: max(200, scoreNodeSize.width + 40), height: 80), cornerRadius: 20)
            textBox.fillColor = index % 2 == 0 ? .cyan : .green
            textBox.position = CGPoint(x: 2*size.width, y: height)
            textBox.alpha = 0.2
            ScoreNode.position = CGPoint(x: 0, y: -scoreNodeSize.height / 2)
            textBox.addChild(ScoreNode)
            
            addChild(textBox)
            let moveAction = SKAction.move(to: CGPoint(x: size.width/2, y: height), duration: TimeInterval(0.5 + delay))
            textBox.run(moveAction)
            height -= 100
        }
        delay = 0
        let CurrentlyScore: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        CurrentlyScore.text = "Your score: \(score)"
        CurrentlyScore.position = CGPoint(x: size.width/2, y: size.height/1.2)
        CurrentlyScore.fontColor = .green
        CurrentlyScore.fontSize = 70
        addChild(CurrentlyScore)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if touches.first != nil {
        
        if let touch = touches.first {
            //let location = touch.location(in: self)
            let transition = SKTransition.fade(withDuration: 2)
            let EndScene = EndingScene()
            //EndScene.Game_Scene = score
            EndScene.scaleMode = .fill
            self.view?.presentScene(EndScene, transition: transition)
        }
    }
}

struct ScoreBoard: View {
    var body: some View {
        SpriteView(scene: ScoreBoardScene())
            .ignoresSafeArea(.all)
    }
}

#Preview {
    ScoreBoard()
}
