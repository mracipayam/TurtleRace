

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var road: SKSpriteNode = SKSpriteNode(imageNamed: "road1")
    private var road2: SKSpriteNode = SKSpriteNode(imageNamed: "road2")
    
    private var playersCar = SKSpriteNode(imageNamed: "car0")
    let height = CGFloat(1334)
    let width = CGFloat(750)
    let roadSpeed = 1.0
    var timer: Timer? // Car timers
    var score = 0
    let scoreDisplay = SKLabelNode(text: "0")
    
    var gameTimer: Timer?
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        
        self.setup1stRoad()
        self.setup2ndRoad()
        self.addChild(self.scoreDisplay)
        scoreDisplay.fontName = "Helvetica"
        self.scoreDisplay.fontSize = 50
        self.scoreDisplay.position = CGPoint(x: self.width / 2 - 370, y: self.height / 2 - 100)
        
        playersCar.xScale = 0.25
        playersCar.yScale = 0.25
        self.addChild(playersCar)
        self.physicsWorld.contactDelegate = self
        
        let physicsBody = SKPhysicsBody(rectangleOf: self.playersCar.size)
        physicsBody.contactTestBitMask = 0x00000001
        //physicsBody.pinned = true
        physicsBody.allowsRotation = false
        physicsBody.affectedByGravity = false
        self.playersCar.physicsBody = physicsBody
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] (_) in
            self?.newCar()
        })
        
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 40, repeats: false) { (_) in
            let gameOverScene = GameOverScene()
            gameOverScene.size = self.size
            gameOverScene.score = self.score
            self.view?.presentScene(gameOverScene)
            
        }
    }
    
    func setup1stRoad() {
        self.addChild(road)
        self.road.size = CGSize(width: self.width, height: self.height)
        self.road.zPosition = CGFloat(-1)
        let action1 = SKAction.moveBy(x: 0, y: -self.height, duration: self.roadSpeed)
        let action2 = SKAction.moveBy(x: 0, y: 2*self.height, duration: 0)
        let action3 = SKAction.moveBy(x: 0, y: -self.height, duration: self.roadSpeed)
        let sequence = SKAction.sequence([action1, action2, action3])
        let repetition = SKAction.repeatForever(sequence)
        
        self.road.run(repetition)
    }
    
    func setup2ndRoad() {
        self.addChild(road2)
        self.road2.zPosition = CGFloat(-1)
        self.road2.size = CGSize(width: self.width, height: self.height)
        let action1 = SKAction.moveBy(x: 0, y: self.height, duration: 0)
        let action2 = SKAction.moveBy(x: 0, y: -2*self.height, duration: self.roadSpeed * 2)
        let action3 = SKAction.moveBy(x: 0, y: self.height, duration: 0)
        let sequence = SKAction.sequence([action1, action2, action3])
        let repetition = SKAction.repeatForever(sequence)
        self.road2.run(repetition)
    }
    
    func newCar() {
        self.score += 5
        let carType = arc4random() % 6 + 1
        let node = SKSpriteNode(imageNamed: "car\(carType)")
        node.name = "car"
        let width = self.width - CGFloat(200)
        let positionOffset = Int(arc4random()) % Int(width) - Int(width) / 2
        
        node.position = CGPoint(x: CGFloat(positionOffset), y: self.height / 2)
        node.size = CGSize(width: 80, height: 160)
        let duration = Double(arc4random() % 50 + 5) / 10.0
        let action = SKAction.moveBy(x: 0, y: -(self.height + 100), duration: duration)
        let actionRemove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action, actionRemove])
        node.run(sequence)
        self.addChild(node)
        
        let physicsBody = SKPhysicsBody(rectangleOf: node.size)
        physicsBody.contactTestBitMask = 0x00000002
        physicsBody.restitution = 2

        physicsBody.allowsRotation = true
        
        node.physicsBody = physicsBody
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] (_) in
            self?.newCar()
        })
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        self.playersCar.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        self.playersCar.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.enumerateChildNodes(withName: "car") { (node, stop) in
            if node.intersects(self.playersCar) {
                self.score -= 1
                
            }
        }
        self.scoreDisplay.text = "\(self.score)"
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        print(contact.contactPoint)
    }
    
    
}
