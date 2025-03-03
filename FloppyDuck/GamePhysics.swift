import SpriteKit

/// GamePhysics provides constants and utilities to ensure the physics of the game
/// match exactly with the original Flappy Bird.
struct GamePhysics {
    // MARK: - World Physics
    
    /// Gravity constant matching original Flappy Bird
    static let gravity: CGVector = CGVector(dx: 0.0, dy: -5.0)
    
    /// The collision categories for physics bodies
    struct Categories {
        static let duck: UInt32 = 1 << 0
        static let world: UInt32 = 1 << 1 
        static let pipe: UInt32 = 1 << 2
        static let score: UInt32 = 1 << 3
    }
    
    // MARK: - Duck Physics
    
    /// The impulse applied when the duck flaps wings
    static let flapImpulse: CGFloat = 4.0
    
    /// The maximum upward velocity the duck can achieve
    static let maxUpwardVelocity: CGFloat = 300.0
    
    /// The maximum downward velocity the duck can achieve
    static let maxDownwardVelocity: CGFloat = -300.0
    
    /// Angular velocity applied when flapping
    static let flapAngularVelocity: CGFloat = 0.0
    
    /// Angular velocity applied when falling
    static let fallAngularVelocity: CGFloat = 3.0
    
    /// The maximum rotation angle (in radians) the duck can achieve when falling
    static let maxRotationAngle: CGFloat = .pi / 4
    
    /// The minimum rotation angle (in radians) the duck can achieve when flapping
    static let minRotationAngle: CGFloat = -0.4
    
    // MARK: - Game Configuration
    
    /// The gap between top and bottom pipes
    static let pipeGap: CGFloat = 150.0
    
    /// The horizontal speed of pipes
    static let pipeSpeed: CGFloat = 2.5
    
    /// Time between pipe spawns
    static let pipeSpawnInterval: TimeInterval = 2.0
    
    /// Duck physics body size adjustment (scale factor relative to texture)
    static let duckPhysicsScale: CGFloat = 0.85
    
    // MARK: - Utility Methods
    
    /// Configure the physics body for the duck
    static func configureDuckPhysics(for duck: SKSpriteNode) -> SKPhysicsBody {
        let duckSize = duck.size
        let scaledSize = CGSize(
            width: duckSize.width * duckPhysicsScale,
            height: duckSize.height * duckPhysicsScale
        )
        
        let physicsBody = SKPhysicsBody(circleOfRadius: scaledSize.height / 2)
        
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = true
        physicsBody.restitution = 0.0
        physicsBody.friction = 0.0
        physicsBody.angularDamping = 0.8
        physicsBody.linearDamping = 0.8
        
        physicsBody.categoryBitMask = Categories.duck
        physicsBody.collisionBitMask = Categories.world | Categories.pipe
        physicsBody.contactTestBitMask = Categories.world | Categories.pipe | Categories.score
        
        return physicsBody
    }
    
    /// Apply a flap impulse to the duck's physics body
    static func applyFlapImpulse(to duckBody: SKPhysicsBody) {
        duckBody.velocity = CGVector(dx: 0, dy: 0)
        duckBody.applyImpulse(CGVector(dx: 0, dy: flapImpulse))
        duckBody.angularVelocity = flapAngularVelocity
    }
    
    /// Configure the physics body for a pipe
    static func configurePipePhysics(for pipe: SKSpriteNode) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: pipe.size)
        
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = Categories.pipe
        physicsBody.collisionBitMask = Categories.duck
        
        return physicsBody
    }
    
    /// Configure the physics body for the score detection area
    static func configureScorePhysics(withSize size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)
        
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = Categories.score
        physicsBody.collisionBitMask = 0
        physicsBody.contactTestBitMask = Categories.duck
        
        return physicsBody
    }
    
    /// Configure the world physics body (ground and ceiling)
    static func configureWorldPhysics(withSize size: CGSize, thickness: CGFloat) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: 0, y: thickness),
            to: CGPoint(x: size.width, y: thickness)
        )
        
        physicsBody.categoryBitMask = Categories.world
        physicsBody.collisionBitMask = Categories.duck
        physicsBody.contactTestBitMask = Categories.duck
        
        return physicsBody
    }
} 