import SwiftUI

@main
struct MusicPlaylistApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel.shared
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(audioPlayerViewModel)
        }
    }
    
    private func configureAudioSession() {
        AudioSessionManager.shared.configureSession()
    }
}
