import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Game Constants
    private let verticalPipeGap: CGFloat = 150.0
    private let pipeSpeed: TimeInterval = 3.0
    
    // MARK: - Physics Categories
    private let duckCategory: UInt32 = 0x1 << 0
    private let obstacleCategory: UInt32 = 0x1 << 1
    private let scoreCategory: UInt32 = 0x1 << 2
    private let groundCategory: UInt32 = 0x1 << 3
    
    // MARK: - Game Properties
    private var gameState: GameState = .mainMenu
    private var isMultiplayer = false
    private var canRestart = false
    
    // MARK: - Duck Properties
    private var player1Duck: SKSpriteNode!
    private var player2Duck: SKSpriteNode?
    private var duckFlapSoundAction: SKAction!
    
    // MARK: - Layers and Nodes
    private var worldNode: SKNode!
    private var player1World: SKNode!
    private var player2World: SKNode?
    private var mainMenuNode: SKNode!
    private var gameOverNode: SKNode!
    
    // MARK: - Scores
    private var player1Score = 0
    private var player2Score = 0
    private var player1ScoreLabel: SKLabelNode!
    private var player2ScoreLabel: SKLabelNode?
    private var highScore = 0
    
    // MARK: - Game States
    enum GameState {
        case mainMenu
        case playing
        case gameOver
    }
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupPhysics()
        loadHighScore()
        setupAudio()
        
        // Create nodes for different game states
        worldNode = SKNode()
        mainMenuNode = SKNode()
        gameOverNode = SKNode()
        
        self.addChild(worldNode)
        self.addChild(mainMenuNode)
        self.addChild(gameOverNode)
        
        showMainMenu()
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
    }
    
    private func setupAudio() {
        // Load sound actions
        duckFlapSoundAction = SKAction.playSoundFileNamed("flap.wav", waitForCompletion: false)
    }
    
    // MARK: - Main Menu
    private func showMainMenu() {
        resetGame()
        gameState = .mainMenu
        gameOverNode.isHidden = true
        
        // Clear previous menu items
        mainMenuNode.removeAllChildren()
        
        // Background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        background.size = self.size
        mainMenuNode.addChild(background)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "FLOPPY DUCK"
        titleLabel.fontSize = 50
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        mainMenuNode.addChild(titleLabel)
        
        // Single Player Button
        let singlePlayerButton = createButton(text: "Single Player", position: CGPoint(x: frame.midX, y: frame.midY))
        singlePlayerButton.name = "singlePlayerButton"
        mainMenuNode.addChild(singlePlayerButton)
        
        // Multiplayer Button
        let multiplayerButton = createButton(text: "Head-to-Head", position: CGPoint(x: frame.midX, y: frame.midY - 80))
        multiplayerButton.name = "multiplayerButton"
        mainMenuNode.addChild(multiplayerButton)
        
        // Credits
        let creditsLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        creditsLabel.text = "Tap to Flap!"
        creditsLabel.fontSize = 20
        creditsLabel.fontColor = .white
        creditsLabel.position = CGPoint(x: frame.midX, y: frame.midY - 200)
        mainMenuNode.addChild(creditsLabel)
    }
    
    private func createButton(text: String, position: CGPoint) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.position = position
        
        let button = SKSpriteNode(color: .systemBlue, size: CGSize(width: 220, height: 60))
        button.alpha = 0.8
        button.cornerRadius = 10
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        
        buttonNode.addChild(button)
        buttonNode.addChild(label)
        
        return buttonNode
    }
    
    // MARK: - Game Setup
    private func startGame(multiplayer: Bool) {
        isMultiplayer = multiplayer
        gameState = .playing
        mainMenuNode.isHidden = true
        gameOverNode.isHidden = true
        
        // Clear world
        worldNode.removeAllChildren()
        
        // Set up player 1 world
        player1World = SKNode()
        worldNode.addChild(player1World)
        
        if multiplayer {
            // Set up player 2 world for multiplayer
            player2World = SKNode()
            worldNode.addChild(player2World!)
            
            // Position worlds side by side
            player1World.position = CGPoint(x: 0, y: 0)
            player2World!.position = CGPoint(x: frame.width/2, y: 0)
            
            // Add divider
            let divider = SKSpriteNode(color: .white, size: CGSize(width: 2, height: frame.height))
            divider.position = CGPoint(x: frame.width/2, y: frame.midY)
            divider.zPosition = 100
            worldNode.addChild(divider)
            
            setupPlayer(node: player1World, isPlayerOne: true)
            setupPlayer(node: player2World!, isPlayerOne: false)
        } else {
            // Single player takes full screen
            player1World.position = CGPoint(x: 0, y: 0)
            setupPlayer(node: player1World, isPlayerOne: true)
        }
        
        // Reset scores
        player1Score = 0
        player2Score = 0
        
        // Schedule pipes
        let spawnPipes = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.spawnPipes()
            },
            SKAction.wait(forDuration: 2.0)
        ])
        
        let spawnPipesForever = SKAction.repeatForever(spawnPipes)
        worldNode.run(spawnPipesForever, withKey: "spawnPipes")
    }
    
    private func setupPlayer(node: SKNode, isPlayerOne: Bool) {
        // Create background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: isMultiplayer ? frame.width/4 : frame.midX, y: frame.midY)
        background.zPosition = -10
        background.size = isMultiplayer ? 
            CGSize(width: frame.width/2, height: frame.height) :
            self.size
        node.addChild(background)
        
        // Create ground
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.position = CGPoint(x: isMultiplayer ? frame.width/4 : frame.midX, y: 30)
        ground.zPosition = 10
        
        if isMultiplayer {
            ground.size = CGSize(width: frame.width/2, height: 60)
        } else {
            ground.size = CGSize(width: frame.width, height: 60)
        }
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = duckCategory
        node.addChild(ground)
        
        // Create duck
        let duck = SKSpriteNode(imageNamed: "duck1")
        duck.position = CGPoint(x: isMultiplayer ? frame.width/4 - 100 : 100, y: frame.midY)
        duck.zPosition = 20
        duck.scale(to: CGSize(width: 60, height: 60))
        
        duck.physicsBody = SKPhysicsBody(circleOfRadius: duck.size.width / 2.0)
        duck.physicsBody?.isDynamic = true
        duck.physicsBody?.allowsRotation = false
        duck.physicsBody?.categoryBitMask = duckCategory
        duck.physicsBody?.contactTestBitMask = obstacleCategory | groundCategory | scoreCategory
        duck.physicsBody?.collisionBitMask = groundCategory | obstacleCategory
        
        // Create animation
        let textureAtlas = SKTextureAtlas(named: "Duck")
        let frames = [
            textureAtlas.textureNamed("duck1"),
            textureAtlas.textureNamed("duck2")
        ]
        
        let animateAction = SKAction.animate(with: frames, timePerFrame: 0.1)
        let flapAction = SKAction.repeatForever(animateAction)
        duck.run(flapAction)
        
        if isPlayerOne {
            player1Duck = duck
            node.addChild(player1Duck)
            
            // Add score label for player 1
            player1ScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            player1ScoreLabel.fontSize = 60
            player1ScoreLabel.position = CGPoint(x: isMultiplayer ? frame.width/4 : frame.midX, y: frame.height - 100)
            player1ScoreLabel.text = "0"
            player1ScoreLabel.zPosition = 100
            node.addChild(player1ScoreLabel)
        } else {
            player2Duck = duck
            node.addChild(player2Duck!)
            
            // Add score label for player 2
            player2ScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            player2ScoreLabel.fontSize = 60
            player2ScoreLabel.position = CGPoint(x: frame.width/4, y: frame.height - 100)
            player2ScoreLabel.text = "0"
            player2ScoreLabel.zPosition = 100
            node.addChild(player2ScoreLabel!)
        }
    }
    
    // MARK: - Pipe Generation
    private func spawnPipes() {
        if gameState != .playing { return }
        
        let player1Pipes = createPipePair()
        player1Pipes.position = CGPoint(x: isMultiplayer ? frame.width/2 : frame.width, y: 0)
        player1World.addChild(player1Pipes)
        
        let distanceToMove = isMultiplayer ? frame.width/2 + 100 : frame.width + 100
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0, duration: pipeSpeed)
        let removePipes = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([movePipes, removePipes])
        player1Pipes.run(moveAndRemove)
        
        if isMultiplayer, let player2World = player2World {
            // Create a similar but different pipe setup for player 2
            let player2Pipes = createPipePair()
            player2Pipes.position = CGPoint(x: frame.width/2, y: 0)
            player2World.addChild(player2Pipes)
            player2Pipes.run(moveAndRemove.copy() as! SKAction)
        }
    }
    
    private func createPipePair() -> SKNode {
        let pipePair = SKNode()
        pipePair.zPosition = 1
        
        // Randomize pipe height
        let height = CGFloat.random(in: frame.height * 0.2...frame.height * 0.8)
        
        // Create top pipe
        let topPipe = SKSpriteNode(imageNamed: "pipe-down")
        topPipe.position = CGPoint(x: 0, y: height + verticalPipeGap/2)
        topPipe.zPosition = 0
        
        // Scale the pipe appropriately
        let pipeWidth = isMultiplayer ? frame.width/6 : frame.width/4
        topPipe.scale(to: CGSize(width: pipeWidth, height: 500))
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = obstacleCategory
        topPipe.physicsBody?.contactTestBitMask = duckCategory
        
        // Create bottom pipe
        let bottomPipe = SKSpriteNode(imageNamed: "pipe-up")
        bottomPipe.position = CGPoint(x: 0, y: height - verticalPipeGap/2)
        bottomPipe.zPosition = 0
        
        // Scale the pipe appropriately
        bottomPipe.scale(to: CGSize(width: pipeWidth, height: 500))
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = obstacleCategory
        bottomPipe.physicsBody?.contactTestBitMask = duckCategory
        
        // Create score node (invisible node between pipes)
        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: topPipe.size.width/2 + 20, y: frame.midY)
        let scoreNodeSize = CGSize(width: 5, height: frame.height)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNodeSize)
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = duckCategory
        
        pipePair.addChild(topPipe)
        pipePair.addChild(bottomPipe)
        pipePair.addChild(scoreNode)
        
        return pipePair
    }
    
    // MARK: - Game Over
    private func gameOver(forPlayerOne: Bool) {
        if gameState == .gameOver { return }
        
        if isMultiplayer {
            // In multiplayer, only end the game when both players have crashed
            if forPlayerOne {
                player1Duck.physicsBody?.isDynamic = false
                if player2Duck?.physicsBody?.isDynamic == false {
                    showGameOverScreen()
                }
            } else {
                player2Duck?.physicsBody?.isDynamic = false
                if player1Duck.physicsBody?.isDynamic == false {
                    showGameOverScreen()
                }
            }
        } else {
            // In single player, end immediately
            player1Duck.physicsBody?.isDynamic = false
            showGameOverScreen()
        }
    }
    
    private func showGameOverScreen() {
        gameState = .gameOver
        worldNode.removeAction(forKey: "spawnPipes")
        canRestart = true
        
        // Clear previous game over screen
        gameOverNode.removeAllChildren()
        gameOverNode.isHidden = false
        
        // Create semi-transparent background
        let overlay = SKSpriteNode(color: .black, size: self.size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.alpha = 0.7
        overlay.zPosition = 50
        gameOverNode.addChild(overlay)
        
        // Game Over text
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        gameOverLabel.zPosition = 51
        gameOverNode.addChild(gameOverLabel)
        
        // Score display
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        if isMultiplayer {
            scoreLabel.text = "Player 1: \(player1Score)    Player 2: \(player2Score)"
            
            // Determine winner text
            let winnerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            if player1Score > player2Score {
                winnerLabel.text = "Player 1 Wins!"
            } else if player2Score > player1Score {
                winnerLabel.text = "Player 2 Wins!"
            } else {
                winnerLabel.text = "It's a Tie!"
            }
            winnerLabel.fontSize = 36
            winnerLabel.fontColor = .yellow
            winnerLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
            winnerLabel.zPosition = 51
            gameOverNode.addChild(winnerLabel)
        } else {
            scoreLabel.text = "Score: \(player1Score)"
            updateHighScore()
            
            // High score
            let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            highScoreLabel.text = "Best: \(highScore)"
            highScoreLabel.fontSize = 24
            highScoreLabel.fontColor = .yellow
            highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
            highScoreLabel.zPosition = 51
            gameOverNode.addChild(highScoreLabel)
        }
        
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = 51
        gameOverNode.addChild(scoreLabel)
        
        // Play Again button
        let playAgainButton = createButton(text: "Play Again", position: CGPoint(x: frame.midX, y: frame.midY - 70))
        playAgainButton.name = "playAgainButton"
        playAgainButton.zPosition = 51
        gameOverNode.addChild(playAgainButton)
        
        // Main Menu button
        let mainMenuButton = createButton(text: "Main Menu", position: CGPoint(x: frame.midX, y: frame.midY - 140))
        mainMenuButton.name = "mainMenuButton" 
        mainMenuButton.zPosition = 51
        gameOverNode.addChild(mainMenuButton)
    }
    
    // MARK: - Score Management
    private func updateScore(forPlayerOne: Bool) {
        if forPlayerOne {
            player1Score += 1
            player1ScoreLabel.text = "\(player1Score)"
            
            // Add visual effect
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            player1ScoreLabel.run(sequence)
        } else if let player2ScoreLabel = player2ScoreLabel {
            player2Score += 1
            player2ScoreLabel.text = "\(player2Score)"
            
            // Add visual effect
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            player2ScoreLabel.run(sequence)
        }
    }
    
    private func updateHighScore() {
        if player1Score > highScore {
            highScore = player1Score
            saveHighScore()
        }
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "floppyDuckHighScore")
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "floppyDuckHighScore")
    }
    
    // MARK: - Game Reset
    private func resetGame() {
        player1Score = 0
        player2Score = 0
        worldNode.removeAllActions()
        worldNode.removeAllChildren()
        player2Duck = nil
        player2World = nil
        player2ScoreLabel = nil
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        switch gameState {
        case .mainMenu:
            handleMainMenuTouch(at: location)
        case .playing:
            handleGameplayTouch(at: location)
        case .gameOver:
            handleGameOverTouch(at: location)
        }
    }
    
    private func handleMainMenuTouch(at location: CGPoint) {
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "singlePlayerButton" || touchedNode.parent?.name == "singlePlayerButton" {
            startGame(multiplayer: false)
        } else if touchedNode.name == "multiplayerButton" || touchedNode.parent?.name == "multiplayerButton" {
            startGame(multiplayer: true)
        }
    }
    
    private func handleGameplayTouch(at location: CGPoint) {
        // Determine which half of the screen was tapped
        let isLeftHalfTapped = location.x < frame.width/2
        
        if isMultiplayer {
            // In multiplayer, left side controls player 1, right side controls player 2
            if isLeftHalfTapped {
                flapDuck(player1Duck)
            } else if let player2Duck = player2Duck {
                flapDuck(player2Duck)
            }
        } else {
            // In single player, the whole screen controls the duck
            flapDuck(player1Duck)
        }
    }
    
    private func handleGameOverTouch(at location: CGPoint) {
        if !canRestart { return }
        
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "playAgainButton" || touchedNode.parent?.name == "playAgainButton" {
            startGame(multiplayer: isMultiplayer)
        } else if touchedNode.name == "mainMenuButton" || touchedNode.parent?.name == "mainMenuButton" {
            showMainMenu()
        }
    }
    
    private func flapDuck(_ duck: SKSpriteNode) {
        duck.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        duck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        run(duckFlapSoundAction)
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        // Determine which bodies contacted
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Duck hit an obstacle or ground
        if contactMask == duckCategory | obstacleCategory || contactMask == duckCategory | groundCategory {
            // Determine which duck hit the obstacle
            let isDuckA = contact.bodyA.categoryBitMask == duckCategory
            let duckBody = isDuckA ? contact.bodyA : contact.bodyB
            
            // Check which player's duck it was
            let isPlayerOne = duckBody.node == player1Duck
            gameOver(forPlayerOne: isPlayerOne)
        }
        
        // Duck passed through score node
        if contactMask == duckCategory | scoreCategory {
            // Determine which duck passed the score node
            let isDuckA = contact.bodyA.categoryBitMask == duckCategory
            let duckBody = isDuckA ? contact.bodyA : contact.bodyB
            
            // Check which player's duck it was
            let isPlayerOne = duckBody.node == player1Duck
            updateScore(forPlayerOne: isPlayerOne)
        }
    }
} 