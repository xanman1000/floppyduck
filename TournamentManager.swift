import GameKit

class TournamentManager {
    static let shared = TournamentManager()
    
    // MARK: - Tournament Properties
    
    enum TournamentState {
        case notStarted
        case registration
        case inProgress
        case complete
    }
    
    struct Tournament {
        let id: String
        let name: String
        let startTime: Date
        let endTime: Date
        let players: [GKPlayer]
        var state: TournamentState
        var brackets: [[GKPlayer]]
        var scores: [String: Int] // Player ID: Score
        var winners: [GKPlayer]
        var currentRound: Int
    }
    
    private(set) var currentTournament: Tournament?
    private(set) var availableTournaments: [Tournament] = []
    
    // Callbacks
    var tournamentUpdatedCallback: ((Tournament) -> Void)?
    var tournamentListUpdatedCallback: (([Tournament]) -> Void)?
    
    // MARK: - Tournament Management
    
    func createTournament(name: String, startTime: Date? = nil, duration: TimeInterval = 3600) {
        let tournamentStartTime = startTime ?? Date()
        let tournamentEndTime = tournamentStartTime.addingTimeInterval(duration)
        
        // Create a new tournament
        let tournament = Tournament(
            id: UUID().uuidString,
            name: name,
            startTime: tournamentStartTime,
            endTime: tournamentEndTime,
            players: [GKLocalPlayer.local],
            state: .registration,
            brackets: [],
            scores: [:],
            winners: [],
            currentRound: 0
        )
        
        // Store the tournament
        saveTournament(tournament)
        
        // Set as current tournament
        currentTournament = tournament
        
        // Create a public tournament in Game Center
        let tournamentData = encodeToData(tournament: tournament)
        
        // Send a tournament invite to nearby players or friends
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 8
        request.defaultNumberOfPlayers = 4
        request.inviteMessage = "Join my Floppy Duck tournament: \(name)"
        
        // TODO: Implement with Game Center matchmaking
        // This is a placeholder for the actual implementation
        
        // Notify listeners
        tournamentUpdatedCallback?(tournament)
    }
    
    func joinTournament(tournamentData: Data) {
        guard let tournament = decodeFromData(data: tournamentData) else { return }
        
        // Add tournament to available tournaments
        availableTournaments.append(tournament)
        
        // Set as current tournament
        currentTournament = tournament
        
        // Notify listeners
        tournamentUpdatedCallback?(tournament)
        tournamentListUpdatedCallback?(availableTournaments)
    }
    
    func startTournament() {
        guard var tournament = currentTournament, tournament.state == .registration else { return }
        
        // Update tournament state
        tournament.state = .inProgress
        
        // Generate brackets based on player count
        tournament.brackets = generateBrackets(players: tournament.players)
        
        // Update tournament
        currentTournament = tournament
        updateTournament(tournament)
        
        // Notify listeners
        tournamentUpdatedCallback?(tournament)
    }
    
    func submitScore(_ score: Int, forTournament tournamentId: String) {
        guard var tournament = currentTournament, tournament.id == tournamentId else { return }
        
        // Update player's score
        tournament.scores[GKLocalPlayer.local.gamePlayerID] = score
        
        // Update tournament
        currentTournament = tournament
        updateTournament(tournament)
        
        // Notify listeners
        tournamentUpdatedCallback?(tournament)
    }
    
    func advanceTournament() {
        guard var tournament = currentTournament, tournament.state == .inProgress else { return }
        
        // Determine winners of current round
        let roundWinners = determineRoundWinners(tournament: tournament)
        
        // If we have only one winner, tournament is complete
        if roundWinners.count == 1 {
            tournament.state = .complete
            tournament.winners = roundWinners
        } else {
            // Otherwise, generate next round brackets
            tournament.brackets = generateBrackets(players: roundWinners)
            tournament.currentRound += 1
        }
        
        // Update tournament
        currentTournament = tournament
        updateTournament(tournament)
        
        // Notify listeners
        tournamentUpdatedCallback?(tournament)
    }
    
    // MARK: - Helper Methods
    
    private func generateBrackets(players: [GKPlayer]) -> [[GKPlayer]] {
        // Create matches of 2 players each
        var brackets: [[GKPlayer]] = []
        var remainingPlayers = players.shuffled() // Randomize player order
        
        while remainingPlayers.count >= 2 {
            let player1 = remainingPlayers.removeFirst()
            let player2 = remainingPlayers.removeFirst()
            brackets.append([player1, player2])
        }
        
        // If we have an odd number of players, one gets a bye
        if !remainingPlayers.isEmpty {
            brackets.append([remainingPlayers[0]])
        }
        
        return brackets
    }
    
    private func determineRoundWinners(tournament: Tournament) -> [GKPlayer] {
        var winners: [GKPlayer] = []
        
        // For each bracket, determine the winner based on scores
        for bracket in tournament.brackets {
            if bracket.count == 1 {
                // Player had a bye
                winners.append(bracket[0])
            } else if bracket.count == 2 {
                let player1 = bracket[0]
                let player2 = bracket[1]
                
                let score1 = tournament.scores[player1.gamePlayerID] ?? 0
                let score2 = tournament.scores[player2.gamePlayerID] ?? 0
                
                if score1 >= score2 {
                    winners.append(player1)
                } else {
                    winners.append(player2)
                }
            }
        }
        
        return winners
    }
    
    // MARK: - Data Persistence
    
    private func saveTournament(_ tournament: Tournament) {
        // In a real app, we would save to a database or Game Center
        // For now, we just keep it in memory and log
        print("Saved tournament: \(tournament.name)")
        
        // Add to available tournaments if not already there
        if !availableTournaments.contains(where: { $0.id == tournament.id }) {
            availableTournaments.append(tournament)
            tournamentListUpdatedCallback?(availableTournaments)
        }
    }
    
    private func updateTournament(_ tournament: Tournament) {
        // Update tournament in available tournaments
        if let index = availableTournaments.firstIndex(where: { $0.id == tournament.id }) {
            availableTournaments[index] = tournament
            tournamentListUpdatedCallback?(availableTournaments)
        }
    }
    
    private func encodeToData(tournament: Tournament) -> Data {
        // In a real app, we would encode the tournament to JSON
        // For now, return a placeholder
        return Data()
    }
    
    private func decodeFromData(data: Data) -> Tournament? {
        // In a real app, we would decode the tournament from JSON
        // For now, return nil
        return nil
    }
    
    // MARK: - Initialization
    
    private init() {
        // Initialize with no tournaments
    }
}

// MARK: - Tournament View Controller

class TournamentViewController: UIViewController {
    // This is a placeholder for the actual tournament UI
    // Will be implemented in a separate file
} 