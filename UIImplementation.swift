import UIKit
import SpriteKit
import GameKit

/// This file demonstrates the UI improvements and leaderboard implementation
/// completed during Week 2. The actual implementation has been integrated into
/// the game's main view controllers.

// MARK: - Modern UI Components

/// Base class for all game UI elements with common styling
class FloppyUIElement: SKNode {
    // Standard colors from the theme
    static let primaryColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
    static let secondaryColor = UIColor(red: 66/255, green: 135/255, blue: 245/255, alpha: 1.0)
    static let backgroundDark = UIColor(red: 41/255, green: 50/255, blue: 65/255, alpha: 1.0)
    static let backgroundLight = UIColor(red: 113/255, green: 197/255, blue: 207/255, alpha: 1.0)
    
    // Animation constants
    static let buttonPressScale: CGFloat = 0.95
    static let buttonPressAnimationDuration: TimeInterval = 0.1
    static let fadeAnimationDuration: TimeInterval = 0.25
    
    // Haptic feedback
    func performHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Standard fade in animation
    func fadeIn(duration: TimeInterval = fadeAnimationDuration) {
        self.alpha = 0.0
        self.run(SKAction.fadeIn(withDuration: duration))
    }
    
    // Standard fade out animation
    func fadeOut(duration: TimeInterval = fadeAnimationDuration, completion: @escaping () -> Void = {}) {
        self.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: duration),
            SKAction.run(completion)
        ]))
    }
}

/// Modern button with animations and sound effects
class FloppyButton: FloppyUIElement {
    // Visual components
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let icon: SKSpriteNode?
    
    // Button state
    private(set) var isEnabled: Bool = true
    var onTap: (() -> Void)?
    
    // Button appearance
    private let cornerRadius: CGFloat = 20.0
    private let disabledAlpha: CGFloat = 0.5
    
    init(text: String, size: CGSize, color: UIColor = primaryColor, textColor: UIColor = .white, iconName: String? = nil) {
        // Create background rounded rectangle
        background = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        background.fillColor = color
        background.strokeColor = .clear
        
        // Create text label
        label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24.0
        label.fontColor = textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        // Create optional icon
        if let iconName = iconName {
            icon = SKSpriteNode(imageNamed: iconName)
            icon?.size = CGSize(width: 32, height: 32)
        } else {
            icon = nil
        }
        
        super.init()
        
        // Add components to button
        addChild(background)
        addChild(label)
        
        if let icon = icon {
            addChild(icon)
            icon.position = CGPoint(x: -size.width/2 + 40, y: 0)
            label.position = CGPoint(x: 10, y: 0) // Offset text when icon is present
        }
        
        // Set up touch handling
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Enable/disable button
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : disabledAlpha
        isUserInteractionEnabled = enabled
    }
    
    // Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        
        // Play press animation
        let scaleDown = SKAction.scale(to: FloppyUIElement.buttonPressScale, duration: FloppyUIElement.buttonPressAnimationDuration)
        run(scaleDown)
        
        // Play sound
        SoundManager.shared.playSound(filename: "button_press", type: "wav")
        
        // Haptic feedback
        performHapticFeedback()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        
        // Play release animation
        let scaleUp = SKAction.scale(to: 1.0, duration: FloppyUIElement.buttonPressAnimationDuration)
        
        run(scaleUp) {
            // Call tap handler
            self.onTap?()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        
        // Reset scale
        let scaleUp = SKAction.scale(to: 1.0, duration: FloppyUIElement.buttonPressAnimationDuration)
        run(scaleUp)
    }
}

/// Panel for displaying scores, achievements, etc.
class FloppyPanel: FloppyUIElement {
    // Panel components
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode
    
    init(title: String, size: CGSize) {
        // Create background rounded rectangle
        background = SKShapeNode(rectOf: size, cornerRadius: 20.0)
        background.fillColor = FloppyUIElement.backgroundDark.withAlphaComponent(0.9)
        background.strokeColor = FloppyUIElement.primaryColor
        background.lineWidth = 2.0
        
        // Create title label
        titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 28.0
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: size.height/2 - 40)
        
        super.init()
        
        // Add components to panel
        addChild(background)
        addChild(titleLabel)
        
        // Add drop shadow
        addShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Add a nice shadow effect
    private func addShadow() {
        background.shadowColor = UIColor.black.withAlphaComponent(0.5)
        background.shadowOffset = CGSize(width: 0, height: 5)
        background.shadowRadius = 10.0
    }
    
    // Add a decorative element like a medal or icon
    func addDecoration(imageName: String, position: CGPoint) {
        let decoration = SKSpriteNode(imageNamed: imageName)
        decoration.position = position
        addChild(decoration)
    }
}

// MARK: - Leaderboard Implementation

/// Handles leaderboard display and integration
class LeaderboardManager {
    // Singleton pattern
    static let shared = LeaderboardManager()
    
    // Leaderboard IDs
    private let highScoreLeaderboardID = "com.floppyduck.highscore"
    private let flapsLeaderboardID = "com.floppyduck.flaps"
    private let flightsLeaderboardID = "com.floppyduck.flights"
    private let distanceLeaderboardID = "com.floppyduck.distance"
    
    // Stores cached leaderboard entries
    private var cachedScores: [String: [GKLeaderboard.Entry]] = [:]
    
    // MARK: - Score Submission
    
