import SpriteKit

// This is a utility script to help you generate a GameScene.sks file
// Copy and paste this code into a new Swift file in a test project,
// run it, and it will generate and save a GameScene.sks file that
// you can use in your FloppyDuck project.

class SceneGenerator {
    
    static func generateGameScene() {
        let scene = SKScene(size: CGSize(width: 320, height: 568))
        scene.backgroundColor = .clear
        
        // You can add initial nodes to the scene if needed
        
        // Save the scene to a file
        let path = NSHomeDirectory() + "/Desktop/GameScene.sks"
        NSKeyedArchiver.archiveRootObject(scene, toFile: path)
        print("Scene saved to: \(path)")
    }
}

// Call this function in a test project to generate the scene
// SceneGenerator.generateGameScene() 