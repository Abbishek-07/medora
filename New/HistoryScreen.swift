import SwiftUI

// MARK: - Models

struct RxHistory: Identifiable {
    let id: Int
    let date: String
    let doctor: String
    let hospital: String
    let meds: [String]
    let issues: Int
    let score: Int
    let status: String
}

let HISTORY: [RxHistory] = [
    RxHistory(id: 1, date: "Jul 28, 2026", doctor: "Dr. James Porter", hospital: "St. Mary Medical Center", meds: ["Warfarin 5mg", "Ibuprofen 400mg", "Omeprazole 20mg"], issues: 2, score: 62, status: "flagged"),
    RxHistory(id: 2, date: "Jul 15, 2026", doctor: "Dr. Linda Chen", hospital: "City Health Clinic", meds: ["Omeprazole 20mg", "Pantoprazole 40mg"], issues: 1, score: 74, status: "flagged"),
    RxHistory(id: 3, date: "Jun 30, 2026", doctor: "Dr. Raj Patel", hospital: "Sunrise Family Practice", meds: ["Lisinopril 10mg", "Amlodipine 5mg"], issues: 0, score: 98, status: "clear"),
    RxHistory(id: 4, date: "Jun 12, 2026", doctor: "Dr. Sarah Kim", hospital: "Metro Cardiology", meds: ["Atorvastatin 40mg", "Aspirin 81mg", "Clopidogrel 75mg"], issues: 0, score: 95, status: "clear"),
    RxHistory(id: 5, date: "May 20, 2026", doctor: "Dr. James Porter", hospital: "St. Mary Medical Center", meds: ["Metformin 1000mg", "Glipizide 5mg"], issues: 1, score: 71, status: "flagged"),
]

// MARK: - HistoryScreen

struct HistoryScreen: View {
    enum Filter: String {
        case all
        case flagged
        case clear
    }

    @State private var filter: Filter = .all
    @State private var expanded: Int? = nil

    private var filtered: [RxHistory] {
        HISTORY.filter { h in
            filter == .all || h.status == filter.rawValue
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("PRESCRIPTION")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.slate400)
                        .tracking(1)
                    Text("History")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.slate900)
                        .padding(.top, 2)

                    // Summary row
                    HStack(spacing: 16) {
                        SummaryItem(label: "Total", value: "12", color: AppTheme.teal700)
                        SummaryItem(label: "Flagged", value: "5", color: AppTheme.rose600)
                        SummaryItem(label: "Clear", value: "7", color: AppTheme.emerald600)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

                // Filter tabs
                HStack(spacing: 4) {
                    ForEach([Filter.all, .flagged, .clear], id: \.self) { f in
                        Button {
                            filter = f
                        } label: {
                            Text(f.rawValue.capitalized)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(filter == f ? AppTheme.teal700 : AppTheme.slate400)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(filter == f ? Color.white : Color.clear)
                                        .shadow(color: filter == f ? Color.black.opacity(0.08) : .clear, radius: 4, x: 0, y: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(4)
                .background(AppTheme.slate100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Timeline
                VStack(spacing: 12) {
                    ForEach(filtered) { rx in
                        HistoryCard(
                            rx: rx,
                            expanded: expanded == rx.id,
                            onToggle: {
                                expanded = expanded == rx.id ? nil : rx.id
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .background(AppTheme.slate50)
    }
}

struct SummaryItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.slate400)
        }
    }
}

// MARK: - History Card

struct HistoryCard: View {
    let rx: RxHistory
    let expanded: Bool
    let onToggle: () -> Void

    private var scoreColor: Color {
        if rx.score >= 90 { return AppTheme.emerald600 }
        if rx.score >= 70 { return AppTheme.amber600 }
        return AppTheme.rose600
    }

    private var scoreBarColors: [Color] {
        if rx.score >= 90 { return [AppTheme.emerald500, Color(red: 0.204, green: 0.827, blue: 0.6)] }
        if rx.score >= 70 { return [AppTheme.amber500, Color(red: 0.984, green: 0.749, blue: 0.141)] }
        return [AppTheme.rose600, AppTheme.rose500]
    }

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                // Score bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.clear
                        LinearGradient(
                            colors: scoreBarColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * CGFloat(rx.score) / 100)
                    }
                }
                .frame(height: 4)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomTrailingRadius: 4
                    )
                )

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(rx.status == "clear" ? "✓ CLEAR" : "⚠ \(rx.issues) ISSUE\(rx.issues > 1 ? "S" : "")")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(rx.status == "clear" ? AppTheme.emerald600 : AppTheme.rose600)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(rx.status == "clear" ? AppTheme.emerald50 : AppTheme.rose50)
                                    .clipShape(Capsule())
                                Text(rx.date)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(AppTheme.slate400)
                            }
                            Text(rx.doctor)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.slate800)
                            Text(rx.hospital)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.slate400)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(rx.score)")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(scoreColor)
                            Text("SCORE")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(AppTheme.slate400)
                        }
                    }

                    // Meds pills
                    HStack(spacing: 6) {
                        ForEach(rx.meds, id: \.self) { m in
                            Text(m)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(AppTheme.slate500)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppTheme.slate50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.slate200, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top, 12)

                    if expanded {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(AppTheme.slate100)
                                .frame(height: 1)
                                .padding(.top, 16)

                            // Detail grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                DetailCell(label: "Medications", value: "\(rx.meds.count)")
                                DetailCell(label: "Safety Score", value: "\(rx.score)")
                                DetailCell(label: "Issues Found", value: "\(rx.issues)")
                                DetailCell(label: "Status", value: rx.status == "clear" ? "Safe" : "Review")
                            }
                            .padding(.top, 16)

                            HStack(spacing: 8) {
                                Button {
                                    // view report
                                } label: {
                                    Text("View Report")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.teal700)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(AppTheme.teal50)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppTheme.teal100, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button {
                                    // export pdf
                                } label: {
                                    Text("Export PDF")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.slate600)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppTheme.slate200, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.top, 12)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.slate100, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DetailCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.slate800)
            Text(label.uppercased())
                .font(.system(size: 9))
                .foregroundColor(AppTheme.slate400)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AppTheme.slate50)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HistoryScreen()
}
