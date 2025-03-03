import Foundation
import SpriteKit
import CoreLocation

class EnvironmentManager: NSObject {
    static let shared = EnvironmentManager()
    
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    private var currentTime: Date = Date()
    
    private var timer: Timer?
    
    // Sky colors for different times of day
    let dawnSky = SKColor(red: 244.0/255.0, green: 164.0/255.0, blue: 96.0/255.0, alpha: 1.0)
    let daySky = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    let duskSky = SKColor(red: 255.0/255.0, green: 99.0/255.0, blue: 71.0/255.0, alpha: 1.0)
    let nightSky = SKColor(red: 25.0/255.0, green: 25.0/255.0, blue: 112.0/255.0, alpha: 1.0)
    
    // Callbacks
    var environmentChangedCallback: ((EnvironmentTheme) -> Void)?
    
    // Current environment theme
    private(set) var currentTheme: EnvironmentTheme = .day
    
    enum EnvironmentTheme: String {
        case dawn
        case day
        case dusk
        case night
        
        var skyColor: SKColor {
            switch self {
            case .dawn: return EnvironmentManager.shared.dawnSky
            case .day: return EnvironmentManager.shared.daySky
            case .dusk: return EnvironmentManager.shared.duskSky
            case .night: return EnvironmentManager.shared.nightSky
            }
        }
        
        var groundFilter: CIFilter? {
            switch self {
            case .dawn: return CIFilter(name: "CISepiaTone", parameters: ["inputIntensity": 0.3])
            case .day: return nil
            case .dusk: return CIFilter(name: "CISepiaTone", parameters: ["inputIntensity": 0.5])
            case .night: return CIFilter(name: "CIColorMonochrome", parameters: ["inputColor": CIColor(red: 0.6, green: 0.6, blue: 1.0), "inputIntensity": 0.5])
            }
        }
        
        var lightLevel: CGFloat {
            switch self {
            case .dawn: return 0.7
            case .day: return 1.0
            case .dusk: return 0.6
            case .night: return 0.3
            }
        }
    }
    
    private override init() {
        super.init()
        setupLocationServices()
        updateEnvironmentBasedOnTime()
        
        // Setup timer to update environment every minute
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateEnvironmentBasedOnTime), userInfo: nil, repeats: true)
    }
    
    // MARK: - Location Services
    
    private func setupLocationServices() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer // We don't need high accuracy
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    // MARK: - Environment Update
    
    @objc func updateEnvironmentBasedOnTime() {
        currentTime = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        
        let newTheme: EnvironmentTheme
        
        switch hour {
        case 5..<8: // Dawn: 5 AM - 8 AM
            newTheme = .dawn
        case 8..<18: // Day: 8 AM - 6 PM
            newTheme = .day
        case 18..<21: // Dusk: 6 PM - 9 PM
            newTheme = .dusk
        default: // Night: 9 PM - 5 AM
            newTheme = .night
        }
        
        if newTheme != currentTheme {
            currentTheme = newTheme
            environmentChangedCallback?(newTheme)
        }
    }
    
    func getSunPosition() -> CGPoint {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        
        // Calculate total minutes since midnight
        let totalMinutesSinceMidnight = hour * 60 + minute
        
        // Calculate sun position on a 24-hour arc
        let sunriseMinutes = 6 * 60 // 6 AM
        let sunsetMinutes = 18 * 60 // 6 PM
        
        // Map time to x position (0 to 1) where 0 is sunrise and 1 is sunset
        var xPosition: CGFloat = 0
        
        if totalMinutesSinceMidnight < sunriseMinutes {
            // Before sunrise - sun is below horizon on the left
            xPosition = -0.2
        } else if totalMinutesSinceMidnight > sunsetMinutes {
            // After sunset - sun is below horizon on the right
            xPosition = 1.2
        } else {
            // During daylight - sun moves across the sky
            xPosition = CGFloat(totalMinutesSinceMidnight - sunriseMinutes) / CGFloat(sunsetMinutes - sunriseMinutes)
        }
        
        // Calculate y position on a sin curve for arc (0 to 1 to 0)
        var yPosition: CGFloat = 0
        
        if totalMinutesSinceMidnight >= sunriseMinutes && totalMinutesSinceMidnight <= sunsetMinutes {
            // Sun is visible - calculate height based on time
            yPosition = sin(CGFloat.pi * xPosition) * 0.8 + 0.2
        } else {
            // Sun is below horizon
            yPosition = -0.2
        }
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    deinit {
        timer?.invalidate()
        locationManager?.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension EnvironmentManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        // No need to constantly update location
        locationManager?.stopUpdatingLocation()
        
        // Update environment based on new location
        updateEnvironmentBasedOnTime()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
} 