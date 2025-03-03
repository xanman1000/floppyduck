import SpriteKit
import GameKit
import CoreHaptics

/// This file demonstrates the key polish and refinement improvements
/// made during Week 3. These features enhance the visual quality,
/// gameplay feel, and user experience of Floppy Duck.

// MARK: - Visual Polish Manager

class VisualPolishManager {
    // Singleton pattern
    static let shared = VisualPolishManager()
    
    // MARK: - Visual Effects Properties
    
    private var hapticEngine: CHHapticEngine?
    private var particleCache: [String: SKEmitterNode] = [:]
    private var postProcessingFilters: [CIFilter] = []
    
    // MARK: - Initialization
    
    private init() {
        setupHaptics()
        setupPostProcessingFilters()
    }
    
    // MARK: - Advanced Particle Effects
    
    /// Generates contextual particle effects based on the game state and environment
    func generateContextualEffects(for duck: SKSpriteNode, in scene: SKScene, with gameState: GameState) {
        // Dynamic particle effects based on duck velocity and environment
        let velocity = duck.physicsBody?.velocity ?? CGVector.zero
        let position = duck.position
        let theme = EnvironmentManager.shared.currentTheme
        
        switch gameState {
        case .playing:
            if velocity.dy > 200 {
                // Fast upward movement - generate wind/thrust particles
                addThrustParticles(at: position, in: scene)
            } else if velocity.dy < -150 {
                // Fast downward movement - generate falling particles
                addFallingParticles(at: position, in: scene)
            }
            
            // Add environment-based particles
            if theme.hasWeatherEffects {
                addWeatherParticles(in: scene, theme: theme)
            }
            
        case .gameOver:
            // Dramatic explosion/feather burst on game over
            addGameOverParticles(at: duck.position, in: scene)
            performIntenseHapticFeedback()
            
        default:
            break
        }
    }
    
