//
//  GameScene.swift
//  FloppyDuck
//
//  Created based on FlappyBird by Nate Murray
//

import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, GKMatchDelegate {
    // MARK: - Game Constants
    let verticalPipeGap = 150.0
    
    // MARK: - Sprites and Nodes
    var duck: SKSpriteNode!
    var skyColor: SKColor!
    var pipeTextureUp: SKTexture!
    var pipeTextureDown: SKTexture!
    var movePipesAndRemove: SKAction!
    var moving: SKNode!
    var pipes: SKNode!
    var scoreLabelNode: SKLabelNode!
    var highScoreLabelNode: SKLabelNode!
    var matchmakingButton: SKSpriteNode!
    var leaderboardButton: SKSpriteNode!
    var profileButton: SKSpriteNode!
    var muteButton: SKSpriteNode!
    var groundTexture: SKTexture!
    
    // MARK: - Game State
    var canRestart = Bool()
    var score = 0
    var highScore = 0
    var isMultiplayerMatch = false
    var opponent: SKSpriteNode?
    var opponentScore = 0
    var opponentScoreLabel: SKLabelNode?
    var gameState: GameState = .mainMenu
    
    // MARK: - Player Statistics
    var totalFlights = 0
    var totalDistance = 0.0
    var totalFlaps = 0
    var currentDistance = 0.0
    var currentFlaps = 0
    
    // MARK: - Multiplayer
    var match: GKMatch?
    
    // MARK: - Categories for Physics
    let duckCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    // MARK: - Game States
    enum GameState {
        case mainMenu
        case playing
        case gameOver
        case matchmaking
        case profile
        case leaderboard
    }
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupGame()
        showMainMenu()
    }
    
    func setupGame() {
        canRestart = true
        
        // Load saved statistics
        loadStats()
        
        // Preload sounds
        SoundManager.shared.preloadSounds()
        
        // Start background music
        SoundManager.shared.playBackgroundMusic(filename: "background_music", type: "mp3")
        
        // Setup physics
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.contactDelegate = self
        
        // Setup background color
        skyColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        moving = SKNode()
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)
        
        setupGround()
        setupSky()
        setupPipes()
        setupDuck()
        setupScoreLabels()
        setupMuteButton()
    }
    
    func setupGround() {
        let groundTexture = SKTexture(imageNamed: "land")
        groundTexture.filteringMode = .nearest
        
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.02 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / (groundTexture.size().width * 2)) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // Create the ground physics body for collision
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
    }
    
    func setupSky() {
        let skyTexture = SKTexture(imageNamed: "sky")
        skyTexture.filteringMode = .nearest
        
        let moveSkySprite = SKAction.moveBy(x: -skyTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.1 * skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveBy(x: skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / (skyTexture.size().width * 2)) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            sprite.run(moveSkySpritesForever)
            moving.addChild(sprite)
        }
    }
    
    func setupPipes() {
        pipeTextureUp = SKTexture(imageNamed: "PipeUp")
        pipeTextureUp.filteringMode = .nearest
        pipeTextureDown = SKTexture(imageNamed: "PipeDown")
        pipeTextureDown.filteringMode = .nearest
        
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeTextureUp.size().width)
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
    }
    
    func setupDuck() {
        let duckTexture1 = SKTexture(imageNamed: "duck-01")
        duckTexture1.filteringMode = .nearest
        let duckTexture2 = SKTexture(imageNamed: "duck-02")
        duckTexture2.filteringMode = .nearest
        
        let anim = SKAction.animate(with: [duckTexture1, duckTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        
        duck = SKSpriteNode(texture: duckTexture1)
        duck.setScale(2.0)
        duck.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        duck.run(flap)
        
        duck.physicsBody = SKPhysicsBody(circleOfRadius: duck.size.height / 2.0)
        duck.physicsBody?.isDynamic = true
        duck.physicsBody?.allowsRotation = false
        
        duck.physicsBody?.categoryBitMask = duckCategory
        duck.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        duck.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(duck)
    }
    
    func setupScoreLabels() {
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        scoreLabelNode.position = CGPoint(x: self.frame.midX, y: 3 * self.frame.size.height / 4)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
        // High score label
        highScoreLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        highScoreLabelNode.position = CGPoint(x: self.frame.midX, y: 3 * self.frame.size.height / 4 - 30)
        highScoreLabelNode.zPosition = 100
        highScoreLabelNode.fontSize = 15
        highScoreLabelNode.text = "Best: \(highScore)"
        self.addChild(highScoreLabelNode)
    }
    
    func setupMuteButton() {
        // Create mute button in the top left corner
        muteButton = SKSpriteNode(color: .darkGray, size: CGSize(width: 40, height: 40))
        muteButton.position = CGPoint(x: self.frame.minX + 30, y: self.frame.maxY - 30)
        muteButton.zPosition = 100
        muteButton.name = "muteButton"
        
        // Add image or text based on current mute state
        updateMuteButtonAppearance()
        
        self.addChild(muteButton)
    }
    
    func updateMuteButtonAppearance() {
        // Clear any existing child nodes
        muteButton.removeAllChildren()
        
        // Add appropriate label based on mute state
        let muteLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        muteLabel.text = SoundManager.shared.isMuted ? "🔇" : "🔊"
        muteLabel.fontSize = 20
        muteLabel.position = CGPoint(x: 0, y: -7)
        muteLabel.name = "muteLabel"
        muteButton.addChild(muteLabel)
    }
    
    func showMainMenu() {
        gameState = .mainMenu
        
        // Create title
        let titleLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        titleLabel.text = "Floppy Duck"
        titleLabel.fontSize = 36
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        titleLabel.name = "title"
        self.addChild(titleLabel)
        
        // Create start button
        let startButton = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        startButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        startButton.name = "startButton"
        self.addChild(startButton)
        
        let startLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        startLabel.text = "Start Game"
        startLabel.fontSize = 24
        startLabel.position = CGPoint(x: 0, y: -7)
        startLabel.name = "startLabel"
        startButton.addChild(startLabel)
        
        // Create multiplayer button
        matchmakingButton = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 50))
        matchmakingButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 60)
        matchmakingButton.name = "matchmakingButton"
        self.addChild(matchmakingButton)
        
        let matchmakingLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        matchmakingLabel.text = "Multiplayer"
        matchmakingLabel.fontSize = 24
        matchmakingLabel.position = CGPoint(x: 0, y: -7)
        matchmakingLabel.name = "matchmakingLabel"
        matchmakingButton.addChild(matchmakingLabel)
        
        // Create leaderboard button
        leaderboardButton = SKSpriteNode(color: .orange, size: CGSize(width: 200, height: 50))
        leaderboardButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 120)
        leaderboardButton.name = "leaderboardButton"
        self.addChild(leaderboardButton)
        
        let leaderboardLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        leaderboardLabel.text = "Leaderboard"
        leaderboardLabel.fontSize = 24
        leaderboardLabel.position = CGPoint(x: 0, y: -7)
        leaderboardLabel.name = "leaderboardLabel"
        leaderboardButton.addChild(leaderboardLabel)
        
        // Create profile button
        profileButton = SKSpriteNode(color: .purple, size: CGSize(width: 200, height: 50))
        profileButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 180)
        profileButton.name = "profileButton"
        self.addChild(profileButton)
        
        let profileLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        profileLabel.text = "Profile Stats"
        profileLabel.fontSize = 24
        profileLabel.position = CGPoint(x: 0, y: -7)
        profileLabel.name = "profileLabel"
        profileButton.addChild(profileLabel)
        
        // Add achievements button
        let achievementsButton = SKSpriteNode(color: .brown, size: CGSize(width: 200, height: 50))
        achievementsButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 240)
        achievementsButton.name = "achievementsButton"
        self.addChild(achievementsButton)
        
        let achievementsLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        achievementsLabel.text = "Achievements"
        achievementsLabel.fontSize = 24
        achievementsLabel.position = CGPoint(x: 0, y: -7)
        achievementsLabel.name = "achievementsLabel"
        achievementsButton.addChild(achievementsLabel)
        
        // Stop the game
        moving.speed = 0
    }
    
    func startGame() {
        // Remove all menu nodes
        self.enumerateChildNodes(withName: "title") { node, _ in
            node.removeFromParent()
        }
        self.enumerateChildNodes(withName: "startButton") { node, _ in
            node.removeFromParent()
        }
        self.enumerateChildNodes(withName: "leaderboardButton") { node, _ in
            node.removeFromParent()
        }
        self.enumerateChildNodes(withName: "matchmakingButton") { node, _ in
            node.removeFromParent()
        }
        self.enumerateChildNodes(withName: "profileButton") { node, _ in
            node.removeFromParent()
        }
        
        gameState = .playing
        
        // Start the pipes spawning
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: TimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever, withKey: "spawnPipes")
        
        // Reset stats for this play session
        currentDistance = 0.0
        currentFlaps = 0
        totalFlights += 1
        
        // Report first flight achievement when game starts
        AchievementManager.shared.reportFirstFlight()
        
        // Start the game
        moving.speed = 1
        resetScene()
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: self.frame.size.width + pipeTextureUp.size().width * 2, y: 0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.size.height / 4)
        let y = Double(arc4random_uniform(height) + height)
        
        let pipeDown = SKSpriteNode(texture: pipeTextureDown)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPoint(x: 0.0, y: y + Double(pipeDown.size.height) + verticalPipeGap)
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = duckCategory
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeTextureUp)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPoint(x: 0.0, y: y)
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
        pipeUp.physicsBody?.isDynamic = false
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = duckCategory
        pipePair.addChild(pipeUp)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: pipeDown.size.width + duck.size.width / 2, y: self.frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.frame.size.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = duckCategory
        pipePair.addChild(contactNode)
        
        pipePair.run(movePipesAndRemove)
        pipes.addChild(pipePair)
    }
    
    func resetScene() {
        // Move duck to original position and reset velocity
        duck.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        duck.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        duck.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        duck.speed = 1.0
        duck.zRotation = 0.0
        
        // Remove all existing pipes
        pipes.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Restart animation
        moving.speed = 1
    }
    
    // MARK: - Player Statistics
    func loadStats() {
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
        totalFlights = defaults.integer(forKey: "totalFlights")
        totalDistance = defaults.double(forKey: "totalDistance")
        totalFlaps = defaults.integer(forKey: "totalFlaps")
    }
    
    func saveStats() {
        let defaults = UserDefaults.standard
        
        // Update high score if needed
        if score > highScore {
            highScore = score
            defaults.set(highScore, forKey: "highScore")
            
            // Submit score to Game Center
            if let gameViewController = self.view?.window?.rootViewController as? GameViewController {
                gameViewController.submitScore(score: highScore)
            }
        }
        
        // Update lifetime stats
        totalDistance += currentDistance
        totalFlaps += currentFlaps
        
        defaults.set(totalFlights, forKey: "totalFlights")
        defaults.set(totalDistance, forKey: "totalDistance")
        defaults.set(totalFlaps, forKey: "totalFlaps")
        
        // Update achievements
        updateAchievements()
    }
    
    func updateAchievements() {
        if GKLocalPlayer.local.isAuthenticated {
            // Report first flight
            AchievementManager.shared.reportFirstFlight()
            
            // Report distance flown
            AchievementManager.shared.reportDistanceFlown(totalDistance)
            
            // Report total flaps
            AchievementManager.shared.reportFlaps(totalFlaps)
            
            // Report high score
            AchievementManager.shared.reportHighScore(highScore)
        }
    }
    
    // MARK: - Show Profile Screen
    func showProfile() {
        gameState = .profile
        
        // Remove any existing profile screen
        self.enumerateChildNodes(withName: "profileNode") { node, _ in
            node.removeFromParent()
        }
        
        // Create the profile container
        let profileNode = SKNode()
        profileNode.name = "profileNode"
        self.addChild(profileNode)
        
        // Background panel
        let panel = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8), size: CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.7))
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        profileNode.addChild(panel)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        titleLabel.text = "Player Stats"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + panel.size.height/2 - 40)
        profileNode.addChild(titleLabel)
        
        // Stats labels
        let statsLabels = [
            "High Score: \(highScore)",
            "Total Flights: \(totalFlights)",
            "Distance Flown: \(Int(totalDistance)) m",
            "Times Flapped: \(totalFlaps)",
            "Avg. Distance Per Flight: \(totalFlights > 0 ? Int(totalDistance/Double(totalFlights)) : 0) m",
            "Avg. Flaps Per Flight: \(totalFlights > 0 ? Int(Double(totalFlaps)/Double(totalFlights)) : 0)"
        ]
        
        for (index, text) in statsLabels.enumerated() {
            let label = SKLabelNode(fontNamed: "MarkerFelt-Wide")
            label.text = text
            label.fontSize = 22
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: self.frame.midX - panel.size.width/2 + 40, y: self.frame.midY + 80 - CGFloat(index * 40))
            profileNode.addChild(label)
        }
        
        // Back button
        let backButton = SKSpriteNode(color: .red, size: CGSize(width: 150, height: 50))
        backButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - panel.size.height/2 + 40)
        backButton.name = "backButton"
        profileNode.addChild(backButton)
        
        let backLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        backLabel.text = "Back"
        backLabel.fontSize = 24
        backLabel.position = CGPoint(x: 0, y: -7)
        backButton.addChild(backLabel)
    }
    
    // MARK: - Show Leaderboard
    func showLeaderboard() {
        gameState = .leaderboard
        
        // First try to use Game Center if available
        if GKLocalPlayer.local.isAuthenticated {
            if let gameViewController = self.view?.window?.rootViewController as? GameViewController {
                gameViewController.showLeaderboard()
                return
            }
        }
        
        // Fallback to the local leaderboard UI if Game Center is not available
        
        // Remove any existing leaderboard screen
        self.enumerateChildNodes(withName: "leaderboardNode") { node, _ in
            node.removeFromParent()
        }
        
        // Create the leaderboard container
        let leaderboardNode = SKNode()
        leaderboardNode.name = "leaderboardNode"
        self.addChild(leaderboardNode)
        
        // Background panel
        let panel = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8), size: CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.7))
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        leaderboardNode.addChild(panel)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        titleLabel.text = "Leaderboard"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + panel.size.height/2 - 40)
        leaderboardNode.addChild(titleLabel)
        
        // Placeholder text
        let placeholderLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        placeholderLabel.text = "Connect to Game Center to view leaderboards"
        placeholderLabel.fontSize = 18
        placeholderLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        leaderboardNode.addChild(placeholderLabel)
        
        // Back button
        let backButton = SKSpriteNode(color: .red, size: CGSize(width: 150, height: 50))
        backButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - panel.size.height/2 + 40)
        backButton.name = "backButton"
        leaderboardNode.addChild(backButton)
        
        let backLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        backLabel.text = "Back"
        backLabel.fontSize = 24
        backLabel.position = CGPoint(x: 0, y: -7)
        backButton.addChild(backLabel)
    }
    
    // MARK: - Head to Head Matchmaking
    func showMatchmaking() {
        gameState = .matchmaking
        
        // Try to start matchmaking with Game Center
        if GKLocalPlayer.local.isAuthenticated {
            if let gameViewController = self.view?.window?.rootViewController as? GameViewController {
                gameViewController.startMatchmaking()
                return
            }
        }
        
        // Fallback UI if Game Center is not available
        
        // Remove any existing matchmaking screen
        self.enumerateChildNodes(withName: "matchmakingNode") { node, _ in
            node.removeFromParent()
        }
        
        // Create the matchmaking container
        let matchmakingNode = SKNode()
        matchmakingNode.name = "matchmakingNode"
        self.addChild(matchmakingNode)
        
        // Background panel
        let panel = SKSpriteNode(color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8), size: CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.7))
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        matchmakingNode.addChild(panel)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        titleLabel.text = "Multiplayer"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + panel.size.height/2 - 40)
        matchmakingNode.addChild(titleLabel)
        
        // Placeholder text
        let placeholderLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        placeholderLabel.text = "Connect to Game Center for multiplayer"
        placeholderLabel.fontSize = 18
        placeholderLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        matchmakingNode.addChild(placeholderLabel)
        
        // Back button
        let backButton = SKSpriteNode(color: .red, size: CGSize(width: 150, height: 50))
        backButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - panel.size.height/2 + 40)
        backButton.name = "backButton"
        matchmakingNode.addChild(backButton)
        
        let backLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        backLabel.text = "Back"
        backLabel.fontSize = 24
        backLabel.position = CGPoint(x: 0, y: -7)
        backButton.addChild(backLabel)
    }
    
    // MARK: - GKMatchDelegate Methods
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Handle data from opponent
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                // Handle opponent position update
                if let positionY = dict["positionY"] as? CGFloat {
                    DispatchQueue.main.async {
                        self.opponent?.position.y = positionY
                    }
                }
                
                // Handle opponent score update
                if let score = dict["score"] as? Int {
                    DispatchQueue.main.async {
                        self.opponentScore = score
                        self.opponentScoreLabel?.text = String(score)
                    }
                }
                
                // Handle opponent rotation
                if let rotation = dict["rotation"] as? CGFloat {
                    DispatchQueue.main.async {
                        self.opponent?.zRotation = rotation
                    }
                }
            }
        } catch {
            print("Error parsing opponent data: \(error)")
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            // Check if mute button was tapped (regardless of game state)
            if let node = self.atPoint(location) as? SKNode {
                if node.name == "muteButton" || node.parent?.name == "muteButton" {
                    _ = SoundManager.shared.toggleMute()
                    updateMuteButtonAppearance()
                    return
                }
            }
            
            switch gameState {
            case .mainMenu:
                // Check if buttons were tapped
                if let node = self.atPoint(location) as? SKNode {
                    if node.name == "startButton" || node.parent?.name == "startButton" {
                        startGame()
                    } else if node.name == "leaderboardButton" || node.parent?.name == "leaderboardButton" {
                        showLeaderboard()
                    } else if node.name == "matchmakingButton" || node.parent?.name == "matchmakingButton" {
                        showMatchmaking()
                    } else if node.name == "profileButton" || node.parent?.name == "profileButton" {
                        showProfile()
                    } else if node.name == "achievementsButton" || node.parent?.name == "achievementsButton" {
                        showAchievements()
                    }
                }
            case .playing:
                if moving.speed > 0 {
                    duck.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    duck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
                    
                    // Play flap/quack sound
                    SoundManager.shared.playSound(named: "flap")
                    SoundManager.shared.playSound(named: "quack")
                    
                    // Update flap counter
                    currentFlaps += 1
                }
            case .gameOver:
                if canRestart {
                    if let node = self.atPoint(location) as? SKNode {
                        if node.name == "playAgainButton" || node.parent?.name == "playAgainButton" {
                            // Remove game over panel
                            self.enumerateChildNodes(withName: "gameOverPanel") { node, _ in
                                node.removeFromParent()
                            }
                            startGame()
                        } else if node.name == "mainMenuButton" || node.parent?.name == "mainMenuButton" {
                            // Remove game over panel
                            self.enumerateChildNodes(withName: "gameOverPanel") { node, _ in
                                node.removeFromParent()
                            }
                            showMainMenu()
                        }
                    }
                }
            case .profile, .leaderboard, .matchmaking:
                // Check for back button
                if let node = self.atPoint(location) as? SKNode {
                    if node.name == "backButton" || node.parent?.name == "backButton" {
                        self.enumerateChildNodes(withName: "profileNode") { node, _ in
                            node.removeFromParent()
                        }
                        self.enumerateChildNodes(withName: "leaderboardNode") { node, _ in
                            node.removeFromParent()
                        }
                        self.enumerateChildNodes(withName: "matchmakingNode") { node, _ in
                            node.removeFromParent()
                        }
                        showMainMenu()
                    }
                }
            }
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if gameState == .playing && moving.speed > 0 {
            // Rotate the duck based on velocity
            let value = duck.physicsBody!.velocity.dy * (duck.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001)
            duck.zRotation = min(max(-1, value), 0.5)
            
            // Update distance traveled (meters)
            currentDistance += 0.1
            
            // Send updates to opponent in multiplayer
            if isMultiplayerMatch {
                sendUpdateToOpponent()
            }
        }
    }
    
    // MARK: - Contact detection
    func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed > 0 {
            if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                // Duck has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
                
                // Play score sound
                SoundManager.shared.playSound(named: "score")
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: TimeInterval(0.1)), SKAction.scale(to: 1.0, duration: TimeInterval(0.1))]))
            } else {
                // Duck hit something - game over
                moving.speed = 0
                gameState = .gameOver
                
                // Play crash sound
                SoundManager.shared.playSound(named: "crash")
                
                duck.physicsBody?.collisionBitMask = worldCategory
                duck.run(SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(duck.position.y) * 0.01, duration: 1), completion: { self.duck.speed = 0 })
                
                // Flash background if contact is detected
                self.removeAction(forKey: "flash")
                self.run(SKAction.sequence([
                    SKAction.repeat(SKAction.sequence([
                        SKAction.run({
                            self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                        }),
                        SKAction.wait(forDuration: TimeInterval(0.05)),
                        SKAction.run({
                            self.backgroundColor = self.skyColor
                        }),
                        SKAction.wait(forDuration: TimeInterval(0.05))
                    ]), count: 4),
                    SKAction.run({
                        self.canRestart = true
                        self.saveStats()  // Save stats when game ends
                        self.showGameOverMenu()
                    })
                ]), withKey: "flash")
            }
        }
    }
    
    // Add a game over menu with buttons
    func showGameOverMenu() {
        // Create game over panel
        let gameOverPanel = SKSpriteNode(color: SKColor(red: 0, green: 0, blue: 0, alpha: 0.7), size: CGSize(width: 320, height: 280))
        gameOverPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        gameOverPanel.zPosition = 90
        gameOverPanel.name = "gameOverPanel"
        self.addChild(gameOverPanel)
        
        // Game Over text
        let gameOverLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: 70)
        gameOverLabel.name = "gameOverLabel"
        gameOverPanel.addChild(gameOverLabel)
        
        // Score text
        let scoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: 20)
        scoreLabel.name = "finalScoreLabel"
        gameOverPanel.addChild(scoreLabel)
        
        // Best score
        let bestScoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        bestScoreLabel.text = "Best: \(highScore)"
        bestScoreLabel.fontSize = 24
        bestScoreLabel.fontColor = .white
        bestScoreLabel.position = CGPoint(x: 0, y: -20)
        bestScoreLabel.name = "bestScoreLabel"
        gameOverPanel.addChild(bestScoreLabel)
        
        // Play Again button
        let playAgainButton = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        playAgainButton.position = CGPoint(x: 0, y: -70)
        playAgainButton.name = "playAgainButton"
        gameOverPanel.addChild(playAgainButton)
        
        let playAgainLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        playAgainLabel.text = "Play Again"
        playAgainLabel.fontSize = 24
        playAgainLabel.position = CGPoint(x: 0, y: -7)
        playAgainLabel.name = "playAgainLabel"
        playAgainButton.addChild(playAgainLabel)
        
        // Main Menu button
        let mainMenuButton = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 50))
        mainMenuButton.position = CGPoint(x: 0, y: -130)
        mainMenuButton.name = "mainMenuButton"
        gameOverPanel.addChild(mainMenuButton)
        
        let mainMenuLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        mainMenuLabel.text = "Main Menu"
        mainMenuLabel.fontSize = 24
        mainMenuLabel.position = CGPoint(x: 0, y: -7)
        mainMenuLabel.name = "mainMenuLabel"
        mainMenuButton.addChild(mainMenuLabel)
        
        // Add a zoom in animation for the panel
        gameOverPanel.setScale(0.1)
        gameOverPanel.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    // Add a method to show achievements
    func showAchievements() {
        if let gameViewController = self.view?.window?.rootViewController as? GameViewController {
            gameViewController.showAchievements()
        }
    }
    
    // Add a method to start a multiplayer game
    func startMultiplayerGame() {
        // Clean up UI
        self.enumerateChildNodes(withName: "matchmakingNode") { node, _ in
            node.removeFromParent()
        }
        
        // Set up the multiplayer game
        isMultiplayerMatch = true
        
        // Set up opponent display if it doesn't exist
        if opponent == nil {
            // Create opponent duck
            let duckTexture1 = SKTexture(imageNamed: "duck-01")
            duckTexture1.filteringMode = .nearest
            let duckTexture2 = SKTexture(imageNamed: "duck-02")
            duckTexture2.filteringMode = .nearest
            
            let anim = SKAction.animate(with: [duckTexture1, duckTexture2], timePerFrame: 0.2)
            let flap = SKAction.repeatForever(anim)
            
            opponent = SKSpriteNode(texture: duckTexture1)
            opponent?.setScale(2.0)
            opponent?.position = CGPoint(x: self.frame.size.width * 0.65, y: self.frame.size.height * 0.6)
            opponent?.run(flap)
            opponent?.alpha = 0.5 // Semi-transparent to distinguish from player
            opponent?.zPosition = 10
            
            // Add opponent score label
            opponentScoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
            opponentScoreLabel?.position = CGPoint(x: self.frame.midX + 50, y: 3 * self.frame.size.height / 4)
            opponentScoreLabel?.zPosition = 100
            opponentScoreLabel?.text = "0"
            opponentScoreLabel?.fontColor = .red
            
            if let opponent = opponent, let opponentScoreLabel = opponentScoreLabel {
                self.addChild(opponent)
                self.addChild(opponentScoreLabel)
            }
        }
        
        // Start the game
        startGame()
    }
    
    // Add a method to send update to opponent
    func sendUpdateToOpponent() {
        guard isMultiplayerMatch, let match = match, match.expectedPlayerCount == 0 else { return }
        
        // Create data to send
        let updateDict: [String: Any] = [
            "positionY": duck.position.y,
            "score": score,
            "rotation": duck.zRotation
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: updateDict, options: [])
            
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Error sending update to opponent: \(error)")
        }
    }
} 