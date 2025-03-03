import UIKit
import SpriteKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the window and set its scene
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Create and configure the view controller
        let viewController = GameViewController()
        window.rootViewController = viewController
        
        // Display the window
        window.makeKeyAndVisible()
        
        // Handle any URL contexts that were provided at launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleDeepLink(url: urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            handleDeepLink(url: urlContext.url)
        }
    }
    
    private func handleDeepLink(url: URL) {
        // Handle deep links for invites, challenges, etc.
        guard url.scheme == "floppyduck" else { return }
        
        if url.host == "challenge" {
            // Extract challenge ID and route to the appropriate screen
            // This will be implemented later in the multiplayer feature
            print("Received challenge deep link: \(url)")
        } else if url.host == "tournament" {
            // Handle tournament deep links
            print("Received tournament deep link: \(url)")
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        
        // Resume game if it was paused
        NotificationCenter.default.post(name: NSNotification.Name("ResumeGameIfPaused"), object: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        
        // Pause game
        NotificationCenter.default.post(name: NSNotification.Name("PauseGame"), object: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        
        // Save game state if needed
        NotificationCenter.default.post(name: NSNotification.Name("SaveGameState"), object: nil)
    }
} 