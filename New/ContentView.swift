import SwiftUI

// MARK: - Models

enum Tab: String {
    case home = "home"
    case scan = "scan"
    case history = "history"
    case chat = "chat"
    case profile = "profile"
}

enum ScanResultState {
    case none
    case results
}

// MARK: - Theme

enum AppTheme {
    static let teal950 = Color(red: 0.016, green: 0.169, blue: 0.176)
    static let teal900 = Color(red: 0.027, green: 0.231, blue: 0.243)
    static let teal800 = Color(red: 0.051, green: 0.341, blue: 0.361)
    static let teal700 = Color(red: 0.055, green: 0.451, blue: 0.467)
    static let teal600 = Color(red: 0.059, green: 0.561, blue: 0.580)
    static let teal500 = Color(red: 0.075, green: 0.678, blue: 0.702)
    static let teal400 = Color(red: 0.196, green: 0.784, blue: 0.808)
    static let teal300 = Color(red: 0.35, green: 0.82, blue: 0.84)
    static let teal200 = Color(red: 0.659, green: 0.929, blue: 0.941)
    static let teal100 = Color(red: 0.831, green: 0.965, blue: 0.973)
    static let teal50 = Color(red: 0.929, green: 0.984, blue: 0.988)

    static let amber600 = Color(red: 0.851, green: 0.467, blue: 0.024)
    static let amber500 = Color(red: 0.961, green: 0.620, blue: 0.043)
    static let amber400 = Color(red: 0.996, green: 0.749, blue: 0.141)
    static let amber100 = Color(red: 0.996, green: 0.953, blue: 0.780)
    static let amber50 = Color(red: 1.0, green: 0.984, blue: 0.922)

    static let rose600 = Color(red: 0.882, green: 0.114, blue: 0.282)
    static let rose500 = Color(red: 0.957, green: 0.247, blue: 0.369)
    static let rose200 = Color(red: 0.996, green: 0.804, blue: 0.824)
    static let rose100 = Color(red: 1.0, green: 0.894, blue: 0.902)
    static let rose50 = Color(red: 1.0, green: 0.945, blue: 0.949)

    static let emerald700 = Color(red: 0.016, green: 0.51, blue: 0.353)
    static let emerald600 = Color(red: 0.02, green: 0.588, blue: 0.412)
    static let emerald500 = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let emerald400 = Color(red: 0.16, green: 0.82, blue: 0.55)
    static let emerald200 = Color(red: 0.655, green: 0.953, blue: 0.816)
    static let emerald100 = Color(red: 0.82, green: 0.98, blue: 0.898)
    static let emerald50 = Color(red: 0.925, green: 0.992, blue: 0.961)

    static let slate50 = Color(red: 0.973, green: 0.980, blue: 0.988)
    static let slate100 = Color(red: 0.945, green: 0.961, blue: 0.976)
    static let slate200 = Color(red: 0.886, green: 0.910, blue: 0.941)
    static let slate300 = Color(red: 0.796, green: 0.835, blue: 0.882)
    static let slate400 = Color(red: 0.580, green: 0.639, blue: 0.722)
    static let slate500 = Color(red: 0.392, green: 0.455, blue: 0.545)
    static let slate600 = Color(red: 0.278, green: 0.333, blue: 0.412)
    static let slate700 = Color(red: 0.200, green: 0.251, blue: 0.333)
    static let slate800 = Color(red: 0.118, green: 0.161, blue: 0.231)
    static let slate900 = Color(red: 0.059, green: 0.090, blue: 0.165)
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var loggedIn = false
    @State private var activeTab: Tab = .home
    @State private var scanResult: ScanResultState = .none

