import AVFoundation

class SoundManager {
    
    // Singleton instance
    static let shared = SoundManager()
    
    // Sound players
    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    // Settings
    private(set) var isMuted = false
    
    // Private initializer for singleton
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sound Loading and Playback
    func preloadSounds() {
        // Preload game sounds
        let soundNames = ["flap", "quack", "score", "crash", "splash"]
        
        for name in soundNames {
            if let soundURL = Bundle.main.url(forResource: name, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: soundURL)
                    player.prepareToPlay()
                    soundPlayers[name] = player
                } catch {
                    print("Error loading sound \(name): \(error.localizedDescription)")
                }
            } else {
                print("Sound file \(name).wav not found")
            }
        }
    }
    
    func playSound(named name: String) {
        if isMuted { return }
        
        if let player = soundPlayers[name] {
            // Reset player if it's playing
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        }
    }
    
    // MARK: - Background Music
    func playBackgroundMusic(filename: String, type: String) {
        guard !isMuted else { return }
        
        if let backgroundMusicURL = Bundle.main.url(forResource: filename, withExtension: type) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer?.volume = 0.5 // Lower volume
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Error playing background music: \(error.localizedDescription)")
            }
        } else {
            print("Background music file \(filename).\(type) not found")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    // MARK: - Mute Control
    func toggleMute() -> Bool {
        isMuted = !isMuted
        
        if isMuted {
            backgroundMusicPlayer?.pause()
        } else if let player = backgroundMusicPlayer, !player.isPlaying {
            player.play()
        }
        
        return isMuted
    }
} 