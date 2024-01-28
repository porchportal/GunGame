//
//  EndingScene.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 22/1/2567 BE.
//

import SwiftUI
import SpriteKit

class EndingScene: SKScene, ObservableObject{
    let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
    let exitLabel = SKLabelNode(fontNamed: "Chalkduster")
    var onExit: (() -> Void)?
    @Published var isShowGame = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        scene?.size = CGSize(width: 750, height: 1335)
        
        // Game Over Text
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Chalkduster"
        gameOverLabel.fontSize = 100
        gameOverLabel.zPosition = 1
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(gameOverLabel)

        let backgroundImage = SKSpriteNode(imageNamed: "Image001")
        backgroundImage.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundImage.zPosition = -1
        backgroundImage.alpha = 0.6
        backgroundImage.setScale(1.3)
        addChild(backgroundImage)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: size.width/2, y: size.height*0.4)
        self.addChild(restartLabel)
        
        exitLabel.text = "Exit \(isShowGame)"
        exitLabel.fontSize = 90
        exitLabel.fontColor = SKColor.white
        exitLabel.zPosition = 1
        exitLabel.position = CGPoint(x: size.width/2, y: size.height*0.3)
        self.addChild(exitLabel)
    }

    // Touch handling to go back to the start or reset game
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pointOfTouch = touch.location(in: self)
            print("Touch detected at: \(pointOfTouch)")
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = Game_Scene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let Transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: Transition)
                
            }
            if exitLabel.contains(pointOfTouch){
                exit()
            }
        }
    }
    func exit(){
        onExit?()
        isShowGame = true
        exitLabel.text = "Exit \(isShowGame)"
    }
}

struct EndingScene1: View {
    @Binding var status: Int
    @Binding var ContentActive : Bool
    @ObservedObject var scene2 = EndingScene()
    //@ObservedObject var scene = Game_Scene(size: CGSize(width: 750, height: 1335))
    var body: some View {
        ZStack{
            SpriteView(scene: scene2)
                .ignoresSafeArea()
            
            Button{
                status = 1
                ContentActive = false
                scene2.exit()
            } label: {
                Text("Exit")
                    .font(.custom("Chalkduster", size: 50))
                    //.offset(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.width*0.3)
                    .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.width*0.3)
                    .foregroundColor(.white)
                    .padding()
                    //.background(Color.green.opacity(0.5))
                    .clipShape(.capsule)
                    .cornerRadius(30)
                    .shadow(color: .red, radius: 10, x: 5, y: 5)
            }
            
        }
        .onAppear{
            scene2.onExit = {status = 1}
        }
        .onChange(of: scene2.isShowGame){
            if scene2.isShowGame{

                status = 1
                //scene2.isShowGame = false
                ContentActive = false
            }
        }
    }
}

#Preview {
    EndingScene1(status: .constant(0), ContentActive: .constant(false))
}
