import UIKit
import GameKit
import Social

class SocialSharingManager {
    static let shared = SocialSharingManager()
    
    // MARK: - Share Score
    
    func shareScore(_ score: Int, from viewController: UIViewController) {
        // Generate score image
        guard let scoreImage = generateScoreImage(score: score) else { return }
        
        // Create activity view controller
        let activityVC = UIActivityViewController(
            activityItems: [
                "I scored \(score) in Floppy Duck! Can you beat me?",
                scoreImage,
                URL(string: "https://floppyduck.app/challenge?score=\(score)")!
            ],
            applicationActivities: nil
        )
        
        // Prevent iPad crash
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Present sharing options
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Share Replay
    
    func shareReplay(from viewController: UIViewController) {
        // This would be implemented when replay recording is added
        // For now, just share a standard message
        let activityVC = UIActivityViewController(
            activityItems: ["Check out Floppy Duck, the most addictive game!", URL(string: "https://floppyduck.app")!],
            applicationActivities: nil
        )
        
        // Prevent iPad crash
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Challenge Friend
    
    func challengeFriend(score: Int, from viewController: UIViewController) {
        let gcVC = GKGameCenterViewController(state: .challenges)
        gcVC.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        viewController.present(gcVC, animated: true)
    }
    
    // MARK: - Share Achievement
    
    func shareAchievement(_ achievement: GKAchievement, from viewController: UIViewController) {
        // Load achievement details
        GKAchievement.loadAchievements { [weak self] (achievements, error) in
            guard let self = self, let achievements = achievements else { return }
            
            // Find the achievement that matches our achievement ID
            if let achievementDetail = achievements.first(where: { $0.identifier == achievement.identifier }) {
                // Generate achievement image
                if let achievementImage = self.generateAchievementImage(achievement: achievementDetail) {
                    // Create activity view controller
                    let activityVC = UIActivityViewController(
                        activityItems: [
                            "I just unlocked the \(achievementDetail.title ?? "Mystery") achievement in Floppy Duck!",
                            achievementImage,
                            URL(string: "https://floppyduck.app")!
                        ],
                        applicationActivities: nil
                    )
                    
                    // Prevent iPad crash
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = viewController.view
                        popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    // Present sharing options
                    DispatchQueue.main.async {
                        viewController.present(activityVC, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Image Generation
    
    private func generateScoreImage(score: Int) -> UIImage? {
        // Create a context to draw in
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400))
        
        let image = renderer.image { context in
            // Fill background
            let backgroundColor = CustomizationManager.shared.selectedGameTheme.menuColor
            backgroundColor.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
            
            // Draw duck image
            if let duckImage = UIImage(named: "\(CustomizationManager.shared.selectedDuckSkin.atlasName)_1") {
                duckImage.draw(in: CGRect(x: 200, y: 50, width: 200, height: 200))
            }
            
            // Draw score text
            let scoreText = "Score: \(score)"
            let scoreAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 50, weight: .bold),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -4.0
            ]
            
            let scoreSize = scoreText.size(withAttributes: scoreAttributes)
            let scoreRect = CGRect(
                x: 300 - scoreSize.width / 2,
                y: 270,
                width: scoreSize.width,
                height: scoreSize.height
            )
            
            scoreText.draw(in: scoreRect, withAttributes: scoreAttributes)
            
            // Draw game logo
            let logoText = "FLOPPY DUCK"
            let logoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .heavy),
                .foregroundColor: UIColor.yellow,
                .strokeColor: UIColor.black,
                .strokeWidth: -5.0
            ]
            
            let logoSize = logoText.size(withAttributes: logoAttributes)
            let logoRect = CGRect(
                x: 300 - logoSize.width / 2,
                y: 340,
                width: logoSize.width,
                height: logoSize.height
            )
            
            logoText.draw(in: logoRect, withAttributes: logoAttributes)
        }
        
        return image
    }
    
    private func generateAchievementImage(achievement: GKAchievement) -> UIImage? {
        // Create a context to draw in
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400))
        
        let image = renderer.image { context in
            // Fill background
            let backgroundColor = CustomizationManager.shared.selectedGameTheme.menuColor
            backgroundColor.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
            
            // Draw achievement medal
            if let medalImage = UIImage(named: "achievement_medal") {
                medalImage.draw(in: CGRect(x: 200, y: 50, width: 200, height: 200))
            }
            
            // Draw achievement title
            let titleText = achievement.title ?? "Achievement Unlocked!"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -4.0
            ]
            
            let titleSize = titleText.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: 300 - titleSize.width / 2,
                y: 270,
                width: titleSize.width,
                height: titleSize.height
            )
            
            titleText.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Draw game logo
            let logoText = "FLOPPY DUCK"
            let logoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .heavy),
                .foregroundColor: UIColor.yellow,
                .strokeColor: UIColor.black,
                .strokeWidth: -5.0
            ]
            
            let logoSize = logoText.size(withAttributes: logoAttributes)
            let logoRect = CGRect(
                x: 300 - logoSize.width / 2,
                y: 340,
                width: logoSize.width,
                height: logoSize.height
            )
            
            logoText.draw(in: logoRect, withAttributes: logoAttributes)
        }
        
        return image
    }
    
    private init() { }
} 