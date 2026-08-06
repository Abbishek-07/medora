import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var vm = DashboardViewModel()
    @State private var showChat = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main Dashboard Content
            ScrollView {
                VStack(spacing: 20) {
                    header

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        StatCard(icon: "pills.fill", label: "Total", value: "\(vm.total)", color: .medoraTotal)
                        StatCard(icon: "checkmark.shield.fill", label: "Verified", value: "\(vm.verified)", color: .medoraVerified)
                        StatCard(icon: "clock.fill", label: "Pending", value: "\(vm.pending)", color: .medoraPending)
                        StatCard(icon: "exclamationmark.triangle.fill", label: "Flagged", value: "\(vm.flagged)", color: .medoraFlagged)
                    }

                    if vm.isLoading {
                        ProgressView()
                            .tint(.medoraPinkDeep)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .padding(.bottom, 60) // Extra padding to prevent floating button overlapping content
            }
            .background(LinearGradient.medoraBackground.ignoresSafeArea())
            .navigationTitle("Medora")
            .onAppear { vm.load(context: context) }
            .refreshable { vm.load(context: context) }

            // Floating Chatbot Button (Bottom Right)
            Button(action: { showChat = true }) {
                ZStack {
                    Circle()
                        .fill(Color.medoraPinkDeep)
                        .frame(width: 58, height: 58)
                        .shadow(color: Color.medoraPinkDeep.opacity(0.35), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "sparkles.bubble.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24) // Adjust upward if floating above custom bottom tab bar
        }
        .sheet(isPresented: $showChat) {
            MedoraChatView()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.medoraInk)
                Text("Prescription verification overview")
                    .font(.subheadline)
                    .foregroundStyle(Color.medoraGraySubtle)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.medoraPinkSoft)
                    .frame(width: 42, height: 42)
                Image(systemName: "stethoscope")
                    .foregroundStyle(Color.medoraPinkDeep)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    @State private var appear = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Color.medoraInk)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.medoraGraySubtle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .medoraCard()
        .scaleEffect(appear ? 1 : 0.86)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                appear = true
            }
        }
    }
}

struct StatusBadge: View {
    let status: PrescriptionStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.medoraColor.opacity(0.15))
            .foregroundStyle(status.medoraColor)
            .clipShape(.capsule)
    }
}