    private func addThrustParticles(at position: CGPoint, in scene: SKScene) {
        guard let thrustEmitter = particleCache["thrust"] ?? SKEmitterNode(fileNamed: "ThrustParticle.sks") else {
            return
        }
        
        thrustEmitter.position = CGPoint(x: position.x, y: position.y - 20)
        thrustEmitter.targetNode = scene
        
        // Only add if not already in scene
        if thrustEmitter.parent == nil {
            scene.addChild(thrustEmitter)
            particleCache["thrust"] = thrustEmitter
        }
        
        // Auto-remove after brief duration
        thrustEmitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    private func addFallingParticles(at position: CGPoint, in scene: SKScene) {
        guard let fallEmitter = particleCache["fall"] ?? SKEmitterNode(fileNamed: "FallParticle.sks") else {
            return
        }
        
        fallEmitter.position = position
        fallEmitter.targetNode = scene
        
        if fallEmitter.parent == nil {
            scene.addChild(fallEmitter)
            particleCache["fall"] = fallEmitter
        }
        
        fallEmitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    private func addWeatherParticles(in scene: SKScene, theme: EnvironmentManager.EnvironmentTheme) {
        guard let weatherEmitter = getWeatherEmitter(for: theme) else { return }
        
        weatherEmitter.position = CGPoint(x: scene.size.width/2, y: scene.size.height)
        weatherEmitter.particlePositionRange = CGVector(dx: scene.size.width * 1.5, dy: 0)
        weatherEmitter.targetNode = scene
        
        if weatherEmitter.parent == nil {
            scene.addChild(weatherEmitter)
        }
    }
    
    private func addGameOverParticles(at position: CGPoint, in scene: SKScene) {
        guard let explosionEmitter = SKEmitterNode(fileNamed: "GameOverExplosion.sks") else {
            return
        }
        
        explosionEmitter.position = position
        explosionEmitter.targetNode = scene
        scene.addChild(explosionEmitter)
        
        // Auto-remove after animation completes
        explosionEmitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
        
        // Add screen shake effect
        addScreenShake(to: scene)
    }
    
    private func getWeatherEmitter(for theme: EnvironmentManager.EnvironmentTheme) -> SKEmitterNode? {
        switch theme.weatherType {
        case .rain:
            return SKEmitterNode(fileNamed: "RainParticle.sks")
        case .snow:
            return SKEmitterNode(fileNamed: "SnowParticle.sks")
        case .leaves:
            return SKEmitterNode(fileNamed: "LeavesParticle.sks")
        case .none:
            return nil
        }
    }
    
    // MARK: - Advanced Visual Effects
    
    /// Applies post-processing effects to the scene
    func applyPostProcessing(to scene: SKScene) {
        guard !postProcessingFilters.isEmpty else { return }
        
        // Apply filters to scene
        scene.filter = CIFilter(name: "CICompositingGroup", parameters: [
            "inputFilters": postProcessingFilters
        ])
    }
    
    private func setupPostProcessingFilters() {
        // Color adjustments for better visual appeal
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(1.1, forKey: "inputSaturation") // Slightly more saturated
            colorControls.setValue(0.05, forKey: "inputBrightness") // Slightly brighter
            colorControls.setValue(1.1, forKey: "inputContrast") // Slightly more contrast
            postProcessingFilters.append(colorControls)
        }
        
        // Slight bloom/glow effect for light sources
        if let bloom = CIFilter(name: "CIBloom") {
            bloom.setValue(2.5, forKey: "inputRadius")
            bloom.setValue(0.5, forKey: "inputIntensity")
            postProcessingFilters.append(bloom)
        }
    }
    
    /// Adds professional screen shake effect
    func addScreenShake(to scene: SKScene, intensity: CGFloat = 8.0, duration: TimeInterval = 0.5) {
        // Save original position
        let originalPosition = scene.camera?.position ?? CGPoint.zero
        
        // Create sequence of random movements
        var actions: [SKAction] = []
        let steps = Int(duration * 60) // 60 steps per second for smoothness
        
        for _ in 0..<steps {
            let randomX = CGFloat.random(in: -intensity...intensity)
            let randomY = CGFloat.random(in: -intensity...intensity)
            let moveAction = SKAction.moveBy(x: randomX, y: randomY, duration: 0.01)
            actions.append(moveAction)
        }
        
        // Add final action to return to original position
        actions.append(SKAction.move(to: originalPosition, duration: 0.01))
        
        // Run the sequence
        scene.camera?.run(SKAction.sequence(actions))
    }
    
    // MARK: - Advanced Animation System
    
    /// Creates smooth, dynamic animations for the duck based on its state and physics
    func applyDynamicDuckAnimations(to duck: SKSpriteNode, velocity: CGVector) {
        // Remove any existing rotation actions
        duck.removeAction(forKey: "rotation")
        
        // Calculate target rotation based on velocity
        // This creates a more natural, physics-based rotation
        let targetRotation = calculateNaturalRotation(from: velocity)
        
        // Current rotation
        let currentRotation = duck.zRotation
        
        // Calculate rotation speed based on how different current and target rotations are
        let rotationDifference = abs(targetRotation - currentRotation)
        let rotationDuration = min(0.2, 0.1 + (rotationDifference / .pi) * 0.1)
        
        // Create smooth rotation action
        let rotateAction = SKAction.rotate(toAngle: targetRotation, duration: rotationDuration, shortestUnitArc: true)
        rotateAction.timingMode = .easeOut
        
        // Apply rotation
        duck.run(rotateAction, withKey: "rotation")
        
        // Add "flap" animation if rising quickly
        if velocity.dy > 100 && duck.action(forKey: "flap") == nil {
            animateFlapSequence(for: duck)
        }
    }
    
    private func calculateNaturalRotation(from velocity: CGVector) -> CGFloat {
        // Map vertical velocity to a rotation range
        // Falling = nose down (positive rotation)
        // Rising = level or slightly up (zero or negative rotation)
        
        // Constants for tuning
        let maxDownwardRotation: CGFloat = .pi / 4      // 45 degrees down
        let maxUpwardRotation: CGFloat = -.pi / 10      // 18 degrees up
        let velocityInfluence: CGFloat = 0.003          // How much velocity affects rotation
        
        // Calculate target rotation based on vertical velocity
        var targetRotation = velocity.dy * -velocityInfluence
        
        // Clamp to our min/max rotation values
        targetRotation = max(targetRotation, maxUpwardRotation)
        targetRotation = min(targetRotation, maxDownwardRotation)
        
        return targetRotation
    }
    
    private func animateFlapSequence(for duck: SKSpriteNode) {
        // Get the appropriate flap animation from the CustomizationManager
        if let flapAnimation = CustomizationManager.shared.createFlapAnimation() {
            duck.run(flapAnimation, withKey: "flap")
        }
    }
    
    // MARK: - Advanced Haptic Feedback
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Handle engine stopping
            hapticEngine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
                try? self.hapticEngine?.start()
            }
            
