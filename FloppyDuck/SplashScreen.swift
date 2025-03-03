//
//  SplashScreen.swift
//  FloppyDuck
//
//  Created for FloppyDuck game
//

import SpriteKit

class SplashScreen: SKScene {
    
    // MARK: - Properties
    var completion: (() -> Void)?
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        
        setupSplashScreen()
        animateSplashScreen()
    }
    
    // MARK: - Create Splash Screen Elements
    private func setupSplashScreen() {
        // Create title label
        let titleLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        titleLabel.text = "Floppy Duck"
        titleLabel.fontSize = 48
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 30)
        titleLabel.alpha = 0
        titleLabel.name = "titleLabel"
        self.addChild(titleLabel)
        
        // Create duck silhouette
        let duckTexture = SKTexture(imageNamed: "duck-01")
        let duck = SKSpriteNode(texture: duckTexture)
        duck.setScale(3.0)
        duck.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 80)
        duck.alpha = 0
        duck.name = "duck"
        self.addChild(duck)
        
        // Create subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        subtitleLabel.text = "Tap to start flapping!"
        subtitleLabel.fontSize = 24
        subtitleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 180)
        subtitleLabel.alpha = 0
        subtitleLabel.name = "subtitleLabel"
        self.addChild(subtitleLabel)
    }
    
    // MARK: - Animate Splash Screen
    private func animateSplashScreen() {
        // Animate title label
        if let titleLabel = self.childNode(withName: "titleLabel") {
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            let scaleUp = SKAction.scale(to: 1.2, duration: 1.0)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            
            let sequence = SKAction.sequence([fadeIn, scaleUp, scaleDown])
            titleLabel.run(sequence)
        }
        
        // Animate duck
        if let duck = self.childNode(withName: "duck") {
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.5)
            let moveDown = SKAction.moveBy(x: 0, y: -20, duration: 0.5)
            let flap = SKAction.repeatForever(SKAction.sequence([moveUp, moveDown]))
            
            let sequence = SKAction.sequence([SKAction.wait(forDuration: 0.5), fadeIn])
            duck.run(sequence)
            duck.run(SKAction.sequence([SKAction.wait(forDuration: 1.5), flap]))
        }
        
        // Animate subtitle
        if let subtitleLabel = self.childNode(withName: "subtitleLabel") {
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ]))
            
            let sequence = SKAction.sequence([SKAction.wait(forDuration: 1.0), fadeIn])
            subtitleLabel.run(sequence)
            subtitleLabel.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), pulse]))
        }
        
        // After animation, allow touch to continue
        self.run(SKAction.wait(forDuration: 2.0)) {
            self.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Complete with animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        self.run(fadeOut) {
            self.completion?()
        }
    }
} 