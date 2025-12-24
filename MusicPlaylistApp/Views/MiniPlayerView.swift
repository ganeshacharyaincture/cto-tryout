import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var viewModel: AudioPlayerViewModel
    @State private var showingNowPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: viewModel.currentTime, total: viewModel.duration)
                .progressViewStyle(.linear)
                .tint(.blue)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.currentSong?.title ?? "No song playing")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(formatTime(viewModel.currentTime) + " / " + formatTime(viewModel.duration))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.skipBackward()
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title3)
                }
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                
                Button(action: {
                    viewModel.skipForward()
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .onTapGesture {
            showingNowPlaying = true
        }
        .sheet(isPresented: $showingNowPlaying) {
            NowPlayingView()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && time >= 0 else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AudioPlayerViewModel.shared
        viewModel.currentSong = Song(title: "Sample Song", youtubeUrl: "https://youtube.com/watch?v=test")
        
        return MiniPlayerView()
            .environmentObject(viewModel)
    }
}