            // Handle engine reset
            hapticEngine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                try? self?.hapticEngine?.start()
            }
        } catch {
            print("Failed to initialize haptic engine: \(error)")
        }
    }
    
    /// Performs a flap haptic feedback - light tap sensation
    func performFlapHapticFeedback() {
        // For devices without advanced haptics, fall back to basic feedback
        if hapticEngine == nil {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }
        
        // Advanced haptic pattern for flap
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else { return }
        
        // Create a haptic pattern that feels like a quick wing flap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
    
    /// Performs intense haptic feedback for collisions
    func performIntenseHapticFeedback() {
        // For devices without advanced haptics
        if hapticEngine == nil {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred(intensity: 1.0)
            return
        }
        
        // Advanced haptic pattern
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else { return }
        
        // Create a haptic pattern for collision - initial impact followed by rumble
        var events = [CHHapticEvent]()
        
        // Sharp initial impact
        let initialIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let initialSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [initialIntensity, initialSharpness], relativeTime: 0))
        
        // Rumble decay
        for i in 1...5 {
            let time = 0.05 * Double(i)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1.0 - (Double(i) * 0.2)))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.8 - (Double(i) * 0.1)))
            
            events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: time, duration: 0.05))
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}

// MARK: - Gameplay Polish

class GameplayPolishManager {
    // Singleton pattern
    static let shared = GameplayPolishManager()
    
    // MARK: - Properties
    
    private var difficultyLevel: Int = 1
    private var adaptiveDifficultyEnabled: Bool = true
    
    // MARK: - Adaptive Difficulty System
    
    /// Adjusts game difficulty based on player performance
    func updateDifficulty(currentScore: Int, averageScore: Int, playCount: Int) {
        guard adaptiveDifficultyEnabled else { return }
        
        // Base difficulty on player's current score compared to their average
        if playCount > 5 {
            // Only start adapting after a few games to establish baseline
            if currentScore > averageScore * 1.5 {
                // Player is doing much better than usual
                difficultyLevel = min(difficultyLevel + 1, 5)
            } else if currentScore < averageScore * 0.5 && difficultyLevel > 1 {
                // Player is struggling
                difficultyLevel = max(difficultyLevel - 1, 1)
            }
        }
    }
    
    /// Applies difficulty settings to game parameters
    func applyDifficultySettings(to pipeSpawner: PipeSpawner) {
        switch difficultyLevel {
        case 1: // Easiest
            pipeSpawner.pipeGapSize = 180
            pipeSpawner.pipeSpeed = 100
            pipeSpawner.timeBetweenPipes = 2.5
        case 2:
            pipeSpawner.pipeGapSize = 160
            pipeSpawner.pipeSpeed = 120
            pipeSpawner.timeBetweenPipes = 2.2
        case 3: // Default
            pipeSpawner.pipeGapSize = 140
            pipeSpawner.pipeSpeed = 140
            pipeSpawner.timeBetweenPipes = 1.9
        case 4:
            pipeSpawner.pipeGapSize = 120
            pipeSpawner.pipeSpeed = 160
            pipeSpawner.timeBetweenPipes = 1.7
        case 5: // Hardest
            pipeSpawner.pipeGapSize = 100
            pipeSpawner.pipeSpeed = 180
            pipeSpawner.timeBetweenPipes = 1.5
        default:
            break
        }
    }
    
