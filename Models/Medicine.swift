import Foundation
import SwiftData

@Model
final class Medicine {
    var id: UUID
    var name: String
    var category: MedicineCategory
    var commonInteractions: String
    var ageRestrictions: String
    var saferAlternatives: String
    var maxDosageAdult: String
    var maxDosageChild: String
    
    init(
        name: String,
        category: MedicineCategory = .other,
        commonInteractions: String = "",
        ageRestrictions: String = "",
        saferAlternatives: String = "",
        maxDosageAdult: String = "",
        maxDosageChild: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.commonInteractions = commonInteractions
        self.ageRestrictions = ageRestrictions
        self.saferAlternatives = saferAlternatives
        self.maxDosageAdult = maxDosageAdult
        self.maxDosageChild = maxDosageChild
    }
}

enum MedicineCategory: String, Codable, CaseIterable {
    case antibiotic = "Antibiotic"
    case analgesic = "Analgesic"
    case cardiovascular = "Cardiovascular"
    case antidiabetic = "Antidiabetic"
    case respiratory = "Respiratory"
    case psychiatric = "Psychiatric"
    case other = "Other"
}