    var body: some View {
        ZStack {
            AppTheme.slate200
                .ignoresSafeArea()

            // iPhone shell
            VStack(spacing: 0) {
                // Status bar
                StatusBar()

                ZStack {
                    // Screen content
                    if !loggedIn {
                        LoginScreen(onLogin: { loggedIn = true })
                    } else {
                        Group {
                            switch activeTab {
                            case .home:
                                HomeScreen(onNavigate: { tab in
                                    activeTab = tab
                                })
                            case .scan:
                                ScanScreen(
                                    scanResult: scanResult,
                                    onScanComplete: { scanResult = .results },
                                    onNewScan: { scanResult = .none }
                                )
                            case .history:
                                HistoryScreen()
                            case .chat:
                                ChatScreen()
                            case .profile:
                                ProfileScreen(onLogout: {
                                    loggedIn = false
                                    activeTab = .home
                                })
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Tab bar
                if loggedIn {
                    TabBar(activeTab: $activeTab)
                }
            }
            .frame(width: 390, height: 844)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 48))
            .shadow(color: Color.black.opacity(0.22), radius: 80, x: 0, y: 32)
            .overlay(
                RoundedRectangle(cornerRadius: 48)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )

            // Dynamic island
            VStack {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 18.5)
                        .fill(Color.black)
                        .frame(width: 126, height: 37)
                        .padding(.top, 12)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: 390, height: 844)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Status Bar

struct StatusBar: View {
    var body: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.slate800)

            Spacer()

            HStack(spacing: 6) {
                // Signal bars
                HStack(spacing: 1.5) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppTheme.slate800)
                        .frame(width: 3, height: 3)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppTheme.slate800)
                        .frame(width: 3, height: 4)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppTheme.slate800)
                        .frame(width: 3, height: 6)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppTheme.slate300)
                        .frame(width: 3, height: 8)
                }

                // WiFi
                Image(systemName: "wifi")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.slate800)

                // Battery
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(AppTheme.slate800.opacity(0.35), lineWidth: 1)
                        .frame(width: 22, height: 11)
                        .overlay(
                            HStack {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(AppTheme.slate800)
                                    .frame(width: 15, height: 8)
                                Spacer()
                            }
                            .padding(1.5)
                        )
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppTheme.slate800.opacity(0.4))
                        .frame(width: 1.5, height: 4)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 14)
        .padding(.bottom, 4)
        .background(Color.white)
    }
}

// MARK: - Tab Bar

struct TabBar: View {
    @Binding var activeTab: Tab

    var body: some View {
        HStack {
            ForEach([
                (Tab.home, "Home", AnyView(HomeIcon(active: activeTab == .home))),
                (Tab.scan, "Verify", AnyView(ScanIcon(active: activeTab == .scan))),
                (Tab.history, "History", AnyView(HistoryIcon(active: activeTab == .history))),
                (Tab.chat, "AI Chat", AnyView(ChatIcon(active: activeTab == .chat))),
                (Tab.profile, "Profile", AnyView(ProfileIcon(active: activeTab == .profile))),
            ], id: \.0) { tab, label, icon in
                Button {
                    activeTab = tab
                } label: {
                    VStack(spacing: 2) {
                        icon
                        Text(label)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(activeTab == tab ? AppTheme.teal700 : AppTheme.slate400)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(AppTheme.slate100)
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .top)
        )
    }
}

// MARK: - Tab Icons

struct HomeIcon: View {
    let active: Bool
    var body: some View {
        let c = active ? AppTheme.teal700 : AppTheme.slate400
        ZStack {
            Image(systemName: "house.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(active ? AppTheme.teal100 : .clear)
            Image(systemName: "house")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(c)
        }
        .frame(width: 22, height: 22)
    }
}

struct ScanIcon: View {
    let active: Bool
    var body: some View {
        let c = active ? AppTheme.teal700 : AppTheme.slate400
        ZStack {
            Image(systemName: "viewfinder")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(c)
            Image(systemName: "plus")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(c)
        }
        .frame(width: 22, height: 22)
    }
}

struct HistoryIcon: View {
    let active: Bool
    var body: some View {
        let c = active ? AppTheme.teal700 : AppTheme.slate400
        Image(systemName: "clock")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(c)
            .frame(width: 22, height: 22)
    }
}

struct ChatIcon: View {
    let active: Bool
    var body: some View {
        let c = active ? AppTheme.teal700 : AppTheme.slate400
        ZStack {
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 18))
                .foregroundColor(active ? AppTheme.teal100 : .clear)
            Image(systemName: "bubble.left")
                .font(.system(size: 18))
                .foregroundColor(c)
        }
        .frame(width: 22, height: 22)
    }
}

struct ProfileIcon: View {
    let active: Bool
    var body: some View {
        let c = active ? AppTheme.teal700 : AppTheme.slate400
        ZStack {
            Image(systemName: "person.fill")
                .font(.system(size: 18))
                .foregroundColor(active ? AppTheme.teal100 : .clear)
            Image(systemName: "person")
                .font(.system(size: 18))
                .foregroundColor(c)
        }
        .frame(width: 22, height: 22)
    }
}

#Preview {
    ContentView()
}