    // MARK: - Advanced Pipe Types
    
    /// Creates special pipe types for added variety
    func createSpecialPipe(at position: CGPoint, in scene: SKScene) -> SKNode {
        let pipeNode = SKNode()
        pipeNode.position = position
        
        // Base chance for special pipes increases with difficulty
        let specialPipeChance = min(0.05 * Double(difficultyLevel), 0.25)
        
        if Double.random(in: 0...1) < specialPipeChance {
            // Create a special pipe
            let specialType = Int.random(in: 0...3)
            
            switch specialType {
            case 0:
                return createMovingPipe(at: position, in: scene)
            case 1:
                return createSizingPipe(at: position, in: scene)
            case 2:
                return createGhostPipe(at: position, in: scene)
            case 3:
                return createRewardPipe(at: position, in: scene)
            default:
                break
            }
        }
        
        // Return standard pipe if no special pipe was created
        return PipeSpawner.shared.createStandardPipe(at: position)
    }
    
    /// Creates a pipe that moves up and down
    private func createMovingPipe(at position: CGPoint, in scene: SKScene) -> SKNode {
        let pipe = PipeSpawner.shared.createStandardPipe(at: position)
        
        // Apply a repeating up and down movement
        let moveUp = SKAction.moveBy(x: 0, y: 150, duration: 2.0)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SKAction.moveBy(x: 0, y: -150, duration: 2.0)
        moveDown.timingMode = .easeInEaseOut
        let sequence = SKAction.sequence([moveUp, moveDown])
        let repeatForever = SKAction.repeatForever(sequence)
        
        pipe.run(repeatForever)
        
        // Add visual indicator that this is a special pipe
        let indicator = SKSpriteNode(color: .yellow, size: CGSize(width: 20, height: 20))
        indicator.position = CGPoint(x: 0, y: 0)
        pipe.addChild(indicator)
        
        return pipe
    }
    
    /// Creates a pipe that changes its gap size
    private func createSizingPipe(at position: CGPoint, in scene: SKScene) -> SKNode {
        let pipe = PipeSpawner.shared.createStandardPipe(at: position)
        
        // Get top and bottom parts of the pipe
        let children = pipe.children
        guard children.count >= 2 else { return pipe }
        
        let topPipe = children[0]
        let bottomPipe = children[1]
        
        // Create a pulsing gap size animation
        let moveTopUp = SKAction.moveBy(x: 0, y: 40, duration: 1.5)
        moveTopUp.timingMode = .easeInEaseOut
        let moveTopDown = SKAction.moveBy(x: 0, y: -40, duration: 1.5)
        moveTopDown.timingMode = .easeInEaseOut
        
        let moveBottomDown = SKAction.moveBy(x: 0, y: -40, duration: 1.5)
        moveBottomDown.timingMode = .easeInEaseOut
        let moveBottomUp = SKAction.moveBy(x: 0, y: 40, duration: 1.5)
        moveBottomUp.timingMode = .easeInEaseOut
        
        let topSequence = SKAction.sequence([moveTopUp, moveTopDown])
        let bottomSequence = SKAction.sequence([moveBottomDown, moveBottomUp])
        
        topPipe.run(SKAction.repeatForever(topSequence))
        bottomPipe.run(SKAction.repeatForever(bottomSequence))
        
        // Add visual indicator
        let indicator = SKSpriteNode(color: .purple, size: CGSize(width: 20, height: 20))
        indicator.position = CGPoint(x: 0, y: 0)
        pipe.addChild(indicator)
        
        return pipe
    }
    
