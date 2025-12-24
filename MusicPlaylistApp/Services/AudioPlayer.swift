import AVFoundation
import Combine
import MediaPlayer

class AudioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 1.0
    @Published var playbackRate: Float = 1.0
    @Published var error: AudioPlayerError?
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotifications()
    }
    
    func loadAudio(url: URL) async throws {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        await MainActor.run {
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
                setupTimeObserver()
            } else {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            player?.volume = volume
            player?.rate = playbackRate
        }
        
        do {
            let duration = try await asset.load(.duration)
            await MainActor.run {
                self.duration = duration.seconds
            }
        } catch {
            throw AudioPlayerError.loadFailed(error)
        }
        
        setupPlayerObservers(for: playerItem)
    }
    
    func play() {
        guard let player = player else { return }
        AudioSessionManager.shared.activateSession()
        player.play()
        isPlaying = true
    }
    
    func pause() {
        guard let player = player else { return }
        player.pause()
        isPlaying = false
    }
    
    func stop() {
        guard let player = player else { return }
        player.pause()
        player.seek(to: .zero)
        isPlaying = false
        currentTime = 0
    }
    
    func seek(to time: TimeInterval) {
        guard let player = player else { return }
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime) { [weak self] completed in
            if completed {
                self?.currentTime = time
            }
        }
    }
    
    func skipForward(seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }
    
    func skipBackward(seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }
    
    func setVolume(_ volume: Float) {
        self.volume = max(0, min(1, volume))
        player?.volume = self.volume
    }
    
    func setPlaybackRate(_ rate: Float) {
        let validRate = max(0.5, min(2.0, rate))
        self.playbackRate = validRate
        player?.rate = isPlaying ? validRate : 0
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    private func setupPlayerObservers(for playerItem: AVPlayerItem) {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.error = .playbackFailed(nil)
            }
            .store(in: &cancellables)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .audioInterruptionBegan)
            .sink { [weak self] _ in
                self?.pause()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .audioInterruptionEnded)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo,
                      let shouldResume = userInfo["shouldResume"] as? Bool,
                      shouldResume else {
                    return
                }
                self?.play()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .audioRouteChanged)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo,
                      let reason = userInfo["reason"] as? String,
                      reason == "deviceDisconnected" else {
                    return
                }
                self?.pause()
            }
            .store(in: &cancellables)
    }
    
    private func handlePlaybackEnded() {
        isPlaying = false
        NotificationCenter.default.post(name: .playbackEnded, object: nil)
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        cancellables.removeAll()
    }
}

enum AudioPlayerError: Error, LocalizedError {
    case loadFailed(Error?)
    case playbackFailed(Error?)
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .loadFailed(let error):
            return "Failed to load audio: \(error?.localizedDescription ?? "Unknown error")"
        case .playbackFailed(let error):
            return "Playback failed: \(error?.localizedDescription ?? "Unknown error")"
        case .invalidURL:
            return "Invalid audio URL"
        }
    }
}

extension Notification.Name {
    static let playbackEnded = Notification.Name("playbackEnded")
}
