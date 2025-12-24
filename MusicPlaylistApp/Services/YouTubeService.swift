import Foundation

class YouTubeService {
    static let shared = YouTubeService()
    
    private let urlCache = NSCache<NSString, NSURL>()
    
    private init() {
        urlCache.countLimit = 50
    }
    
    func validateYouTubeURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        let host = url.host?.lowercased() ?? ""
        
        let validHosts = [
            "www.youtube.com",
            "youtube.com",
            "m.youtube.com",
            "youtu.be"
        ]
        
        guard validHosts.contains(host) else {
            return false
        }
        
        if host == "youtu.be" {
            return url.pathComponents.count > 1
        } else {
            return url.query?.contains("v=") ?? false || url.path.contains("/watch")
        }
    }
    
    func extractVideoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        if url.host?.contains("youtu.be") == true {
            return url.pathComponents.last
        }
        
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        }
        
        return nil
    }
    
    func extractAudioURL(from youtubeURL: String) async throws -> String {
        guard validateYouTubeURL(youtubeURL) else {
            throw YouTubeServiceError.invalidURL
        }
        
        if let cachedURL = urlCache.object(forKey: youtubeURL as NSString) {
            return cachedURL.absoluteString ?? ""
        }
        
        guard let videoID = extractVideoID(from: youtubeURL) else {
            throw YouTubeServiceError.invalidVideoID
        }
        
        let audioURL = try await performAudioExtraction(videoID: videoID)
        
        if let url = URL(string: audioURL) {
            urlCache.setObject(url as NSURL, forKey: youtubeURL as NSString)
        }
        
        return audioURL
    }
    
    private func performAudioExtraction(videoID: String) async throws -> String {
        throw YouTubeServiceError.notImplemented
    }
    
    func clearCache() {
        urlCache.removeAllObjects()
    }
}

enum YouTubeServiceError: Error, LocalizedError {
    case invalidURL
    case invalidVideoID
    case extractionFailed
    case networkError
    case timeout
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid YouTube URL"
        case .invalidVideoID:
            return "Could not extract video ID"
        case .extractionFailed:
            return "Failed to extract audio URL"
        case .networkError:
            return "Network error occurred"
        case .timeout:
            return "Request timed out"
        case .notImplemented:
            return "Audio extraction not yet implemented - placeholder for future implementation"
        }
    }
}
