import SwiftUI

// MARK: - Data

let CONDITIONS = ["Type 2 Diabetes", "Hypertension", "Atrial Fibrillation", "Hyperlipidemia"]
let ALLERGIES = ["Penicillin", "Sulfonamides", "Latex"]

// MARK: - ProfileScreen

struct ProfileScreen: View {
    let onLogout: (() -> Void)?
    @State private var notifOn = true
    @State private var biometricOn = true
    @State private var autoSaveOn = false

    init(onLogout: (() -> Void)? = nil) {
        self.onLogout = onLogout
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("ACCOUNT")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.slate400)
                        .tracking(1)
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.slate900)
                        .padding(.top, 2)

                    // Avatar card
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.teal900, AppTheme.teal700],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            Text("SM")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sarah Mitchell")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.slate900)
                            Text("sarah.mitchell@email.com")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(AppTheme.slate400)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(AppTheme.emerald400)
                                    .frame(width: 8, height: 8)
                                Text("VERIFIED PATIENT")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(AppTheme.emerald600)
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

                VStack(alignment: .leading, spacing: 0) {
                    // Medical Profile
                    SectionView(title: "Medical Profile") {
                        InfoRow(label: "Date of Birth", value: "March 14, 1958 (Age 68)")
                        InfoRow(label: "Blood Type", value: "B+")
                        InfoRow(label: "Weight", value: "68 kg")
                        InfoRow(label: "Primary Care Physician", value: "Dr. James Porter")
                    }

                    // Conditions
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Conditions", count: CONDITIONS.count)
                        HStack(spacing: 8) {
                            ForEach(CONDITIONS, id: \.self) { c in
                                Text(c)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.teal700)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.teal50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppTheme.teal100, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 16)

                    // Allergies
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Known Allergies", count: ALLERGIES.count)
                        HStack(spacing: 8) {
                            ForEach(ALLERGIES, id: \.self) { a in
                                Text(a)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.rose600)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.rose50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppTheme.rose100, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 16)

                    // Settings
                    SectionView(title: "Settings") {
                        ToggleRow(label: "Interaction Alerts", sub: "Push notifications for drug interactions", value: $notifOn)
                        ToggleRow(label: "Biometric Lock", sub: "Face ID / Touch ID access", value: $biometricOn)
                        ToggleRow(label: "Auto-save Prescriptions", sub: "Save verified Rx automatically", value: $autoSaveOn)
                    }

                    // Privacy & Data
                    SectionView(title: "Privacy & Data") {
                        InfoRow(label: "Processing", value: "On-device only", accent: true)
                        InfoRow(label: "Data Storage", value: "SwiftData (local)", accent: true)
                        InfoRow(label: "External Sharing", value: "None", accent: true)
                    }

                    // Account actions
                    VStack(spacing: 8) {
                        Button {
                            // export records
                        } label: {
                            Text("Export Medical Records")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.teal700)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.teal50)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.teal100, lineWidth: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            onLogout?()
                        } label: {
                            Text("Sign Out")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.rose600)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.rose50)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.rose100, lineWidth: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 8)

                    // App info
                    VStack(spacing: 2) {
                        Text("MEDORA v2.1.0")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.teal700)
                        Text("Smart Prescription Verification")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.slate400)
                        Text("All data processed on-device. Your privacy is protected.")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.slate300)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(AppTheme.slate50)
    }
}

// MARK: - Helper Views

struct SectionHeader: View {
    let title: String
    let count: Int?

    init(title: String, count: Int? = nil) {
        self.title = title
        self.count = count
    }

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.slate500)
                .tracking(1)
            Spacer()
            if let count {
                Text("\(count) total")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.teal600)
            }
        }
        .padding(.bottom, 8)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: title)
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.slate100, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        }
        .padding(.bottom, 16)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let accent: Bool

    init(label: String, value: String, accent: Bool = false) {
        self.label = label
        self.value = value
        self.accent = accent
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.slate400)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(accent ? AppTheme.teal700 : AppTheme.slate800)
                .fontDesign(accent ? .monospaced : .default)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(AppTheme.slate50)
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}

struct ToggleRow: View {
    let label: String
    let sub: String
    @Binding var value: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.slate700)
                Text(sub)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.slate400)
            }
            Spacer()
            Toggle("", isOn: $value)
                .labelsHidden()
                .tint(AppTheme.teal700)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(AppTheme.slate50)
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}

#Preview {
    ProfileScreen(onLogout: {})
}