    /// Creates a semi-transparent pipe that can be passed through but gives fewer points
    private func createGhostPipe(at position: CGPoint, in scene: SKScene) -> SKNode {
        let pipe = PipeSpawner.shared.createStandardPipe(at: position)
        
        // Make pipe semi-transparent and adjust physics
        pipe.alpha = 0.5
        pipe.children.forEach { child in
            child.physicsBody?.categoryBitMask = 0 // No collisions
        }
        
        // Add special pass-through scoring logic
        // This would be handled by the game scene
        
        // Add visual indicator
        let indicator = SKSpriteNode(color: .cyan, size: CGSize(width: 20, height: 20))
        indicator.position = CGPoint(x: 0, y: 0)
        pipe.addChild(indicator)
        
        return pipe
    }
    
    /// Creates a pipe with a reward item in the center
    private func createRewardPipe(at position: CGPoint, in scene: SKScene) -> SKNode {
        let pipe = PipeSpawner.shared.createStandardPipe(at: position)
        
        // Create reward item (coin, power-up, etc.)
        let reward = SKSpriteNode(imageNamed: "coin")
        reward.size = CGSize(width: 40, height: 40)
        reward.position = CGPoint.zero // Center of pipe
        
        // Add physics body for detection
        reward.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        reward.physicsBody?.isDynamic = false
        reward.physicsBody?.categoryBitMask = 4 // Reward category
        reward.physicsBody?.contactTestBitMask = 1 // Player category
        reward.physicsBody?.collisionBitMask = 0 // No collisions
        
        // Add spinning animation
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        reward.run(SKAction.repeatForever(spin))
        
        // Add glow effect
        let glow = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        reward.run(SKAction.repeatForever(glow))
        
        pipe.addChild(reward)
        
        return pipe
    }
    
    // MARK: - Tutorial System
    
    /// Creates an improved, context-sensitive tutorial
    func createAdaptiveTutorial(in scene: SKScene, gameState: GameState) -> SKNode {
        let tutorialNode = SKNode()
        
        // Check if this is first time player
        let isFirstTime = UserDefaults.standard.integer(forKey: "gamesPlayed") < 3
        
        if isFirstTime {
            // Create comprehensive tutorial
            createFullTutorial(on: tutorialNode, in: scene)
        } else {
            // Create contextual tips based on player stats
            let averageScore = UserDefaults.standard.integer(forKey: "averageScore")
            let highScore = UserDefaults.standard.integer(forKey: "highScore")
            
            if highScore < 10 {
                // Player is struggling - show basic tips
                addTutorialTip(to: tutorialNode, text: "Tap lightly for more control", position: CGPoint(x: scene.size.width/2, y: scene.size.height * 0.75))
            } else if averageScore < highScore / 2 {
                // Player is inconsistent - show advanced tips
                addTutorialTip(to: tutorialNode, text: "Maintain steady rhythm for best results", position: CGPoint(x: scene.size.width/2, y: scene.size.height * 0.75))
            }
        }
        
        return tutorialNode
    }
    
