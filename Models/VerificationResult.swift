import Foundation
import SwiftData

@Model
final class VerificationResult {
    var id: UUID
    var prescriptionRef: String
    var riskLevel: RiskLevel
    var interactionWarnings: String
    var duplicateWarning: String
    var dosageAssessment: String
    var alternativeSuggestions: String
    /// Whether the prescribed medicine matches the stated diagnosis,
    /// e.g. "Paracetamol is a recognized treatment for \"fever\"." or a
    /// caution if it isn't a typical treatment for the diagnosis given.
    var diagnosisAssessment: String = ""
    var verifiedAt: Date
    
    init(
        prescriptionRef: String = "",
        riskLevel: RiskLevel = .unknown,
        interactionWarnings: String = "",
        duplicateWarning: String = "",
        dosageAssessment: String = "",
        alternativeSuggestions: String = "",
        diagnosisAssessment: String = ""
    ) {
        self.id = UUID()
        self.prescriptionRef = prescriptionRef
        self.riskLevel = riskLevel
        self.interactionWarnings = interactionWarnings
        self.duplicateWarning = duplicateWarning
        self.dosageAssessment = dosageAssessment
        self.alternativeSuggestions = alternativeSuggestions
        self.diagnosisAssessment = diagnosisAssessment
        self.verifiedAt = .now
    }
}
