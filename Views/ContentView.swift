import SwiftUI

struct ContentView: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { DashboardView() }
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }.tag(0)
            NavigationStack { PrescriptionsListView() }
                .tabItem { Label("Prescriptions", systemImage: "doc.text.magnifyingglass") }.tag(1)
            NavigationStack { NewPrescriptionView() }
                .tabItem { Label("New Entry", systemImage: "pill.circle") }.tag(2)
        }
        .tint(.teal)
    }
}
