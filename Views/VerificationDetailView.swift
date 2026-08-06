//
//  VerificationDetailView.swift
//  Medora
//
//  Same Prescription data, RiskLevel logic, and verification fields
//  as before — only the visual layer changed. GroupBox now renders as
//  a white pink-shadowed card via a custom GroupBoxStyle, so the API
//  (GroupBox("Title") { ... }) didn't need to change at the call sites.
//

import SwiftUI

struct VerificationDetailView: View {
    let prescription: Prescription

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 6) {
                    Text(prescription.patientName)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.medoraInk)
                    Text(prescription.medicineName)
                        .font(.subheadline)
                        .foregroundStyle(Color.medoraGraySubtle)
                    RiskBadge(level: prescription.riskLevel)
                        .padding(.top, 2)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .medoraCard()

                // Warning banner
                if prescription.riskLevel == .high || prescription.riskLevel == .critical {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundStyle(Color.medoraFlagged)
                        Text("Safety concerns detected — review before dispensing")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.medoraInk)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14).fill(Color.medoraFlagged.opacity(0.1))
                    )
                }

                // Prescription details
                GroupBox("Prescription Details") {
                    VStack(spacing: 10) {
                        DetailRow(icon: "person.fill", label: "Patient", value: prescription.patientName)
                        DetailRow(icon: "pills.fill", label: "Medicine", value: prescription.medicineName)
                        DetailRow(icon: "number", label: "Dosage", value: prescription.dosage)
                        DetailRow(icon: "clock.fill", label: "Frequency", value: prescription.frequency)
                        DetailRow(icon: "figure.stand", label: "Age Group", value: prescription.ageGroup.rawValue)
                        DetailRow(icon: "calendar", label: "Date", value: prescription.date.formatted(date: .long, time: .omitted))
                        if !prescription.notes.isEmpty {
                            DetailRow(icon: "note.text", label: "Notes", value: prescription.notes)
                        }
                    }
                }

                // Verification results
                if !prescription.interactionWarnings.isEmpty ||
                    !prescription.dosageAssessment.isEmpty ||
                    !prescription.alternativeSuggestions.isEmpty ||
                    !prescription.duplicateWarning.isEmpty {
                    GroupBox("Verification") {
                        VStack(alignment: .leading, spacing: 12) {
                            if !prescription.interactionWarnings.isEmpty {
                                WarningBox(icon: "exclamationmark.triangle.fill", label: "Drug Interactions", text: prescription.interactionWarnings, color: .medoraPending)
                            }
                            if !prescription.duplicateWarning.isEmpty && prescription.duplicateWarning != "No duplicate medications found." {
                                WarningBox(icon: "doc.on.doc.fill", label: "Duplicate Check", text: prescription.duplicateWarning, color: .medoraPending)
                            }
                            if !prescription.dosageAssessment.isEmpty {
                                WarningBox(icon: "scalemass.fill", label: "Dosage Assessment", text: prescription.dosageAssessment, color: prescription.riskLevel == .low ? .medoraVerified : .medoraPending)
                            }
                            if !prescription.alternativeSuggestions.isEmpty && prescription.alternativeSuggestions != "No alternative suggestions needed." {
                                WarningBox(icon: "arrow.triangle.swap", label: "Safer Alternatives", text: prescription.alternativeSuggestions, color: .medoraResolved)
                            }
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
        .background(LinearGradient.medoraBackground.ignoresSafeArea())
        .groupBoxStyle(MedoraGroupBoxStyle())
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Custom GroupBox style (white card, matches medoraCard)

struct MedoraGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.medoraInk)
            configuration.content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.medoraPink.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}

struct RiskBadge: View {
    let level: RiskLevel

    var color: Color {
        switch level {
        case .unknown:  return .medoraGraySubtle
        case .low:      return .medoraVerified
        case .medium:   return .medoraPending
        case .high:     return .medoraFlagged
        case .critical: return .purple
        }
    }

    var icon: String {
        level == .critical || level == .high ? "exclamationmark.shield.fill" : "checkmark.shield.fill"
    }

    var body: some View {
        Label(level == .unknown ? "Not Verified" : "\(level.rawValue) Risk", systemImage: icon)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
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
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(Color.medoraPinkDeep)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.medoraGraySubtle)
                .frame(width: 70, alignment: .leading)
            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .foregroundStyle(Color.medoraInk)
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
                .foregroundStyle(color)
                .font(.callout)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.medoraInk)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(Color.medoraGraySubtle)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.08))
        )
    }
}
