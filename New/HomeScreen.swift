import SwiftUI

// MARK: - Data Models

struct AlertItem: Identifiable {
    let id: Int
    let type: String
    let title: String
    let desc: String
    let meds: [String]
    let severity: Severity
    let time: String

    enum Severity: String {
        case high
        case medium
        case low
    }
}

struct MedItem: Identifiable {
    let id = UUID()
    let name: String
    let dose: String
    let freq: String
    let category: String
    let safe: Bool
}

let ALERTS: [AlertItem] = [
    AlertItem(
        id: 1,
        type: "interaction",
        title: "Drug Interaction Detected",
        desc: "Warfarin + Ibuprofen increases bleeding risk significantly.",
        meds: ["Warfarin 5mg", "Ibuprofen 400mg"],
        severity: .high,
        time: "2h ago"
    ),
    AlertItem(
        id: 2,
        type: "duplicate",
        title: "Duplicate Medication",
        desc: "Omeprazole appears twice across your active prescriptions.",
        meds: ["Omeprazole 20mg", "Prilosec 20mg"],
        severity: .medium,
        time: "1d ago"
    ),
    AlertItem(
        id: 3,
        type: "dosage",
        title: "Dosage Advisory",
        desc: "Metformin dose exceeds recommended limit for age 68+.",
        meds: ["Metformin 1000mg"],
        severity: .medium,
        time: "3d ago"
    ),
]

let ACTIVE_MEDS: [MedItem] = [
    MedItem(name: "Lisinopril", dose: "10mg", freq: "Once daily", category: "ACE Inhibitor", safe: true),
    MedItem(name: "Atorvastatin", dose: "40mg", freq: "Nightly", category: "Statin", safe: true),
    MedItem(name: "Metformin", dose: "1000mg", freq: "Twice daily", category: "Antidiabetic", safe: false),
    MedItem(name: "Aspirin", dose: "81mg", freq: "Once daily", category: "Antiplatelet", safe: true),
]

// MARK: - HomeScreen

struct HomeScreen: View {
    var onNavigate: ((Tab) -> Void)?
    @State private var expandedAlert: Int? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GOOD MORNING")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(AppTheme.slate400)
                                .tracking(1)
                            Text("Sarah Mitchell")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.slate900)
                        }
                        Spacer()
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.teal700)
                                    .frame(width: 40, height: 40)
                                Text("SM")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Circle()
                                .fill(AppTheme.rose500)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .offset(x: 2, y: -2)
                        }
                    }

                    // Quick stats
                    HStack(spacing: 12) {
                        StatCard(label: "Active Meds", value: "4", color: AppTheme.teal700, bg: AppTheme.teal50)
                        StatCard(label: "Alerts", value: "3", color: AppTheme.rose600, bg: AppTheme.rose50)
                        StatCard(label: "Verified", value: "12", color: AppTheme.emerald600, bg: AppTheme.emerald50)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 20)
                .background(Color.white)

                // Safety score card
                SafetyScoreCard()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                // Alerts section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Alerts")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.slate800)
                        Spacer()
                        Text("3 active")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.teal700)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 10) {
                        ForEach(ALERTS) { alert in
                            AlertCard(
                                alert: alert,
                                expanded: expandedAlert == alert.id,
                                onToggle: {
                                    expandedAlert = expandedAlert == alert.id ? nil : alert.id
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)

                // Active medications
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Active Medications")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.slate800)
                        Spacer()
                        Text("4 total")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.teal700)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 8) {
                        ForEach(ACTIVE_MEDS) { med in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(med.safe ? AppTheme.emerald50 : AppTheme.rose50)
                                        .frame(width: 40, height: 40)
                                    Text("💊")
                                        .font(.system(size: 18))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 8) {
                                        Text(med.name)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(AppTheme.slate800)
                                        if !med.safe {
                                            Text("ALERT")
                                                .font(.system(size: 9, weight: .semibold))
                                                .foregroundColor(AppTheme.rose600)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AppTheme.rose50)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Text("\(med.dose) · \(med.freq)")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(AppTheme.slate400)
                                }
                                Spacer()
                                Text(med.category)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(AppTheme.slate400)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.slate100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .background(AppTheme.slate50)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let label: String
    let value: String
    let color: Color
    let bg: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.slate500)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(bg)
        )
    }
}

// MARK: - Safety Score Card

struct SafetyScoreCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PRESCRIPTION SAFETY SCORE")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.teal300)
                        .tracking(1)
                    HStack(alignment: .bottom, spacing: 8) {
                        Text("72")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("/100")
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundColor(AppTheme.teal300)
                            .padding(.bottom, 8)
                    }
                    Text("3 issues require your attention")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.teal200)
                }
                Spacer()
                ScoreRing(score: 72)
            }

            // Score bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.teal900)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.amber400, AppTheme.teal300],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.72)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("RISK")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(AppTheme.teal400)
                    Spacer()
                    Text("SAFE")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(AppTheme.teal400)
                }
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppTheme.teal900, AppTheme.teal700],
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Score Ring

struct ScoreRing: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 6)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [AppTheme.amber500, AppTheme.teal400]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
    }
}

// MARK: - Alert Card

struct AlertCard: View {
    let alert: AlertItem
    let expanded: Bool
    let onToggle: () -> Void

    private var config: (bg: Color, border: Color, icon: String, tag: Color, tagBg: Color, label: String) {
        switch alert.severity {
        case .high:
            return (AppTheme.rose50, Color(red: 0.996, green: 0.804, blue: 0.824), "⚠️", AppTheme.rose600, AppTheme.rose100, "HIGH RISK")
        case .medium:
            return (AppTheme.amber50, Color(red: 0.992, green: 0.906, blue: 0.541), "⚡", AppTheme.amber600, AppTheme.amber100, "MODERATE")
        case .low:
            return (AppTheme.emerald50, Color(red: 0.655, green: 0.953, blue: 0.816), "ℹ️", AppTheme.emerald600, AppTheme.emerald100, "LOW")
        }
    }

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Text(config.icon)
                        .font(.system(size: 18))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(alert.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.slate800)
                            Text(config.label)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(config.tag)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(config.tagBg)
                                .clipShape(Capsule())
                        }
                        Text(alert.desc)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.slate500)
                            .multilineTextAlignment(.leading)

                        if expanded {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("MEDICATIONS INVOLVED")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(AppTheme.slate500)
                                    .tracking(1)
                                HStack(spacing: 6) {
                                    ForEach(alert.meds, id: \.self) { m in
                                        Text(m)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(AppTheme.slate700)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(AppTheme.slate200, lineWidth: 1)
                                            )
                                    }
                                }
                                HStack(spacing: 8) {
                                    Button {
                                        // alternatives
                                    } label: {
                                        Text("Get Alternatives")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(AppTheme.teal700)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Button {
                                        // dismiss
                                    } label: {
                                        Text("Dismiss")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.slate600)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.slate200, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top, 12)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(alert.time)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(AppTheme.slate400)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.slate400)
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                    }
                }
            }
            .padding(16)
            .background(config.bg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(config.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeScreen()
}
