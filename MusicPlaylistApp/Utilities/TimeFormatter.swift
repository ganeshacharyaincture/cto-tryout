import Foundation

struct TimeFormatter {
    static func format(timeInterval: TimeInterval) -> String {
        guard timeInterval.isFinite && timeInterval >= 0 else {
            return "0:00"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    static func formatShort(timeInterval: TimeInterval) -> String {
        guard timeInterval.isFinite && timeInterval >= 0 else {
            return "--:--"
        }
        
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
