//
//  GameViewController.swift
//  FloppyDuck
//
//  Created based on FlappyBird by Nate Murray
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate, MatchmakingHandlerDelegate {
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Default leaderboard ID
    
    // Matchmaking handler
    var matchmakingHandler: MatchmakingHandler?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load achievements when the game starts
        AchievementManager.shared.loadAchievements()
        
        // Authenticate Game Center
        authenticateLocalPlayer()
        
        // Show splash screen first
        if let view = self.view as? SKView {
            // Configure the view
            view.showsFPS = true
            view.showsNodeCount = true
            view.ignoresSiblingOrder = true
            
            // Create and present the splash screen
            let splashScreen = SplashScreen(size: view.bounds.size)
            splashScreen.scaleMode = .aspectFill
            splashScreen.completion = { [weak self] in
                self?.loadMainGame()
            }
            
            view.presentScene(splashScreen)
        }
    }
    
    func loadMainGame() {
        if let view = self.view as? SKView, let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene with a transition
            let transition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(scene, transition: transition)
        }
    }
    
    // MARK: - Game Center Authentication
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                // 1. Show login if player is not logged in
                self.present(viewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier, error) in
                    if error != nil {
                        print("Error getting leaderboard: \(String(describing: error))")
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifier ?? "floppyduck.highscores"
                    }
                })
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    // MARK: - Game Center Delegate Methods
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Game Center Score Reporting
    
    func submitScore(score: Int) {
        if gcEnabled {
            let bestScoreInt = score
            
            let scoreReporter = GKScore(leaderboardIdentifier: gcDefaultLeaderBoard)
            scoreReporter.value = Int64(bestScoreInt)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                if error != nil {
                    print("Error reporting score: \(String(describing: error))")
                }
            })
        }
    }
    
    // MARK: - Show Game Center UI
    
    /// Present Game Center leaderboards
    func showLeaderboard() {
        if gcEnabled {
            let gcVC = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = .leaderboards
            gcVC.leaderboardIdentifier = gcDefaultLeaderBoard
            present(gcVC, animated: true, completion: nil)
        } else {
            // Game Center not enabled, show alert
            let alert = UIAlertController(title: "Game Center Disabled", 
                                         message: "Please sign in to Game Center to view leaderboards.", 
                                       preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    /// Present Game Center achievements
    func showAchievements() {
        if gcEnabled {
            let gcVC = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = .achievements
            present(gcVC, animated: true, completion: nil)
        } else {
            // Game Center not enabled, show alert
            let alert = UIAlertController(title: "Game Center Disabled", 
                                         message: "Please sign in to Game Center to view achievements.", 
                                       preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Device Orientation
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Matchmaking
    
    func startMatchmaking() {
        matchmakingHandler = MatchmakingHandler(viewController: self)
        matchmakingHandler?.delegate = self
        matchmakingHandler?.startMatchmaking()
    }
    
    // MARK: - MatchmakingHandlerDelegate
    
    func matchmakingHandler(_ handler: MatchmakingHandler, didFind match: GKMatch) {
        // Pass the match to the game scene
        if let skView = self.view as? SKView, let scene = skView.scene as? GameScene {
            scene.match = match
            scene.startMultiplayerGame()
        }
    }
    
    func matchmakingHandler(_ handler: MatchmakingHandler, matchmakingFailed error: Error?) {
        let message = error?.localizedDescription ?? "Unknown error"
        let alert = UIAlertController(title: "Matchmaking Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func matchmakingHandlerCanceled(_ handler: MatchmakingHandler) {
        // Return to main menu or handle cancel
    }
} 