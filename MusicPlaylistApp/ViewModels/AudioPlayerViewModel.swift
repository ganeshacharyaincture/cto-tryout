import Combine
import Foundation
import AVFoundation

class AudioPlayerViewModel: ObservableObject {
    static let shared = AudioPlayerViewModel()
    
    @Published var currentSong: Song?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 1.0
    @Published var playbackRate: Float = 1.0
    @Published var error: AudioPlayerError?
    @Published var playlist: [Song] = []
    @Published var currentIndex: Int = 0
    
    private let audioPlayer = AudioPlayer()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
        RemoteCommandManager.shared.setup(with: self)
    }
    
    private func setupBindings() {
        audioPlayer.$isPlaying
            .assign(to: &$isPlaying)
        
        audioPlayer.$currentTime
            .assign(to: &$currentTime)
        
        audioPlayer.$duration
            .assign(to: &$duration)
        
        audioPlayer.$volume
            .assign(to: &$volume)
        
        audioPlayer.$playbackRate
            .assign(to: &$playbackRate)
        
        audioPlayer.$error
            .assign(to: &$error)
        
        Publishers.CombineLatest4($currentSong, $currentTime, $duration, $isPlaying)
            .sink { [weak self] song, time, duration, playing in
                RemoteCommandManager.shared.updateNowPlayingInfo(
                    song: song,
                    currentTime: time,
                    duration: duration,
                    isPlaying: playing
                )
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .playbackEnded)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)
    }
    
    func loadSong(_ song: Song) async {
        currentSong = song
        
        guard let audioUrlString = song.audioUrl,
              let audioUrl = URL(string: audioUrlString) else {
            error = .invalidURL
            return
        }
        
        do {
            try await audioPlayer.loadAudio(url: audioUrl)
        } catch {
            self.error = error as? AudioPlayerError ?? .loadFailed(error)
        }
    }
    
    func loadPlaylist(_ songs: [Song], startIndex: Int = 0) {
        playlist = songs
        currentIndex = startIndex
        
        if currentIndex < playlist.count {
            Task {
                await loadSong(playlist[currentIndex])
            }
        }
    }
    
    func play() {
        audioPlayer.play()
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func stop() {
        audioPlayer.stop()
        currentSong = nil
        RemoteCommandManager.shared.clearNowPlayingInfo()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer.seek(to: time)
    }
    
    func skipForward() {
        audioPlayer.skipForward()
    }
    
    func skipBackward() {
        audioPlayer.skipBackward()
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer.setVolume(volume)
    }
    
    func setPlaybackRate(_ rate: Float) {
        audioPlayer.setPlaybackRate(rate)
    }
    
    func playNext() {
        guard !playlist.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % playlist.count
        Task {
            await loadSong(playlist[currentIndex])
            play()
        }
    }
    
    func playPrevious() {
        guard !playlist.isEmpty else { return }
        
        if currentTime > 3 {
            seek(to: 0)
        } else {
            currentIndex = currentIndex > 0 ? currentIndex - 1 : playlist.count - 1
            Task {
                await loadSong(playlist[currentIndex])
                play()
            }
        }
    }
    
    private func handlePlaybackEnded() {
        if currentIndex < playlist.count - 1 {
            playNext()
        } else {
            stop()
        }
    }
}
