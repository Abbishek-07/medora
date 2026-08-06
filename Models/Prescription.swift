import Foundation
import SwiftData

@Model
final class Prescription {
    var id: UUID
    var patientName: String
    var medicineName: String
    var dosage: String
    var frequency: String
    var ageGroup: AgeGroup
    var status: PrescriptionStatus
    var date: Date
    var notes: String
    var diagnosis: String = ""
    var riskLevel: RiskLevel
    var interactionWarnings: String
    var duplicateWarning: String
    var dosageAssessment: String
    var alternativeSuggestions: String
    var diagnosisAssessment: String = ""
    
    init(
        patientName: String = "",
        medicineName: String = "",
        dosage: String = "",
        frequency: String = "",
        ageGroup: AgeGroup = .adult,
        status: PrescriptionStatus = .pending,
        date: Date = .now,
        notes: String = "",
        diagnosis: String = ""
    ) {
        self.id = UUID()
        self.patientName = patientName
        self.medicineName = medicineName
        self.dosage = dosage
        self.frequency = frequency
        self.ageGroup = ageGroup
        self.status = status
        self.date = date
        self.notes = notes
        self.diagnosis = diagnosis
        self.riskLevel = .unknown
        self.interactionWarnings = ""
        self.duplicateWarning = ""
        self.dosageAssessment = ""
        self.alternativeSuggestions = ""
        self.diagnosisAssessment = ""
    }
}

enum AgeGroup: String, Codable, CaseIterable {
    case child = "Child"
    case adult = "Adult"
    case elderly = "Elderly"
}

enum PrescriptionStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case verified = "Verified"
    case flagged = "Flagged"
    case resolved = "Resolved"
}

enum RiskLevel: String, Codable, CaseIterable {
    case unknown = "Unknown"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .unknown: return "gray"
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        case .critical: return "purple"
        }
    }
}
