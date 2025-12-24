import SwiftUI

struct PlaylistDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var viewModel: PlaylistDetailViewModel
    @State private var showingAddSong = false
    
    let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        _viewModel = StateObject(wrappedValue: PlaylistDetailViewModel(
            context: PersistenceController.shared.container.viewContext,
            playlist: playlist
        ))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.songs) { song in
                SongRowView(song: song, isPlaying: audioPlayerViewModel.currentSong?.id == song.id)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        playSong(song)
                    }
            }
            .onDelete(perform: deleteSongs)
            .onMove(perform: moveSongs)
        }
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddSong = true }) {
                        Label("Add Song", systemImage: "plus")
                    }
                    
                    Button(action: playAll) {
                        Label("Play All", systemImage: "play.fill")
                    }
                    .disabled(viewModel.songs.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSong) {
            AddSongView(isPresented: $showingAddSong, onAdd: addSong)
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil), presenting: viewModel.error) { _ in
            Button("OK") {
                viewModel.error = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .overlay {
            if viewModel.songs.isEmpty {
                ContentUnavailableView(
                    "No Songs",
                    systemImage: "music.note.list",
                    description: Text("Add songs to this playlist")
                )
            }
        }
    }
    
    private func playSong(_ song: Song) {
        audioPlayerViewModel.loadPlaylist(viewModel.songs, startIndex: viewModel.songs.firstIndex(of: song) ?? 0)
        audioPlayerViewModel.play()
    }
    
    private func playAll() {
        audioPlayerViewModel.loadPlaylist(viewModel.songs, startIndex: 0)
        audioPlayerViewModel.play()
    }
    
    private func addSong(title: String, youtubeUrl: String) {
        Task {
            await viewModel.addSong(title: title, youtubeUrl: youtubeUrl)
        }
    }
    
    private func deleteSongs(at offsets: IndexSet) {
        offsets.forEach { index in
            let song = viewModel.songs[index]
            viewModel.removeSong(song)
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        viewModel.reorderSongs(from: source, to: destination)
    }
}

struct SongRowView: View {
    let song: Song
    let isPlaying: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(isPlaying ? .blue : .primary)
                
                HStack {
                    Text(formatDuration(song.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if song.audioUrl == nil {
                        Text("• Processing")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        guard duration > 0 else { return "--:--" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AddSongView: View {
    @Binding var isPresented: Bool
    let onAdd: (String, String) -> Void
    
    @State private var songTitle = ""
    @State private var youtubeUrl = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Song Details") {
                    TextField("Title", text: $songTitle)
                    TextField("YouTube URL", text: $youtubeUrl)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Text("Paste a YouTube URL and the audio will be extracted automatically.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd(songTitle, youtubeUrl)
                        isPresented = false
                    }
                    .disabled(songTitle.isEmpty || youtubeUrl.isEmpty)
                }
            }
        }
    }
}

struct PlaylistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let playlist = Playlist(name: "My Playlist")
        NavigationStack {
            PlaylistDetailView(playlist: playlist)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AudioPlayerViewModel.shared)
        }
    }
}
