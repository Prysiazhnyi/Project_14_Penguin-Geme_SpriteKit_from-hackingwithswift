//
//  GameScene.swift
//  Project-14
//
//  Created by Serhii Prysiazhnyi on 12.11.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var slots = [WhackSlot]()
    var popupTime = 0.85
    var numRounds = 0
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
        
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
        
    }
    
    func createEnemy() {
        
        numRounds += 1

        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }

            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.name = "gameOver"
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            run(SKAction.playSoundFileNamed("Игра окончена!Vova.m4a", waitForCompletion: false))
            
            // Создаем уведомление с кнопкой для перезапуска игры
            let ac = UIAlertController(
                title: "Your score: \(score)",
                message: "Press OK to start the game again",
                preferredStyle: .alert
            )
            
            // Добавляем действие OK, которое перезапускает игру
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.restartGame()
            })
            // Ищем родительский UIViewController
            if let viewController = view?.window?.rootViewController {
                viewController.present(ac, animated: true)
            }
            
            print("Игра окончена")

            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 {  slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)  }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if let smoke = SKEmitterNode(fileNamed: "Smoke") {
                 smoke.position = whackSlot.position
                 addChild(smoke)
             }
            
            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin
                score -= 5

                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                // they should have whacked this one
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1

                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    func restartGame() {
        // Сбрасываем значения для новой игры
        score = 0
        numRounds = 0
        popupTime = 0.85
        
        if let gameOverNode = childNode(withName: "gameOver") {
              gameOverNode.removeFromParent()
          }
        
        // Перезапускаем процесс создания врагов
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
}
