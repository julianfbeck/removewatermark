struct MainTabView: View {
    @StateObject private var viewModel = TryOnViewModel()
    
    var body: some View {
        TabView {
            TryOnView()
                .tabItem {
                    Label("Try On", systemImage: "tshirt.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(viewModel)
        .accentColor(.accentColor) // This uses the asset catalog's accent color
    }
}