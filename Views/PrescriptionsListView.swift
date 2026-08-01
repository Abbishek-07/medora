import SwiftUI
import SwiftData

struct PrescriptionsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Prescription.date, order: .reverse) private var all: [Prescription]
    @State private var search = ""
    @State private var filter: PrescriptionStatus?

    var filtered: [Prescription] {
        all.filter { rx in
            (search.isEmpty || rx.patientName.localizedCaseInsensitiveContains(search) || rx.medicineName.localizedCaseInsensitiveContains(search)) &&
            (filter == nil || rx.status == filter)
        }
    }

    var body: some View {
        List {
            if filtered.isEmpty {
                ContentUnavailableView("No Prescriptions", systemImage: "pills",
                    description: Text(all.isEmpty ? "Add your first prescription" : "No results match your filters"))
            } else {
                ForEach(filtered) { rx in
                    NavigationLink(destination: VerificationDetailView(prescription: rx)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(rx.patientName).font(.subheadline).bold()
                            Text(rx.medicineName).font(.caption).foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Text(rx.date, style: .date).font(.caption2).foregroundStyle(.secondary)
                                StatusBadge(status: rx.status)
                            }
                        }.padding(.vertical, 4)
                    }
                }.onDelete { idx in
                    for i in idx { context.delete(filtered[i]) }
                    try? context.save()
                }
            }
        }
        .searchable(text: $search, prompt: "Search by patient or medicine")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Status", selection: $filter) {
                    Text("All").tag(nil as PrescriptionStatus?)
                    ForEach(PrescriptionStatus.allCases, id: \.self) { Text($0.rawValue).tag($0 as PrescriptionStatus?) }
                }.pickerStyle(.menu)
            }
        }
        .navigationTitle("Prescriptions")
    }
}