    private func createFullTutorial(on node: SKNode, in scene: SKScene) {
        // Background dimming
        let background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6), size: scene.size)
        background.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        node.addChild(background)
        
        // Title
        let title = SKLabelNode(text: "How to Play")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 36
        title.fontColor = .white
        title.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.8)
        node.addChild(title)
        
        // Tap instruction with animation
        let tapInstruction = SKLabelNode(text: "Tap to flap your wings and fly")
        tapInstruction.fontName = "AvenirNext-Medium"
        tapInstruction.fontSize = 24
        tapInstruction.fontColor = .white
        tapInstruction.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.7)
        node.addChild(tapInstruction)
        
        // Animated duck example
        let exampleDuck = SKSpriteNode(imageNamed: "duck1")
        exampleDuck.size = CGSize(width: 80, height: 80)
        exampleDuck.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.5)
        node.addChild(exampleDuck)
        
        // Create flap animation
        let flapUp = SKAction.moveBy(x: 0, y: 50, duration: 0.4)
        flapUp.timingMode = .easeOut
        let flapDown = SKAction.moveBy(x: 0, y: -50, duration: 0.6)
        flapDown.timingMode = .easeIn
        let flapSequence = SKAction.sequence([flapUp, flapDown])
        
        // Animated hand icon
        let hand = SKSpriteNode(imageNamed: "tap_icon")
        hand.size = CGSize(width: 60, height: 60)
        hand.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.3)
        node.addChild(hand)
        
        // Hand tap animation
        let tapDown = SKAction.scale(to: 0.8, duration: 0.1)
        let tapUp = SKAction.scale(to: 1.0, duration: 0.1)
        let waitAction = SKAction.wait(forDuration: 1.0)
        let tapSequence = SKAction.sequence([tapDown, tapUp, waitAction])
        
        // Run animations
        hand.run(SKAction.repeatForever(tapSequence))
        exampleDuck.run(SKAction.repeatForever(flapSequence))
        
        // Continue button
        let continueButton = SKSpriteNode(color: UIColor(red: 0, green: 0.6, blue: 1, alpha: 1), size: CGSize(width: 200, height: 60))
        continueButton.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.15)
        continueButton.name = "tutorialContinueButton"
        
        let continueLabel = SKLabelNode(text: "Start Playing")
        continueLabel.fontName = "AvenirNext-Bold"
        continueLabel.fontSize = 20
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueButton.addChild(continueLabel)
        
        node.addChild(continueButton)
    }
    
    private func addTutorialTip(to node: SKNode, text: String, position: CGPoint) {
        // Create tip bubble
        let bubble = SKShapeNode(rectOf: CGSize(width: 300, height: 80), cornerRadius: 20)
        bubble.fillColor = UIColor(white: 0.1, alpha: 0.8)
        bubble.strokeColor = UIColor(white: 1.0, alpha: 0.3)
        bubble.position = position
        
        // Create tip text
        let tipText = SKLabelNode(text: text)
        tipText.fontName = "AvenirNext-Medium"
        tipText.fontSize = 18
        tipText.fontColor = .white
        tipText.position = CGPoint.zero
        tipText.verticalAlignmentMode = .center
        bubble.addChild(tipText)
        
        // Add light pulsing animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.0)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        bubble.run(SKAction.repeatForever(pulseSequence))
        
        // Auto-dismiss after a few seconds
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        bubble.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            fadeOut,
            remove
        ]))
        
        node.addChild(bubble)
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer for singleton
    }
}

// MARK: - Pipe Spawner Class Reference

/// Reference to the PipeSpawner class for the purposes of this file
class PipeSpawner {
    static let shared = PipeSpawner()
    
    var pipeGapSize: CGFloat = 140
    var pipeSpeed: CGFloat = 140
    var timeBetweenPipes: TimeInterval = 1.9
    
    func createStandardPipe(at position: CGPoint) -> SKNode {
        // This would be implemented in the actual game
        // Simple placeholder implementation
        let pipeNode = SKNode()
        pipeNode.position = position
        
        let topPipe = SKSpriteNode(color: .green, size: CGSize(width: 80, height: 500))
        topPipe.position = CGPoint(x: 0, y: pipeGapSize/2 + 250)
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        
        let bottomPipe = SKSpriteNode(color: .green, size: CGSize(width: 80, height: 500))
        bottomPipe.position = CGPoint(x: 0, y: -(pipeGapSize/2 + 250))
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        
        pipeNode.addChild(topPipe)
        pipeNode.addChild(bottomPipe)
        
        return pipeNode
    }
    
    private init() {}
} 