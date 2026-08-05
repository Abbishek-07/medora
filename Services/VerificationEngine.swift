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

        // 1. Check interactions
        let interactions = db.findInteractions(for: medicineNames)
        let interactionText = interactions.isEmpty ? "No significant interactions detected." : interactions.joined(separator: "\n")

        // 2. Check duplicates
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

        // 3. Age-based dosage
        var dosageNotes: [String] = []
        for name in medicineNames {
            let warning = db.getAgeBasedWarnings(medicineName: name, ageGroup: prescription.ageGroup)
            if !warning.isEmpty { dosageNotes.append(warning) }
        }
        let dosageText = dosageNotes.isEmpty ? "Dosage appears appropriate for \(prescription.ageGroup.rawValue) age group." : dosageNotes.joined(separator: "\n")

        // 4. Alternatives
        var altNotes: [String] = []
        if interactions.count > 1 || !duplicateWarnings.isEmpty {
            for name in medicineNames {
                let alt = db.getAlternatives(for: name)
                if !alt.isEmpty { altNotes.append(alt) }
            }
        }
        let altText = altNotes.isEmpty ? "No alternative suggestions needed." : altNotes.joined(separator: "\n")

        // 5. Classify condition severity from the diagnosis field
        let conditionSeverity = DiseaseSeverityClassifier.classify(prescription.diagnosis)

        // 6. Determine risk level — combines drug-safety checks (as before)
        //    with the diagnosis severity tier.
        var riskLevel: RiskLevel
        let criticalCount = [
            dosageText.lowercased().contains("contraindicated"),
            dosageText.lowercased().contains("reyes"),
            interactionText.lowercased().contains("lactic acidosis")
        ].filter { $0 }.count

        if criticalCount > 0 || conditionSeverity == .severe {
            riskLevel = .critical
        } else if interactions.count > 2 || duplicateWarnings.count > 1 {
            riskLevel = .high
        } else if interactions.count > 0 || duplicateWarnings.count > 0 || conditionSeverity == .moderate {
            riskLevel = .medium
        } else if conditionSeverity == .mild || conditionSeverity == .unknownCondition {
            riskLevel = .low
        } else {
            riskLevel = .low
        }

        // 7. Summary
        let summaryText: String
        switch riskLevel {
        case .low:
            summaryText = "Verified safe. No major issues detected."
        case .medium:
            summaryText = "Review recommended due to potential concerns."
        case .high:
            summaryText = "High risk detected. Pharmacist review required."
        case .critical:
            summaryText = "Critical safety alert. Do not dispense without prescriber consultation."
        case .unknown:
            summaryText = "Insufficient data to verify."
        }

        return VerificationResult(
            prescriptionRef: "\(prescription.patientName) — \(prescription.medicineName)",
            riskLevel: riskLevel,
            interactionWarnings: interactionText,
            duplicateWarning: duplicateText,
            dosageAssessment: dosageText,
            alternativeSuggestions: altText
        )
    }
}

