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

    var filtered: [Prescription] {
        all.filter { rx in
            (search.isEmpty || rx.patientName.localizedCaseInsensitiveContains(search) || rx.medicineName.localizedCaseInsensitiveContains(search)) &&
            (filter == nil || rx.status == filter)
        }
    }

    var body: some View {
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
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(LinearGradient.medoraBackground.ignoresSafeArea())
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
        }
    }
}
