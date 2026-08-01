import Foundation

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
        
        // 5. Determine risk level
        let riskLevel: RiskLevel
        let criticalCount = [
            dosageText.lowercased().contains("contraindicated"),
            dosageText.lowercased().contains("reyes"),
            interactionText.lowercased().contains("lactic acidosis")
        ].filter { $0 }.count
        
        if criticalCount > 0 {
            riskLevel = .critical
        } else if interactions.count > 2 || duplicateWarnings.count > 1 {
            riskLevel = .high
        } else if interactions.count > 0 || duplicateWarnings.count > 0 {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }
        
        // 6. AI-style summary
        let summary = generateSummary(
            patientName: prescription.patientName,
            medicineName: prescription.medicineName,
            riskLevel: riskLevel,
            hasInteractions: !interactions.isEmpty,
            hasDuplicates: !duplicateWarnings.isEmpty,
            ageGroup: prescription.ageGroup
        )
        
        return VerificationResult(
            prescriptionRef: "\(prescription.patientName) — \(prescription.medicineName)",
            riskLevel: riskLevel,
            interactionWarnings: interactionText,
            duplicateWarning: duplicateText,
            dosageAssessment: dosageText,
            alternativeSuggestions: altText,
            aiSummary: summary
        )
    }
    
    private func generateSummary(
        patientName: String,
        medicineName: String,
        riskLevel: RiskLevel,
        hasInteractions: Bool,
        hasDuplicates: Bool,
        ageGroup: AgeGroup
    ) -> String {
        switch riskLevel {
        case .low:
            return "Verified safe. \(medicineName) at prescribed dosage is standard for \(ageGroup.rawValue.lowercased()) patients. No interactions or duplicates found. Remind \(patientName) to complete the full course."
        case .medium:
            return "\(medicineName) prescribed for \(patientName) (\(ageGroup.rawValue)). \(hasInteractions ? "Potential drug interactions noted — review before dispensing." : "") \(hasDuplicates ? "Possible duplicate therapy detected." : "") Monitor and counsel patient on warning signs."
        case .high:
            return "HIGH RISK for \(patientName). \(hasInteractions ? "Significant drug interactions detected." : "") \(hasDuplicates ? "Multiple medications from the same class — review necessity." : "") Strongly recommend pharmacist consultation before dispensing."
        case .critical:
            return "CRITICAL SAFETY ALERT for \(patientName). This prescription may be contraindicated for \(ageGroup.rawValue.lowercased()) patients. DO NOT dispense without immediate prescriber consultation."
        case .unknown:
            return "Insufficient data to verify \(medicineName) for \(patientName). Enter more details or consult a pharmacist."
        }
    }
}
