import GameKit
import SpriteKit

/// This file demonstrates the key multiplayer functionality implemented
/// during Week 2. The actual implementation has been integrated into various
/// components of the game.

// MARK: - Multiplayer Game Data Structure

/// Data structure for multiplayer synchronization
struct GameUpdateData: Codable {
    let playerID: String
    let duckPosition: CGPoint
    let duckVelocity: CGVector
    let duckRotation: CGFloat
    let score: Int
    let timestamp: TimeInterval
    let gameEvent: GameEvent?
    
    enum GameEvent: String, Codable {
        case flap
        case hitPipe
        case scorePoint
        case gameOver
    }
}

// MARK: - Multiplayer Match Manager

class MultiplayerMatchManager {
    // Singleton pattern
    static let shared = MultiplayerMatchManager()
    
    // Current match
    private(set) var currentMatch: GKMatch?
    private(set) var matchState: MatchState = .notConnected
    
    // Callbacks
    var matchStateChangedCallback: ((MatchState) -> Void)?
    var dataReceivedCallback: ((GameUpdateData, GKPlayer) -> Void)?
    var errorCallback: ((Error) -> Void)?
    
    // MARK: - Match States
    
    enum MatchState {
        case notConnected
        case connecting
        case connected
        case playing
        case paused
        case complete
        case disconnected
    }
    
    // MARK: - Match Setup
    
    func findMatch() {
        // Create a match request
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        request.inviteMessage = "Let's play Floppy Duck head-to-head!"
        
        // Present the matchmaker view controller
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            if let rootController = UIApplication.shared.windows.first?.rootViewController {
                rootController.present(viewController, animated: true)
            }
        }
    }
    
    func startMatch() {
        guard currentMatch != nil else { return }
        
        // Set match state to playing
        matchState = .playing
        matchStateChangedCallback?(.playing)
        
        // Send initial game state
        sendInitialGameState()
    }
    
    func endMatch() {
        guard let match = currentMatch else { return }
        
        // Send game over event
        let gameOverData = GameUpdateData(
            playerID: GKLocalPlayer.local.gamePlayerID,
            duckPosition: .zero,
            duckVelocity: .zero,
            duckRotation: 0,
            score: 0,
            timestamp: Date().timeIntervalSince1970,
            gameEvent: .gameOver
        )
        
        sendGameData(gameOverData)
        
        // Disconnect
        match.disconnect()
        currentMatch = nil
        matchState = .notConnected
        matchStateChangedCallback?(.notConnected)
    }
    
    // MARK: - Data Transmission
    
    func sendGameData(_ data: GameUpdateData) {
        guard let match = currentMatch, matchState == .playing else { return }
        
        do {
            // Encode game data
            let encodedData = try JSONEncoder().encode(data)
            
            // Send data to opponent reliably
            try match.sendData(encodedData, to: match.players, dataMode: .reliable)
        } catch {
            errorCallback?(error)
        }
    }
    
    private func sendInitialGameState() {
        let initialData = GameUpdateData(
            playerID: GKLocalPlayer.local.gamePlayerID,
            duckPosition: CGPoint(x: 100, y: 300),  // Starting position
            duckVelocity: .zero,
            duckRotation: 0,
            score: 0,
            timestamp: Date().timeIntervalSince1970,
            gameEvent: nil
        )
        
        sendGameData(initialData)
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer for singleton
    }
}

// MARK: - GKMatchmakerViewControllerDelegate

extension MultiplayerMatchManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        // Dismiss the matchmaker
        viewController.dismiss(animated: true)
        
        // Set up the match
        currentMatch = match
        match.delegate = self
        
        // Update match state
        matchState = .connected
        matchStateChangedCallback?(.connected)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        // Dismiss the matchmaker
        viewController.dismiss(animated: true)
        
        // Handle error
        errorCallback?(error)
        matchState = .notConnected
        matchStateChangedCallback?(.notConnected)
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        // Dismiss the matchmaker
        viewController.dismiss(animated: true)
        
        // Reset match state
        matchState = .notConnected
        matchStateChangedCallback?(.notConnected)
    }
}

// MARK: - GKMatchDelegate

extension MultiplayerMatchManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            // Decode received game data
            let gameData = try JSONDecoder().decode(GameUpdateData.self, from: data)
            
            // Notify listeners
            dataReceivedCallback?(gameData, player)
        } catch {
            errorCallback?(error)
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            if match.players.count == match.expectedPlayerCount {
                // All players connected, ready to start
                matchState = .connected
                matchStateChangedCallback?(.connected)
            }
        case .disconnected:
            // Player disconnected
            matchState = .disconnected
            matchStateChangedCallback?(.disconnected)
            
            // Handle opponent disconnection
            if match.players.isEmpty {
                currentMatch = nil
            }
        @unknown default:
            break
        }
    }
}

// MARK: - Spectator Mode

class SpectatorManager {
    // Singleton pattern
    static let shared = SpectatorManager()
    
    // Current match being spectated
    private(set) var currentMatch: GKTurnBasedMatch?
    
    // Callbacks
    var matchUpdatedCallback: ((GKTurnBasedMatch) -> Void)?
    
    func spectateMatch(_ match: GKTurnBasedMatch) {
        currentMatch = match
        
        // Register for match updates
        GKTurnBasedMatch.load(withID: match.matchID) { [weak self] updatedMatch, error in
            if let updatedMatch = updatedMatch {
                self?.matchUpdatedCallback?(updatedMatch)
            }
        }
    }
    
    private init() {
        // Private initializer for singleton
    }
}

// MARK: - Tournament Implementation

extension TournamentManager {
    // Additional tournament functionality
    
    func spectateCurrentMatch() {
        guard let tournament = currentTournament,
              tournament.state == .inProgress,
              !tournament.brackets.isEmpty else { return }
        
        // In a real implementation, this would fetch the active match
        // from Game Center and allow spectating
    }
    
    func getCurrentStandings() -> [GKPlayer] {
        guard let tournament = currentTournament else { return [] }
        
        // Sort players by score
        let playerIDs = tournament.scores.keys
        var players: [GKPlayer] = []
        
        // In a real implementation, we would convert playerIDs to GKPlayer objects
        // and return them sorted by score
        
        return players
    }
} 