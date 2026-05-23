import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EntryListView()
                .tabItem {
                    Label("Log", systemImage: "list.bullet")
                }

            ChartsTabView()
                .tabItem {
                    Label("Charts", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
