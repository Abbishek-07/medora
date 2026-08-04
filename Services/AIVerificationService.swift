import Foundation
import NaturalLanguage
import SwiftData

final class AIVerificationService {
    private let db: MedicineDatabaseService
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        self.db = MedicineDatabaseService(context: context)
    }
    
    @MainActor
    func analyzePrescription(_ prescription: Prescription) {
        let existing = fetchAllPrescriptions()
        let engine = VerificationEngine(db: db)
        let result = engine.verify(prescription: prescription, existingPrescriptions: existing)
        
        print("riskLevel:", result.riskLevel, "warnings:", result.interactionWarnings, "dosage:", result.dosageAssessment)
        prescription.interactionWarnings = result.interactionWarnings
        prescription.duplicateWarning = result.duplicateWarning
        prescription.dosageAssessment = result.dosageAssessment
        prescription.alternativeSuggestions = result.alternativeSuggestions
        prescription.aiSummary = result.aiSummary
        prescription.riskLevel = result.riskLevel
        prescription.status = result.riskLevel == .low ? .verified : .flagged
        
        context.insert(result)
        try? context.save()
    }
    
    private func fetchAllPrescriptions() -> [Prescription] {
        let descriptor = FetchDescriptor<Prescription>()
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func extractMedicineNames(from text: String) -> [String] {
        var names: [String] = []
        let allMeds = db.getAllMedicines()
        let lowercased = text.lowercased()
        for med in allMeds {
            if lowercased.contains(med.name.lowercased()) {
                names.append(med.name)
            }
        }
        return names
    }
}