    /// Submit a new high score
    func submitScore(_ score: Int, leaderboardID: String = "com.floppyduck.highscore") {
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                               leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
                print("Successfully submitted score \(score) to leaderboard \(leaderboardID)")
                // Invalidate cache for this leaderboard
                self.cachedScores[leaderboardID] = nil
            }
        }
    }
    
    /// Submit all stats at once
    func submitAllStats(score: Int, flaps: Int, flights: Int, distance: Int) {
        submitScore(score, leaderboardID: highScoreLeaderboardID)
        submitScore(flaps, leaderboardID: flapsLeaderboardID)
        submitScore(flights, leaderboardID: flightsLeaderboardID)
        submitScore(distance, leaderboardID: distanceLeaderboardID)
    }
    
    // MARK: - Leaderboard Retrieval
    
    /// Load entries for a specific leaderboard
    func loadLeaderboard(id: String, scope: GKLeaderboard.PlayerScope = .global, 
                        timeScope: GKLeaderboard.TimeScope = .allTime, 
                        range: NSRange = NSRange(location: 1, length: 10),
                        completion: @escaping ([GKLeaderboard.Entry]?, Error?) -> Void) {
        
        // Check if we have cached results
        if let cachedEntries = cachedScores[id] {
            completion(cachedEntries, nil)
            return
        }
        
        // Load entries from Game Center
        GKLeaderboard.loadLeaderboards(IDs: [id]) { [weak self] leaderboards, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let leaderboard = leaderboards?.first else {
                completion(nil, NSError(domain: "LeaderboardManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"]))
                return
            }
            
            // Load entries
            leaderboard.loadEntries(for: scope, timeScope: timeScope, range: range) { entries, localPlayerEntry, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var allEntries = entries ?? []
                
                // Add local player entry if it exists and is not already in the list
                if let localEntry = localPlayerEntry,
                   !allEntries.contains(where: { $0.player.gamePlayerID == localEntry.player.gamePlayerID }) {
                    allEntries.append(localEntry)
                }
                
                // Sort entries by rank
                allEntries.sort { $0.rank < $1.rank }
                
                // Cache results
                self.cachedScores[id] = allEntries
                
                // Return results
                completion(allEntries, nil)
            }
        }
    }
    
    // MARK: - UI Creation
    
    /// Create a leaderboard panel for in-game display
    func createLeaderboardPanel(size: CGSize, leaderboardID: String = "com.floppyduck.highscore") -> FloppyPanel {
        let panel = FloppyPanel(title: "Leaderboard", size: size)
        
        // Add loading indicator
        let loading = SKLabelNode(text: "Loading leaderboard...")
        loading.fontName = "AvenirNext-Medium"
        loading.fontSize = 20.0
        loading.fontColor = .white
        loading.position = CGPoint(x: 0, y: 0)
        panel.addChild(loading)
        
        // Load leaderboard data
        loadLeaderboard(id: leaderboardID) { entries, error in
            // Remove loading indicator
            loading.removeFromParent()
            
            if let error = error {
                // Show error message
                let errorLabel = SKLabelNode(text: "Couldn't load leaderboard")
                errorLabel.fontName = "AvenirNext-Medium"
                errorLabel.fontSize = 20.0
                errorLabel.fontColor = .white
                errorLabel.position = CGPoint(x: 0, y: 0)
                panel.addChild(errorLabel)
                
                print("Leaderboard error: \(error.localizedDescription)")
                return
            }
            
            guard let entries = entries else { return }
            
            // Display top scores
            for (index, entry) in entries.prefix(8).enumerated() {
                let yPos = size.height/2 - 100 - CGFloat(index * 50)
                
                // Rank label
                let rankLabel = SKLabelNode(text: "\(entry.rank)")
                rankLabel.fontName = "AvenirNext-Bold"
                rankLabel.fontSize = 20.0
                rankLabel.fontColor = .white
                rankLabel.horizontalAlignmentMode = .right
                rankLabel.position = CGPoint(x: -size.width/2 + 60, y: yPos)
                panel.addChild(rankLabel)
                
                // Player name label
                let nameLabel = SKLabelNode(text: entry.player.displayName)
                nameLabel.fontName = "AvenirNext-Medium"
                nameLabel.fontSize = 20.0
                nameLabel.fontColor = .white
                nameLabel.horizontalAlignmentMode = .left
                nameLabel.position = CGPoint(x: -size.width/2 + 80, y: yPos)
                panel.addChild(nameLabel)
                
                // Score label
                let scoreLabel = SKLabelNode(text: "\(entry.score)")
                scoreLabel.fontName = "AvenirNext-Bold"
                scoreLabel.fontSize = 20.0
                scoreLabel.fontColor = FloppyUIElement.primaryColor
                scoreLabel.horizontalAlignmentMode = .right
                scoreLabel.position = CGPoint(x: size.width/2 - 30, y: yPos)
                panel.addChild(scoreLabel)
                
                // Highlight local player
                if entry.player.gamePlayerID == GKLocalPlayer.local.gamePlayerID {
                    let highlight = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: 40), cornerRadius: 10.0)
                    highlight.fillColor = FloppyUIElement.primaryColor.withAlphaComponent(0.3)
                    highlight.strokeColor = .clear
                    highlight.position = CGPoint(x: 0, y: yPos)
                    highlight.zPosition = -1
                    panel.addChild(highlight)
                }
            }
        }
        
        return panel
    }
    
    // MARK: - Game Center Integration
    
    /// Show the Game Center leaderboard UI
    func showGameCenterLeaderboard(leaderboardID: String = "com.floppyduck.highscore") {
        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.leaderboardIdentifier = leaderboardID
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(gcVC, animated: true)
        }
    }
    
    private init() {
        // Private initializer for singleton
    }
} 