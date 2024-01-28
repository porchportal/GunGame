

import SwiftUI
import SpriteKit

class Game_testing: SKScene{
    var bossyOne_ = SKSpriteNode()
    let bossHealthLabel = SKLabelNode(fontNamed: "Chalkduster")
    var bossOneFire_ = SKSpriteNode()
    let NumberOne = SKLabelNode(fontNamed: "Chalkduster")
    let NumberOneLabel = SKLabelNode(fontNamed: "Chalkduster")
    let Damage = SKLabelNode(fontNamed: "Chalkduster")
    //var BossChoice = UserDefaults.standard
    var bulletDamage : Int = 0
    var statusUpdate = 0
    override func didMove(to view: SKView) {
        scene?.size = CGSize(width: 750, height: 1335)
        makeBossOne_()
        
        Damage.text = "Damage \(bulletDamage)"
        Damage.position = CGPoint(x: size.width/2, y: size.height/1.4)
        Damage.fontColor = .white
        Damage.fontSize = 50
        self.addChild(Damage)
        
        NumberOne.text = "The Number 2"
        NumberOne.position = CGPoint(x: size.width/2, y: size.height/5)
        NumberOne.fontSize = 50
        NumberOne.fontColor = .white
        NumberOne.zPosition = 1
        self.addChild(NumberOne)
        
        NumberOneLabel.text = "Not Active"
        NumberOneLabel.position = CGPoint(x: size.width/2, y: size.height/8)
        NumberOneLabel.fontSize = 50
        NumberOneLabel.fontColor = .white
        NumberOneLabel.zPosition = 1
        self.addChild(NumberOneLabel)
        
    }
    func updateGameState(){
        if statusUpdate == 1{
            bossOneFire_.texture = SKTexture(imageNamed: "Number2.001")
            activateTheNumber()
            //print("Status update 1, setting bulletDamage to 20")
            bulletDamage = 20
            Damage.text = "Damage \(bulletDamage)"
        }
        else if statusUpdate == 2{
            bossOneFire_.texture = SKTexture(imageNamed: "buttel.001")
            bossyOne_.removeChildren(in: [bossyOne_.childNode(withName: "TheNumber")].compactMap { $0 })
            bulletDamage = 30
        } else {
            bossOneFire_.texture = SKTexture(imageNamed: "buttel.001")
            bossyOne_.childNode(withName: "TheNumber")?.removeFromParent()
            bulletDamage = 1
            Damage.text = "Damage \(bulletDamage)"
        }
    }
    func activateTheNumber() {
        // Check if "TheNumber" is already added, if not, create and add it
        if bossyOne_.childNode(withName: "TheNumber") == nil {
            let TheNumber = SKSpriteNode(imageNamed: "Number2.001")
            TheNumber.name = "TheNumber" // Set a name for easy identification
            TheNumber.size = CGSize(width: 100, height: 100)
            TheNumber.zPosition = 6
            // Adjust the position relative to bossyOne_
            TheNumber.position = CGPoint(x: 6, y: bossyOne_.size.height / 3 + TheNumber.size.height / 8)
            TheNumber.zRotation = .pi
            bossyOne_.addChild(TheNumber)
        }
    }
    func makeBossOne_(){
        
        if let imagePath = BossChoice.string(forKey: "BossImagePath"),
               let data = FileManager.default.contents(atPath: imagePath),
           let uiImage = UIImage(data: data) {
            let texture = SKTexture(image: uiImage)
            //bossyOne_ = SKSpriteNode(texture: texture)
            bossyOne_.size = CGSize(width: 200, height: 200)
            //bossyOne_ = SKSpriteNode(n)
            
            let mask = SKShapeNode(circleOfRadius: 50)
            mask.fillColor = .white
            let cropNode = SKCropNode()
            cropNode.maskNode = mask
            cropNode.addChild(SKSpriteNode(texture: texture))
            bossyOne_.addChild(cropNode)
            
        } else {
            bossyOne_ = SKSpriteNode(imageNamed: "Boss")
            bossyOne_.size = CGSize(width: 300, height: 300)
        }
        //bossyOne_ = SKSpriteNode(imageNamed: "Boss")
        bossyOne_.position = CGPoint(x: size.width/2, y: size.height/2)
        bossyOne_.zPosition = 10
        bossyOne_.setScale(1.3)
        //bossyOne_.size = CGSize(width: 300, height: 300)
        bossyOne_.zRotation = .pi
        addChild(bossyOne_)
    }
    func bossOneFireFunc_() {
        let randomAngle = CGFloat.random(in: 150...210) * CGFloat.pi / 180
        //var ImageBullet = ""
        //var StatusTheNumber = 0
        /*switch StatusTheNumber{
        case 2:
            ImageBullet = "Number2.001"
        default:
            ImageBullet = "buttel.001"
        }*/
        bossOneFire_ = .init(imageNamed: "buttel.001")
        //print("Created bossOneFire with image: \(ImageBullet)")
        updateGameState()
        bossOneFire_.position = bossyOne_.position
        bossOneFire_.zPosition = 5
        bossOneFire_.size = CGSize(width: 100, height: 100)
        //bossOneFire.physicsBody = SKPhysicsBody(rectangleOf: bossOneFire.size)
        bossOneFire_.physicsBody?.affectedByGravity = false

        let rotationAction = SKAction.rotate(toAngle:randomAngle, duration: 0.5)
        bossyOne_.run(rotationAction)
        bossOneFire_.zRotation = bossyOne_.zRotation
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
                fireThrusterEffectNode.position.y = -40
                bossOneFire_.addChild(fireThrusterEffectNode)
            } catch {
                print("Error unarchiving file: \(error)")
            }
        }
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
            self.bossOneFire_.run(sequence)
        }

            // Sequence the rotation and movement
        let fireSequence = SKAction.sequence([fireRotationAction, moveAction])
        bossOneFire_.run(fireSequence)
        addChild(bossOneFire_)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bossOneFireFunc_()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            //bossyOne_.position = location
            //statusUpdate = (statusUpdate == 0) ? 1 : 0
            if NumberOne.contains(location){
                //BulletBossChoice.set(2, forKey: "BulletBoss")
                NumberOne.run(SKAction.scale(to: 1.4, duration: 0.1))
                //statusUpdate = (statusUpdate == 0) ? 1 : 0
                statusUpdate = 1
                //statusUpdate += 1
                //print("NumberOne touched, setting statusUpdate to 1")

            }
            else if NumberOneLabel.contains(location){
                NumberOneLabel.run(SKAction.scale(to: 1.4, duration: 0.1))
                statusUpdate = 0
                //BulletBossChoice.set(1, forKey: "BulletBoss")
                //statusUpdate = (statusUpdate == 0) ? 1 : 0
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        NumberOne.run(SKAction.scale(to: 1, duration: 0.1))
        NumberOneLabel.run(SKAction.scale(to: 1, duration: 0.1))
    }
}
struct others: View{
    var scene : SKScene{
        let scene = Game_testing()
        scene.size = CGSize(width: 750, height: 1335)
        scene.scaleMode = .aspectFill
        return scene
    }
    var body: some View{
        SpriteView(scene: scene)
            .ignoresSafeArea(.all)
    }
}
#Preview {
    others()
}
