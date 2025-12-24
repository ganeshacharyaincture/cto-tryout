import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                PlaylistsListView()
                    .padding(.bottom, audioPlayerViewModel.currentSong != nil ? 70 : 0)
                
                if audioPlayerViewModel.currentSong != nil {
                    MiniPlayerView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AudioPlayerViewModel.shared)
    }
}
