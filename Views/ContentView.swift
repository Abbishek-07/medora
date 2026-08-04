//
//  ContentView.swift
//  Medora
//
//  Same 3-tab structure and view hierarchy as before — added the pink
//  tab bar styling and the splash-to-dashboard zoom on launch.
//

import SwiftUI

struct ContentView: View {
    @State private var tab = 0
    @State private var showSplash = true

    var body: some View {
        ZStack {
            TabView(selection: $tab) {
                NavigationStack { DashboardView() }
                    .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }.tag(0)
                NavigationStack { PrescriptionsListView() }
                    .tabItem { Label("Prescriptions", systemImage: "doc.text.magnifyingglass") }.tag(1)
                NavigationStack { NewPrescriptionView() }
                    .tabItem { Label("New Entry", systemImage: "pill.circle.fill") }.tag(2)
            }
            .tint(.medoraPinkDeep)
            .onAppear { configureTabBarAppearance() }

            if showSplash {
                SplashView { showSplash = false }
                    .zIndex(1)
            }
        }
    }

    /// Gives the native tab bar a white background with pink selected
    /// icons/text, matching the rest of the theme (UITabBar doesn't
    /// pick up SwiftUI colors automatically, so this is done via
    /// UIKit's appearance proxy).
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white

        let selectedColor = UIColor(Color.medoraPinkDeep)
        let normalColor = UIColor(Color.medoraGraySubtle)

        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
