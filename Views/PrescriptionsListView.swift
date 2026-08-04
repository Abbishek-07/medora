import SwiftUI
import SwiftData

struct PrescriptionsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Prescription.date, order: .reverse) private var all: [Prescription]
    @State private var search = ""
    @State private var filter: PrescriptionStatus?
    @State private var showClearAllConfirm = false
    @State private var isSelecting = false
    @State private var selectedIDs: Set<Prescription.ID> = []
    @State private var showDeleteSelectedConfirm = false

    var filtered: [Prescription] {
        all.filter { rx in
            (search.isEmpty || rx.patientName.localizedCaseInsensitiveContains(search) || rx.medicineName.localizedCaseInsensitiveContains(search)) &&
            (filter == nil || rx.status == filter)
        }
    }

    var body: some View {
        List(selection: $selectedIDs) {
            if filtered.isEmpty {
                ContentUnavailableView("No Prescriptions", systemImage: "pills",
                    description: Text(all.isEmpty ? "Add your first prescription" : "No results match your filters"))
            } else {
                ForEach(filtered) { rx in
                    Group {
                        if isSelecting {
                            HStack {
                                rowContent(rx)
                            }
                        } else {
                            NavigationLink(destination: VerificationDetailView(prescription: rx)) {
                                rowContent(rx)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            context.delete(rx)
                            try? context.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            context.delete(rx)
                            try? context.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .environment(\.editMode, .constant(isSelecting ? .active : .inactive))
        .searchable(text: $search, prompt: "Search by patient or medicine")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Status", selection: $filter) {
                    Text("All").tag(nil as PrescriptionStatus?)
                    ForEach(PrescriptionStatus.allCases, id: \.self) { Text($0.rawValue).tag($0 as PrescriptionStatus?) }
                }.pickerStyle(.menu)
            }
            ToolbarItem(placement: .topBarLeading) {
                if isSelecting {
                    Button("Cancel") {
                        isSelecting = false
                        selectedIDs.removeAll()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isSelecting {
                    Button("Delete (\(selectedIDs.count))") {
                        showDeleteSelectedConfirm = true
                    }
                    .disabled(selectedIDs.isEmpty)
                    .foregroundStyle(.red)
                } else {
                    Menu {
                        Button {
                            isSelecting = true
                        } label: {
                            Label("Select", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive) {
                            showClearAllConfirm = true
                        } label: {
                            Label("Clear All History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .confirmationDialog("Delete all prescriptions? This cannot be undone.",
                             isPresented: $showClearAllConfirm,
                             titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                for rx in all { context.delete(rx) }
                try? context.save()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete \(selectedIDs.count) selected prescription(s)?",
                             isPresented: $showDeleteSelectedConfirm,
                             titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                let toDelete = filtered.filter { selectedIDs.contains($0.id) }
                for rx in toDelete { context.delete(rx) }
                try? context.save()
                selectedIDs.removeAll()
                isSelecting = false
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Prescriptions")
    }

    @ViewBuilder
    private func rowContent(_ rx: Prescription) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rx.patientName).font(.subheadline).bold()
            Text(rx.medicineName).font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Text(rx.date, style: .date).font(.caption2).foregroundStyle(.secondary)
                StatusBadge(status: rx.status)
            }
        }.padding(.vertical, 4)
    }
}
