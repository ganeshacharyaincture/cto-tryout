import SwiftUI

struct PlaylistsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: PlaylistsViewModel
    @State private var showingAddPlaylist = false
    @State private var newPlaylistName = ""
    
    init() {
        _viewModel = StateObject(wrappedValue: PlaylistsViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.playlists) { playlist in
                NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                    PlaylistRowView(playlist: playlist)
                }
            }
            .onDelete(perform: deletePlaylists)
            .onMove(perform: movePlaylists)
        }
        .navigationTitle("Playlists")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPlaylist = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddPlaylist) {
            AddPlaylistView(isPresented: $showingAddPlaylist, onCreate: createPlaylist)
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil), presenting: viewModel.error) { _ in
            Button("OK") {
                viewModel.error = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .refreshable {
            viewModel.fetchPlaylists()
        }
    }
    
    private func createPlaylist(name: String) {
        viewModel.createPlaylist(name: name)
    }
    
    private func deletePlaylists(at offsets: IndexSet) {
        offsets.forEach { index in
            let playlist = viewModel.playlists[index]
            viewModel.deletePlaylist(playlist)
        }
    }
    
    private func movePlaylists(from source: IndexSet, to destination: Int) {
        viewModel.reorderPlaylists(from: source, to: destination)
    }
}

struct PlaylistRowView: View {
    let playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(playlist.name)
                .font(.headline)
            
            Text("\(playlist.songs.count) songs")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AddPlaylistView: View {
    @Binding var isPresented: Bool
    let onCreate: (String) -> Void
    @State private var playlistName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Playlist Name", text: $playlistName)
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate(playlistName)
                        isPresented = false
                    }
                    .disabled(playlistName.isEmpty)
                }
            }
        }
    }
}

struct PlaylistsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlaylistsListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
