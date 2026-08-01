import Foundation
import SwiftData

@MainActor
final class MedicineDatabaseService {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func findMedicine(named name: String) -> Medicine? {
        let normalized = name.lowercased().trimmingCharacters(in: .whitespaces)
        let descriptor = FetchDescriptor<Medicine>()
        guard let all = try? context.fetch(descriptor) else { return nil }
        return all.first { med in
            let medName = med.name.lowercased()
            return normalized.contains(medName) || medName.contains(normalized)
        }
    }
    
    func getAllMedicines() -> [Medicine] {
        let descriptor = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\.name)])
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func findInteractions(for medicineNames: [String]) -> [String] {
        var warnings: [String] = []
        let allMeds = getAllMedicines()
        
        for name in medicineNames {
            if let med = findMedicine(named: name), !med.commonInteractions.isEmpty {
                warnings.append("\(med.name): \(med.commonInteractions)")
            }
        }
        
        // Check for NSAID duplicates
        let nsaids = ["ibuprofen", "naproxen", "diclofenac", "aspirin", "indomethacin", "celecoxib"]
        let foundNSAIDs = medicineNames.filter { name in
            nsaids.contains { name.lowercased().contains($0) }
        }
        if foundNSAIDs.count > 1 {
            warnings.append("Duplicate NSAID therapy detected: \(foundNSAIDs.joined(separator: ", ")). Combining NSAIDs increases GI bleeding and renal risk.")
        }
        
        return warnings
    }
    
    func getAgeBasedWarnings(medicineName: String, ageGroup: AgeGroup) -> String {
        guard let med = findMedicine(named: medicineName) else { return "" }
        
        switch ageGroup {
        case .elderly where med.category == .analgesic:
            return "Elderly patient: \(med.name) may require reduced dosing. Consider renal function. \(med.ageRestrictions)"
        case .child where med.name.lowercased().contains("aspirin"):
            return "WARNING: Aspirin is contraindicated in children due to Reye's syndrome risk."
        case .child:
            return med.maxDosageChild.isEmpty ? "" : "Pediatric max: \(med.maxDosageChild)"
        case .elderly:
            return med.ageRestrictions.isEmpty ? "Monitor renal and hepatic function." : med.ageRestrictions
        default:
            return ""
        }
    }
    
    func getAlternatives(for medicineName: String) -> String {
        guard let med = findMedicine(named: medicineName) else { return "" }
        return med.saferAlternatives.isEmpty ? "" : "Safer alternatives: \(med.saferAlternatives)"
    }
}
