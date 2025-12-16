//
//  GameScene.swift
//  PetualanganAwan
//
//  Created by Diana Febrina Lumbantoruan on 01/12/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var currentTargetWord = ""
    var currentLetterProgress = 0
    var targetEmojiLabel: SKLabelNode?
    var answerSlotsLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupUI()
        startGame()
    }
    
    func setupUI() {
        backgroundColor = SKColor.blue
        
        targetEmojiLabel = SKLabelNode(fontNamed: "AppleColorEmoji")
        targetEmojiLabel?.fontSize = 120
        targetEmojiLabel?.position = CGPoint(x: frame.midX, y: frame.maxY / 1.5)
        targetEmojiLabel?.zPosition = 5
        if let targetEmojiLabel = targetEmojiLabel { addChild(targetEmojiLabel) }
        
        answerSlotsLabel = SKLabelNode(fontNamed: "Avenir-Black")
        answerSlotsLabel?.fontSize = 60
        answerSlotsLabel?.fontColor = .white
        answerSlotsLabel?.position = CGPoint(x: frame.midX, y: (targetEmojiLabel?.position.y ?? 0) - 120)
        answerSlotsLabel?.zPosition = 10
        if let answerSlotsLabel = answerSlotsLabel { addChild(answerSlotsLabel) }
    }
    
    func startGame() {
        currentLetterProgress = 0
        if let randomContent = contentDatabase.randomElement() {
            currentTargetWord = randomContent.targetWord
            targetEmojiLabel?.text = randomContent.targetImage
            targetEmojiLabel?.setScale(0)
            targetEmojiLabel?.run(SKAction.scale(to: 1.0, duration: 0.5))
        }
        updateAnswerSlots()
        startBalloonSpawner()
    }
    
    func updateAnswerSlots() {
        var displayText = ""
        for (index, char) in currentTargetWord.enumerated() {
            if index < currentLetterProgress {
                displayText += "\(char) "
            } else {
                displayText += "_ "
            }
        }
        answerSlotsLabel.text = displayText
    }
    
    func startBalloonSpawner() {
        removeAction(forKey: "spawner")
        let wait = SKAction.wait(forDuration: 0.3)
        let spawn = SKAction.run { [weak self] in
            self?.createBalloon()
        }
        let sequence = SKAction.sequence([wait, spawn])
        run(SKAction.repeatForever(sequence), withKey: "spawner")
    }
    
    @objc func createBalloon() {
        let balloonNode = SKNode()
        let shouldSpawnCorrectBallon = Bool.random()
        var textToShow = ""
        
        if shouldSpawnCorrectBallon && (currentLetterProgress < currentTargetWord.count) {
            let index = currentTargetWord.index(currentTargetWord.startIndex, offsetBy: currentLetterProgress)
            textToShow = String(currentTargetWord[index])
            balloonNode.name = "correctBalloon"
        } else {
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            var randomChar = letters.randomElement()!
            while currentTargetWord.contains(randomChar) {
                randomChar = letters.randomElement()!
            }
            textToShow = String(randomChar)
            balloonNode.name = "wrongBalloon"
        }
        
        let balloonShape = SKShapeNode(circleOfRadius: 55)
        let randomHue = CGFloat.random(in: 0...1)
        balloonShape.fillColor = UIColor(hue: randomHue, saturation: 0.6, brightness: 0.9, alpha: 1.0)
        balloonShape.strokeColor = .white
        balloonShape.lineWidth = 3
        balloonNode.addChild(balloonShape)
        
        let letterLabel = SKLabelNode(fontNamed: "Avenir-Black")
        letterLabel.text = textToShow
        letterLabel.fontSize = 50
        letterLabel.verticalAlignmentMode = .center
        letterLabel.fontColor = .white
        balloonNode.addChild(letterLabel)
        balloonNode.zPosition = 10
        
        let randomX = CGFloat.random(in: frame.minX + 60 ... frame.maxX - 60)
        balloonNode.position = CGPoint(x: randomX, y: frame.minY - 70)
        addChild(balloonNode)
        
        let duration = Double.random(in: 6.0...8.0)
        let moveUp = SKAction.moveTo(y: frame.maxY + 100, duration: duration)
        let remove = SKAction.removeFromParent()
        
        let wiggleToRightOrLeft = SKAction.sequence([
            SKAction.rotate(byAngle: -0.1, duration: 0.5),
            SKAction.rotate(byAngle: 0.1, duration: 0.5)
        ])
        balloonNode.run(SKAction.repeatForever(wiggleToRightOrLeft))
        balloonNode.run(SKAction.sequence([moveUp, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if let parent = node.parent, (parent.name == "correctBalloon" || parent.name == "wrongBalloon") {
                checkBalloon(node: parent)
                break
            }
            
            if node.name == "correctBalloon" || node.name == "wrongBalloon" {
                checkBalloon(node: node)
                break
            }
        }
    }
    
    func checkBalloon(node: SKNode) {
        let correctCharIndex = currentTargetWord.index(currentTargetWord.startIndex, offsetBy: currentLetterProgress)
        let neededChar = String(currentTargetWord[correctCharIndex])
        var textInBalloon = ""
        if let labelNode = node.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
            textInBalloon = labelNode.text ?? ""
        }
        
        if node.name == "correctBalloon" && textInBalloon == neededChar {
            popBalloon(node: node)
            currentLetterProgress += 1
            updateAnswerSlots()
            
            if currentLetterProgress >= currentTargetWord.count {
                showNewQuestionContent()
            }
            
        } else {
            shakeBalloon(node: node)
        }
    }
    
    func shakeBalloon(node: SKNode) {
        let shake = SKAction.sequence([
            SKAction.rotate(byAngle: 0.3, duration: 0.05),
            SKAction.rotate(byAngle: -0.3, duration: 0.05),
            SKAction.rotate(toAngle: 0, duration: 0.05)
        ])
        node.run(SKAction.repeat(shake, count: 3))
    }
    
    func showNewQuestionContent() {
        answerSlotsLabel.fontColor = .white
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.2)
        targetEmojiLabel?.run(SKAction.sequence([scaleUp, scaleBack]))
        
        let wait = SKAction.wait(forDuration: 2.0)
        let nextQuestionContent = SKAction.run { [weak self] in
            self?.answerSlotsLabel.fontColor = .white
            self?.startGame()
        }
        run(SKAction.sequence([wait, nextQuestionContent]))
    }
    
    func popBalloon(node: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "BalloonPop") {
            explosion.position = node.position
            addChild(explosion)
            explosion.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.removeFromParent()]))
        }
        node.removeFromParent()
    }
}
