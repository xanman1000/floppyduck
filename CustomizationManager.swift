import SpriteKit

class CustomizationManager {
    static let shared = CustomizationManager()
    
    // MARK: - Duck Skins
    
    enum DuckSkin: String, CaseIterable {
        case classic = "Classic"
        case golden = "Golden"
        case pixel = "Pixel"
        case zombie = "Zombie"
        case robot = "Robot"
        case swimmer = "Swimmer"
        
        var isLocked: Bool {
            switch self {
            case .classic:
                return false // Classic is always available
            case .golden:
                return UserDefaults.standard.integer(forKey: "highScore") < 50
            case .pixel:
                return UserDefaults.standard.integer(forKey: "totalFlights") < 100
            case .zombie:
                return UserDefaults.standard.integer(forKey: "totalFlaps") < 1000
            case .robot:
                return UserDefaults.standard.integer(forKey: "gamesPlayed") < 200
            case .swimmer:
                return UserDefaults.standard.integer(forKey: "totalDistance") < 10000
            }
        }
        
        var unlockRequirement: String {
            switch self {
            case .classic:
                return "Available by default"
            case .golden:
                return "Reach a score of 50"
            case .pixel:
                return "Complete 100 flights"
            case .zombie:
                return "Flap 1,000 times"
            case .robot:
                return "Play 200 games"
            case .swimmer:
                return "Travel 10,000 pixels"
            }
        }
        
        var atlasName: String {
            return "duck_\(self.rawValue.lowercased())"
        }
        
        var frameCount: Int {
            switch self {
            case .classic, .golden:
                return 2
            case .pixel:
                return 2
            case .zombie:
                return 3
            case .robot:
                return 4
            case .swimmer:
                return 2
            }
        }
        
        var animationSpeed: TimeInterval {
            switch self {
            case .robot:
                return 0.1
            case .zombie:
                return 0.15
            default:
                return 0.12
            }
        }
    }
    
    // MARK: - Game Themes
    
    enum GameTheme: String, CaseIterable {
        case classic = "Classic"
        case meadow = "Meadow"
        case desert = "Desert"
        case snow = "Snow"
        case neon = "Neon"
        
        var isLocked: Bool {
            switch self {
            case .classic:
                return false // Classic is always available
            case .meadow:
                return UserDefaults.standard.integer(forKey: "totalFlights") < 50
            case .desert:
                return UserDefaults.standard.integer(forKey: "gamesPlayed") < 100
            case .snow:
                return UserDefaults.standard.integer(forKey: "highScore") < 30
            case .neon:
                return UserDefaults.standard.integer(forKey: "totalDistance") < 5000
            }
        }
        
        var unlockRequirement: String {
            switch self {
            case .classic:
                return "Available by default"
            case .meadow:
                return "Complete 50 flights"
            case .desert:
                return "Play 100 games"
            case .snow:
                return "Reach a score of 30"
            case .neon:
                return "Travel 5,000 pixels"
            }
        }
        
        var backgroundTexture: SKTexture {
            return SKTexture(imageNamed: "background_\(self.rawValue.lowercased())")
        }
        
        var groundTexture: SKTexture {
            return SKTexture(imageNamed: "ground_\(self.rawValue.lowercased())")
        }
        
        var pipeTextures: (SKTexture, SKTexture) {
            let up = SKTexture(imageNamed: "pipe_\(self.rawValue.lowercased())_up")
            let down = SKTexture(imageNamed: "pipe_\(self.rawValue.lowercased())_down")
            return (up, down)
        }
        
        var menuColor: SKColor {
            switch self {
            case .classic:
                return SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
            case .meadow:
                return SKColor(red: 124.0/255.0, green: 185.0/255.0, blue: 99.0/255.0, alpha: 1.0)
            case .desert:
                return SKColor(red: 244.0/255.0, green: 164.0/255.0, blue: 96.0/255.0, alpha: 1.0)
            case .snow:
                return SKColor(red: 200.0/255.0, green: 230.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            case .neon:
                return SKColor(red: 0.0/255.0, green: 0.0/255.0, blue: 30.0/255.0, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Properties
    
    private let selectedDuckSkinKey = "selectedDuckSkin"
    private let selectedGameThemeKey = "selectedGameTheme"
    
    var selectedDuckSkin: DuckSkin {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: selectedDuckSkinKey),
               let skin = DuckSkin(rawValue: rawValue) {
                if !skin.isLocked {
                    return skin
                }
            }
            return .classic
        }
        set {
            guard !newValue.isLocked else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedDuckSkinKey)
        }
    }
    
    var selectedGameTheme: GameTheme {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: selectedGameThemeKey),
               let theme = GameTheme(rawValue: rawValue) {
                if !theme.isLocked {
                    return theme
                }
            }
            return .classic
        }
        set {
            guard !newValue.isLocked else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedGameThemeKey)
        }
    }
    
    // MARK: - Duck Animation
    
    func createDuckAnimation() -> SKAction {
        let skin = selectedDuckSkin
        let atlasName = skin.atlasName
        let frameCount = skin.frameCount
        let speed = skin.animationSpeed
        
        var textures: [SKTexture] = []
        
        // Load all frames for the selected skin
        for i in 1...frameCount {
            let texture = SKTexture(imageNamed: "\(atlasName)_\(i)")
            texture.filteringMode = .nearest
            textures.append(texture)
        }
        
        // For animations with more than 2 frames, add reverse sequence
        if frameCount > 2 {
            let reverseTextures = textures.dropFirst().dropLast().reversed()
            textures.append(contentsOf: reverseTextures)
        }
        
        return SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: speed))
    }
    
    // MARK: - Theme Application
    
    func applyCurrentTheme(to scene: SKScene) {
        let theme = selectedGameTheme
        
        // Apply background
        if let bg = scene.childNode(withName: "background") as? SKSpriteNode {
            bg.texture = theme.backgroundTexture
        }
        
        // Apply ground
        scene.enumerateChildNodes(withName: "//ground_*") { node, _ in
            if let ground = node as? SKSpriteNode {
                ground.texture = theme.groundTexture
            }
        }
        
        // Apply pipes
        let pipeTextures = theme.pipeTextures
        scene.enumerateChildNodes(withName: "//pipe_up") { node, _ in
            if let pipe = node as? SKSpriteNode {
                pipe.texture = pipeTextures.0
            }
        }
        scene.enumerateChildNodes(withName: "//pipe_down") { node, _ in
            if let pipe = node as? SKSpriteNode {
                pipe.texture = pipeTextures.1
            }
        }
    }
    
    private init() {
        // Initialize with defaults if not already set
        if UserDefaults.standard.string(forKey: selectedDuckSkinKey) == nil {
            UserDefaults.standard.set(DuckSkin.classic.rawValue, forKey: selectedDuckSkinKey)
        }
        
        if UserDefaults.standard.string(forKey: selectedGameThemeKey) == nil {
            UserDefaults.standard.set(GameTheme.classic.rawValue, forKey: selectedGameThemeKey)
        }
    }
} 