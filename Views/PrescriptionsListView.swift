//
//  PrescriptionsListView.swift
//  Medora
//
//  Same @Query, search, filter and delete logic as before — the status
//  picker moved from the toolbar into pink filter chips (matches the
//  rest of the theme), and rows are now white cards instead of default
//  List rows.
//

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
<<<<<<< HEAD
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
=======
        VStack(spacing: 0) {
            filterChips

            List {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "No Prescriptions",
                        systemImage: "pills",
                        description: Text(all.isEmpty ? "Add your first prescription" : "No results match your filters")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filtered) { rx in
                        NavigationLink(destination: VerificationDetailView(prescription: rx)) {
                            PrescriptionRow(prescription: rx)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { idx in
                        for i in idx { context.delete(filtered[i]) }
                        try? context.save()
>>>>>>> main
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
<<<<<<< HEAD
        .environment(\.editMode, .constant(isSelecting ? .active : .inactive))
=======
        .background(LinearGradient.medoraBackground.ignoresSafeArea())
>>>>>>> main
        .searchable(text: $search, prompt: "Search by patient or medicine")
        .navigationTitle("Prescriptions")
        .animation(.easeInOut(duration: 0.25), value: filter)
        .animation(.easeInOut(duration: 0.25), value: search)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "All", isSelected: filter == nil, tint: .medoraPinkDeep) {
                    filter = nil
                }
                ForEach(PrescriptionStatus.allCases, id: \.self) { status in
                    FilterChip(title: status.rawValue, isSelected: filter == status, tint: status.medoraColor) {
                        filter = status
                    }
                }
            }
<<<<<<< HEAD
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
=======
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.medoraBlush)
    }
}

private struct PrescriptionRow: View {
    let prescription: Prescription

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(prescription.status.medoraColor.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: "pills.fill")
                    .foregroundStyle(prescription.status.medoraColor)
                    .font(.system(size: 17, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(prescription.patientName)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.medoraInk)
                Text(prescription.medicineName)
                    .font(.caption)
                    .foregroundStyle(Color.medoraGraySubtle)
                Text(prescription.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(Color.medoraGraySubtle)
            }

            Spacer()

            StatusBadge(status: prescription.status)
        }
        .padding(12)
        .medoraCard(padding: 0)
        .padding(4)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { action() }
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : tint)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(isSelected ? tint : tint.opacity(0.12)))
>>>>>>> main
        }
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
