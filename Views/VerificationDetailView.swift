import SwiftUI

struct VerificationDetailView: View {
    let prescription: Prescription
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text(prescription.patientName)
                        .font(.title2).bold()
                    Text(prescription.medicineName)
                        .font(.subheadline).foregroundStyle(.secondary)
                    RiskBadge(level: prescription.riskLevel)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 16))
                
                // Warning banner
                if prescription.riskLevel == .high || prescription.riskLevel == .critical {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundStyle(.red)
                        Text("Safety concerns detected — review before dispensing")
                            .font(.caption).bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.red.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 12))
                }
                
                // Prescription details
                GroupBox("Prescription Details") {
                    DetailRow(icon: "person", label: "Patient", value: prescription.patientName)
                    DetailRow(icon: "pills", label: "Medicine", value: prescription.medicineName)
                    DetailRow(icon: "number", label: "Dosage", value: prescription.dosage)
                    DetailRow(icon: "clock", label: "Frequency", value: prescription.frequency)
                    DetailRow(icon: "figure.stand", label: "Age Group", value: prescription.ageGroup.rawValue)
                    DetailRow(icon: "calendar", label: "Date", value: prescription.date.formatted(date: .long, time: .omitted))
                    if !prescription.notes.isEmpty {
                        DetailRow(icon: "note.text", label: "Notes", value: prescription.notes)
                    }
                }
                
                // Verification results
                if !prescription.aiSummary.isEmpty {
                    GroupBox("AI Verification") {
                        VStack(alignment: .leading, spacing: 12) {
                            if !prescription.interactionWarnings.isEmpty {
                                WarningBox(icon: "exclamationmark.triangle", label: "Drug Interactions", text: prescription.interactionWarnings, color: .orange)
                            }
                            if !prescription.duplicateWarning.isEmpty && prescription.duplicateWarning != "No duplicate medications found." {
                                WarningBox(icon: "doc.on.doc", label: "Duplicate Check", text: prescription.duplicateWarning, color: .orange)
                            }
                            if !prescription.dosageAssessment.isEmpty {
                                WarningBox(icon: "scalemass", label: "Dosage Assessment", text: prescription.dosageAssessment, color: prescription.riskLevel == .low ? .green : .orange)
                            }
                            if !prescription.alternativeSuggestions.isEmpty && prescription.alternativeSuggestions != "No alternative suggestions needed." {
                                WarningBox(icon: "arrow.triangle.swap", label: "Safer Alternatives", text: prescription.alternativeSuggestions, color: .blue)
                            }
                            
                            // AI Summary
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Summary").font(.caption).foregroundStyle(.secondary)
                                Text(prescription.aiSummary).font(.callout)
                            }
                            .padding()
                            .background(.quaternary)
                            .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Verification Yet",
                        systemImage: "hourglass",
                        description: Text("Verification runs automatically after saving. Pull to refresh.")
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RiskBadge: View {
    let level: RiskLevel
    
    var color: Color {
        switch level {
        case .unknown: return .gray
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
    
    var icon: String {
        level == .critical || level == .high ? "exclamationmark.shield.fill" : "checkmark.shield.fill"
    }
    
    var body: some View {
        Label(level == .unknown ? "Not Verified" : "\(level.rawValue) Risk", systemImage: icon)
            .font(.caption).bold()
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(.capsule)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 20).foregroundStyle(.secondary)
            Text(label).font(.caption).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
            Text(value.isEmpty ? "—" : value).font(.subheadline)
            Spacer()
        }
    }
}

struct WarningBox: View {
    let icon: String
    let label: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color).font(.callout)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline).bold()
                Text(text).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }
}
