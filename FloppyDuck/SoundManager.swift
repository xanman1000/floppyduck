//
//  SoundManager.swift
//  FloppyDuck
//
//  Created for FloppyDuck game
//

import AVFoundation

class SoundManager {
    
    // MARK: - Singleton
    static let shared = SoundManager()
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Properties
    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var muted = false
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Load Sounds
    func preloadSounds() {
        // Preload all game sounds
        preloadSound(filename: "quack", type: "wav")
        preloadSound(filename: "flap", type: "wav")
        preloadSound(filename: "score", type: "wav")
        preloadSound(filename: "crash", type: "wav")
        preloadSound(filename: "splash", type: "wav")
    }
    
    private func preloadSound(filename: String, type: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            print("Sound file not found: \(filename).\(type)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            soundPlayers[filename] = player
        } catch {
            print("Failed to load sound \(filename): \(error)")
        }
    }
    
    // MARK: - Play Sounds
    func playSound(named name: String) {
        if muted { return }
        
        if let player = soundPlayers[name] {
            if player.isPlaying {
                player.currentTime = 0
            } else {
                player.play()
            }
        } else {
            // Try to load the sound if it wasn't preloaded
            preloadSound(filename: name, type: "wav")
            soundPlayers[name]?.play()
        }
    }
    
    // MARK: - Background Music
    func playBackgroundMusic(filename: String, type: String) {
        if muted { return }
        
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            print("Background music file not found: \(filename).\(type)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.5 // Lower volume for background music
            backgroundMusicPlayer?.play()
        } catch {
            print("Failed to play background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    // MARK: - Sound Control
    func toggleMute() -> Bool {
        muted = !muted
        
        if muted {
            backgroundMusicPlayer?.pause()
        } else {
            backgroundMusicPlayer?.play()
        }
        
        return muted
    }
    
    var isMuted: Bool {
        return muted
    }
} 