import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var vm = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dashboard").font(.title).bold()
                    Text("Prescription verification overview").font(.subheadline).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(icon: "pills", label: "Total", value: "\(vm.total)", color: .teal)
                    StatCard(icon: "checkmark.shield", label: "Verified", value: "\(vm.verified)", color: .green)
                    StatCard(icon: "clock", label: "Pending", value: "\(vm.pending)", color: .orange)
                    StatCard(icon: "exclamationmark.triangle", label: "Flagged", value: "\(vm.flagged)", color: .red)
                }

                if !vm.recent.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Prescriptions").font(.headline)
                        ForEach(vm.recent) { rx in
                            NavigationLink(destination: VerificationDetailView(prescription: rx)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(rx.patientName).font(.subheadline).bold()
                                        Text(rx.medicineName).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    StatusBadge(status: rx.status)
                                }.padding(.vertical, 4)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                }

                if vm.isLoading { ProgressView() }
            }.padding()
        }
        .navigationTitle("Medora")
        .onAppear { vm.load(context: context) }
        .refreshable { vm.load(context: context) }
    }
}

struct StatCard: View {
    let icon, label, value: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.title).bold().fontDesign(.rounded)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }
}

struct StatusBadge: View {
    let status: PrescriptionStatus
    var color: Color {
        switch status {
        case .pending: .orange; case .verified: .green; case .flagged: .red; case .resolved: .blue
        }
    }
    var body: some View {
        Text(status.rawValue).font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.15)).foregroundStyle(color)
            .clipShape(.capsule)
    }
}
