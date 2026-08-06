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
    /// Comma-separated list of conditions this medicine is a recognized
    /// treatment for, e.g. "fever, mild pain, headache, common cold".
    /// Used to verify the prescribed medicine actually matches the
    /// diagnosis, and to show "other uses" info in the detail view.
    /// Default "" keeps existing seeded data / SwiftData migration safe.
    var indications: String = ""

    init(
        name: String,
        category: MedicineCategory = .other,
        commonInteractions: String = "",
        ageRestrictions: String = "",
        saferAlternatives: String = "",
        maxDosageAdult: String = "",
        maxDosageChild: String = "",
        indications: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.commonInteractions = commonInteractions
        self.ageRestrictions = ageRestrictions
        self.saferAlternatives = saferAlternatives
        self.maxDosageAdult = maxDosageAdult
        self.maxDosageChild = maxDosageChild
        self.indications = indications
    }
}

enum MedicineCategory: String, Codable, CaseIterable {
    case antibiotic = "Antibiotic"
    case analgesic = "Analgesic"
    case cardiovascular = "Cardiovascular"
    case antidiabetic = "Antidiabetic"
    case respiratory = "Respiratory"
    case psychiatric = "Psychiatric"
    case gastrointestinal = "Gastrointestinal"
    case vitamin = "Vitamin & Supplement"
    case other = "Other"
}
