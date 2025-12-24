import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var viewModel: AudioPlayerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "music.note")
                        .font(.system(size: 120))
                        .foregroundColor(.blue)
                        .frame(width: 250, height: 250)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 8) {
                        Text(viewModel.currentSong?.title ?? "No song playing")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { viewModel.currentTime },
                            set: { viewModel.seek(to: $0) }
                        ),
                        in: 0...max(viewModel.duration, 1)
                    )
                    .tint(.blue)
                    
                    HStack {
                        Text(formatTime(viewModel.currentTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatTime(viewModel.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.playPrevious()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    
                    Button(action: {
                        viewModel.skipBackward()
                    }) {
                        Image(systemName: "gobackward.15")
                            .font(.title2)
                    }
                    
                    Button(action: {
                        viewModel.togglePlayPause()
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                    }
                    
                    Button(action: {
                        viewModel.skipForward()
                    }) {
                        Image(systemName: "goforward.15")
                            .font(.title2)
                    }
                    
                    Button(action: {
                        viewModel.playNext()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "speaker.fill")
                        Slider(
                            value: Binding(
                                get: { viewModel.volume },
                                set: { viewModel.setVolume($0) }
                            ),
                            in: 0...1
                        )
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    
                    HStack {
                        Text("0.5×")
                            .font(.caption)
                        Slider(
                            value: Binding(
                                get: { viewModel.playbackRate },
                                set: { viewModel.setPlaybackRate($0) }
                            ),
                            in: 0.5...2.0,
                            step: 0.25
                        )
                        Text("2.0×")
                            .font(.caption)
                        
                        Text(String(format: "%.2f×", viewModel.playbackRate))
                            .font(.caption)
                            .frame(width: 50)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && time >= 0 else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AudioPlayerViewModel.shared
        viewModel.currentSong = Song(title: "Sample Song", youtubeUrl: "https://youtube.com/watch?v=test", duration: 180)
        viewModel.duration = 180
        
        return NowPlayingView()
            .environmentObject(viewModel)
    }
}
