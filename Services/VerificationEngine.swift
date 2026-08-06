import Foundation

// MARK: - Disease severity classification
// Mirrors how clinicians triage conditions: self-limiting/minor vs.
// chronic-but-manageable vs. acute/life-threatening.

enum DiseaseSeverity {
    case mild
    case moderate
    case severe
    case unknownCondition
}

enum DiseaseSeverityClassifier {

    private static let mildConditions: Set<String> = [
        "cold", "common cold", "flu", "fever", "headache", "migraine",
        "cough", "sore throat", "allergy", "allergies", "rhinitis",
        "mild fever", "seasonal allergy", "acidity", "indigestion",
        "minor cut", "minor burn", "constipation", "diarrhea", "nausea"
    ]

    private static let moderateConditions: Set<String> = [
        "hypertension", "high blood pressure", "diabetes", "type 2 diabetes",
        "asthma", "thyroid", "hypothyroidism", "hyperthyroidism",
        "arthritis", "migraine chronic", "gastritis", "ulcer",
        "urinary tract infection", "uti", "bronchitis", "pneumonia mild",
        "anemia", "depression", "anxiety"
    ]

    private static let severeConditions: Set<String> = [
        "cancer", "tumor", "chemotherapy", "heart failure", "cardiac arrest",
        "kidney failure", "renal failure", "liver failure", "hepatic failure",
        "stroke", "sepsis", "severe pneumonia", "covid severe",
        "myocardial infarction", "heart attack", "seizure", "epilepsy severe",
        "hiv", "aids", "tuberculosis", "organ transplant", "severe burn",
        "internal bleeding", "respiratory failure"
    ]

    static func classify(_ diagnosis: String) -> DiseaseSeverity {
        let text = diagnosis.lowercased().trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return .unknownCondition }

        if severeConditions.contains(where: { text.contains($0) }) {
            return .severe
        }
        if moderateConditions.contains(where: { text.contains($0) }) {
            return .moderate
        }
        if mildConditions.contains(where: { text.contains($0) }) {
            return .mild
        }
        return .unknownCondition
    }
}

struct VerificationEngine {
    let db: MedicineDatabaseService

