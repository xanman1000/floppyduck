//
//  AchievementManager.swift
//  FloppyDuck
//
//  Created for FloppyDuck game
//

import GameKit

class AchievementManager {
    
    // MARK: - Achievement IDs
    struct AchievementID {
        static let firstFlight = "floppyduck.firstflight"
        static let distanceFlyer = "floppyduck.distanceflyer"
        static let flapMaster = "floppyduck.flapmaster"
        static let highScorer = "floppyduck.highscorer"
    }
    
    // MARK: - Singleton
    static let shared = AchievementManager()
    private init() {}
    
    // MARK: - Local Achievement Cache
    private var cachedAchievements: [String: GKAchievement] = [:]
    private var achievementsLoaded = false
    
    // MARK: - Load Achievements
    func loadAchievements(completion: ((Error?) -> Void)? = nil) {
        GKAchievement.loadAchievements { [weak self] (achievements, error) in
            guard let self = self else { return }
            
            if let achievements = achievements {
                for achievement in achievements {
                    self.cachedAchievements[achievement.identifier] = achievement
                }
                self.achievementsLoaded = true
            }
            
            completion?(error)
        }
    }
    
    // MARK: - Achievement Progress Tracking
    
    /// Report the first flight achievement
    func reportFirstFlight() {
        if GKLocalPlayer.local.isAuthenticated {
            reportAchievement(identifier: AchievementID.firstFlight, percentComplete: 100.0)
        }
    }
    
    /// Report distance flown progress (out of 1000 meters)
    func reportDistanceFlown(_ distance: Double) {
        if GKLocalPlayer.local.isAuthenticated {
            // Calculate percentage (1000 meters = 100%)
            let percentComplete = min(distance / 1000.0 * 100.0, 100.0)
            reportAchievement(identifier: AchievementID.distanceFlyer, percentComplete: percentComplete)
        }
    }
    
    /// Report flap count progress (out of 1000 flaps)
    func reportFlaps(_ flaps: Int) {
        if GKLocalPlayer.local.isAuthenticated {
            // Calculate percentage (1000 flaps = 100%)
            let percentComplete = min(Double(flaps) / 1000.0 * 100.0, 100.0)
            reportAchievement(identifier: AchievementID.flapMaster, percentComplete: percentComplete)
        }
    }
    
    /// Report high score progress (out of target score of 50)
    func reportHighScore(_ score: Int) {
        if GKLocalPlayer.local.isAuthenticated {
            // Calculate percentage (score of 50 = 100%)
            let percentComplete = min(Double(score) / 50.0 * 100.0, 100.0)
            reportAchievement(identifier: AchievementID.highScorer, percentComplete: percentComplete)
        }
    }
    
    // MARK: - Achievement Reporting
    
    /// Report achievement progress to Game Center
    private func reportAchievement(identifier: String, percentComplete: Double) {
        
        // If achievements aren't loaded yet, load them first
        if !achievementsLoaded {
            loadAchievements { [weak self] _ in
                self?.reportAchievement(identifier: identifier, percentComplete: percentComplete)
            }
            return
        }
        
        // Get existing achievement or create a new one
        let achievement: GKAchievement
        if let existingAchievement = cachedAchievements[identifier] {
            achievement = existingAchievement
        } else {
            achievement = GKAchievement(identifier: identifier)
            cachedAchievements[identifier] = achievement
        }
        
        // Only update if the new progress is greater than existing progress
        if percentComplete > achievement.percentComplete {
            achievement.percentComplete = percentComplete
            achievement.showsCompletionBanner = true
            
            // Report the achievement
            let achievementsToReport = [achievement]
            GKAchievement.report(achievementsToReport) { (error) in
                if let error = error {
                    print("Error reporting achievement: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Reset Achievements (for testing)
    
    /// Reset all achievements (useful during development)
    func resetAllAchievements() {
        GKAchievement.resetAchievements { (error) in
            if let error = error {
                print("Error resetting achievements: \(error.localizedDescription)")
            } else {
                self.cachedAchievements.removeAll()
                print("Successfully reset achievements")
            }
        }
    }
} 