    func verify(prescription: Prescription, existingPrescriptions: [Prescription]) -> VerificationResult {
        let medicineNames = prescription.medicineName
            .components(separatedBy: CharacterSet(charactersIn: "+,"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // 0. Which of these medicine names actually exist in our database?
        // A name we don't recognize (typo, non-existent drug, or garbage
        // input like "Petrol") must NEVER be treated as safe by default —
        // "we have no data" is not the same as "nothing is wrong". This gets
        // its own dedicated, prominent warning distinct from dosage notes.
        let unrecognizedMedicines = medicineNames.filter { db.findMedicine(named: $0) == nil }
        let unverifiedWarningText: String = unrecognizedMedicines.isEmpty ? "" :
            "NOT VERIFIED: " + unrecognizedMedicines.map { "\"\($0)\"" }.joined(separator: ", ")
            + (unrecognizedMedicines.count > 1 ? " were" : " was")
            + "Do not use — this could be harmful. Please double-check the spelling or verify manually before dispensing."

        // 1. Check interactions.
        // `findInteractions` returns general per-drug interaction info (e.g.
        // "avoid with alcohol") PLUS real multi-drug conflicts (e.g. duplicate
        // NSAIDs). The per-drug general notes are useful to SHOW, but they
        // aren't an actual detected conflict unless a second interacting
        // substance is actually present on this prescription.
        let interactions = db.findInteractions(for: medicineNames)
        let interactionText = interactions.isEmpty ? "No significant interactions detected." : interactions.joined(separator: "\n")

        // A single medicine, alone, cannot "interact" with itself — only
        // prescriptions with 2+ medicines can produce an actionable
        // interaction risk.
        let actionableInteractionCount = medicineNames.count > 1 ? interactions.count : 0

        // 2. Check duplicates — compares this prescription's medicines
        // against every OTHER existing prescription for the same patient
        // name, regardless of date. So prescribing the same medicine to the
        // same patient again (e.g. the next day) is expected to correctly
        // surface "previously prescribed on <date>" — that's this feature
        // working as intended, not a bug.
        var duplicateWarnings: [String] = []
        for existing in existingPrescriptions where existing.id != prescription.id {
            let existingMeds = existing.medicineName
                .components(separatedBy: CharacterSet(charactersIn: "+,"))
                .map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
            let currentMeds = medicineNames.map { $0.lowercased() }
            let overlap = currentMeds.filter { m in existingMeds.contains { $0.contains(m) || m.contains($0) } }
            if !overlap.isEmpty {
                duplicateWarnings.append("\(prescription.patientName) was previously prescribed \(existing.medicineName) on \(existing.date.formatted(date: .abbreviated, time: .omitted)).")
            }
        }
        let duplicateText = duplicateWarnings.isEmpty ? "No duplicate medications found." : duplicateWarnings.joined(separator: "\n")

        // 3. Age-based dosage.
        // A hard contraindication (e.g. aspirin in a child) must be treated
        // as a real, risk-elevating flag rather than just informational text.
        // Unrecognized medicines are skipped here (already covered by the
        // dedicated warning above) rather than double-reported.
        var dosageNotes: [String] = []
        var hasAgeContraindication = false
        for name in medicineNames {
            guard db.findMedicine(named: name) != nil else { continue }
            let warning = db.getAgeBasedWarnings(medicineName: name, ageGroup: prescription.ageGroup)
            if !warning.isEmpty {
                dosageNotes.append(warning)
                if warning.lowercased().contains("contraindicated")
                    || warning.lowercased().contains("reye") {
                    hasAgeContraindication = true
                }
            }
        }
        let dosageText: String
        if dosageNotes.isEmpty {
            dosageText = unrecognizedMedicines.isEmpty
                ? "Dosage appears appropriate for \(prescription.ageGroup.rawValue) age group."
                : "Could not assess — see 'Not Verified' warning above."
        } else {
            dosageText = dosageNotes.joined(separator: "\n")
        }

        // 4. Diagnosis <-> medicine match.
        // If a diagnosis was entered, check whether each prescribed medicine
        // is actually a recognized treatment for it (via Medicine.indications).
        var diagnosisNotes: [String] = []
        var diagnosisMismatch = false
        let trimmedDiagnosis = prescription.diagnosis.trimmingCharacters(in: .whitespaces)
        if !trimmedDiagnosis.isEmpty {
            let diagLower = trimmedDiagnosis.lowercased()
            for name in medicineNames {
                let indications = db.getIndications(for: name)
                guard !indications.isEmpty else { continue }
                let matches = indications.contains { ind in
                    let indLower = ind.lowercased()
                    return diagLower.contains(indLower) || indLower.contains(diagLower)
                }
                if matches {
                    diagnosisNotes.append("\(name) is a recognized treatment for \"\(trimmedDiagnosis)\".")
                } else {
                    diagnosisNotes.append("\(name) is not a typical treatment for \"\(trimmedDiagnosis)\" — please confirm this is intentional.")
                    diagnosisMismatch = true
                }
            }
        }
        let diagnosisText: String
        if !diagnosisNotes.isEmpty {
            diagnosisText = diagnosisNotes.joined(separator: "\n")
        } else if trimmedDiagnosis.isEmpty {
            diagnosisText = "No diagnosis provided."
        } else if !unrecognizedMedicines.isEmpty {
            diagnosisText = "Cannot verify — see 'Not Verified' warning above."
        } else {
            diagnosisText = "No indication data available to verify this medicine against \"\(trimmedDiagnosis)\"."
        }

        // 5. Alternatives
        var altNotes: [String] = []
        if actionableInteractionCount > 1 || !duplicateWarnings.isEmpty || hasAgeContraindication || diagnosisMismatch {
            for name in medicineNames {
                let alt = db.getAlternatives(for: name)
                if !alt.isEmpty { altNotes.append(alt) }
            }
        }
        let altText = altNotes.isEmpty ? "No alternative suggestions needed." : altNotes.joined(separator: "\n")

        // 6. Classify condition severity from the diagnosis field
        let conditionSeverity = DiseaseSeverityClassifier.classify(prescription.diagnosis)

        // 7. Determine risk level.
        //    - Hard age contraindication or a severe underlying condition -> critical.
        //    - An unrecognized/unverifiable medicine -> high. We simply
        //      cannot certify an unknown substance as safe, and this should
        //      surface the same "review before dispensing" banner as any
        //      other serious concern.
        //    - Medicine doesn't match the diagnosis -> high.
        //    - Real multi-drug conflicts / repeated duplicates -> high.
        //    - Any actionable interaction, a duplicate, or a moderate condition -> medium.
        //    - Otherwise (single known-safe drug, no conflicts, no mismatch) -> low.
        var riskLevel: RiskLevel

        if hasAgeContraindication || conditionSeverity == .severe {
            riskLevel = .critical
        } else if !unrecognizedMedicines.isEmpty {
            riskLevel = .high
        } else if diagnosisMismatch {
            riskLevel = .high
        } else if actionableInteractionCount > 2 || duplicateWarnings.count > 1 {
            riskLevel = .high
        } else if actionableInteractionCount > 0 || duplicateWarnings.count > 0 || conditionSeverity == .moderate {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }

        return VerificationResult(
            prescriptionRef: "\(prescription.patientName) — \(prescription.medicineName)",
            riskLevel: riskLevel,
            interactionWarnings: interactionText,
            duplicateWarning: duplicateText,
            dosageAssessment: dosageText,
            alternativeSuggestions: altText,
            diagnosisAssessment: diagnosisText,
            unverifiedMedicineWarning: unverifiedWarningText
        )
    }
}
