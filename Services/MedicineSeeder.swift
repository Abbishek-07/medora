import Foundation
import SwiftData

enum MedicineSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Medicine>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return }
        
        let medicines: [(String, MedicineCategory, String, String, String, String, String)] = [
            (
                "Amoxicillin", .antibiotic,
                "Reduces efficacy of oral contraceptives. Increased rash risk with allopurinol.",
                "Safe for all ages; adjust dose by weight in children.",
                "Cefuroxime, Doxycycline (if penicillin-allergic)",
                "500mg 3x daily (max 3g/day severe)", "90mg/kg/day divided 2-3 doses"
            ),
            (
                "Ibuprofen", .analgesic,
                "Increased bleeding with warfarin, aspirin. Reduces ACE inhibitor efficacy. Avoid other NSAIDs.",
                "Avoid in elderly with renal impairment. Lowest effective dose.",
                "Paracetamol (safer for elderly), Celecoxib (if NSAID needed)",
                "400mg 3x daily (max 2.4g/day)", "10mg/kg/dose every 6-8 hrs (not under 6mo)"
            ),
            (
                "Paracetamol", .analgesic,
                "Hepatotoxicity risk with alcohol, enzyme-inducing drugs.",
                "Safe for all ages; weight-based in children. Max 4g/day adults.",
                "Ibuprofen (if anti-inflammatory needed), Tramadol (severe pain)",
                "1g 4x daily (max 4g/day)", "15mg/kg/dose every 4-6 hrs (max 75mg/kg/day)"
            ),
            (
                "Cefixime", .antibiotic,
                "May increase nephrotoxicity with aminoglycosides. Caution with anticoagulants.",
                "Weight-based dosing in children. Renal adjustment in elderly.",
                "Amoxicillin-clavulanate, Cefuroxime (alternative cephalosporin)",
                "400mg once daily", "8mg/kg once daily"
            ),
            (
                "Aspirin", .analgesic,
                "Increased bleeding with warfarin, clopidogrel. GI ulcer risk with NSAIDs.",
                "Avoid in children (Reye's syndrome). Low dose (75-100mg) for elderly CV protection.",
                "Clopidogrel (antiplatelet), Paracetamol (pain relief)",
                "300-900mg every 4-6 hrs (max 4g/day)", "Not recommended under 16 years"
            ),
            (
                "Metformin", .antidiabetic,
                "Lactic acidosis risk with alcohol. Enhanced hypoglycemia with sulfonylureas.",
                "Safe for adults. Renal-adjusted dosing in elderly. Not first-line in children under 10.",
                "Pioglitazone, Dapagliflozin (SGLT2 inhibitor), Sitagliptin (DPP-4 inhibitor)",
                "500mg-1g 2x daily (max 2g/day)", "500mg 1-2x daily (age 10+ only)"
            ),
            (
                "Atorvastatin", .cardiovascular,
                "Myopathy risk with fibrates, cyclosporine. Reduced absorption with antacids.",
                "Start low in elderly. Not recommended under 10 years.",
                "Rosuvastatin, Pravastatin (less drug interactions)",
                "10-80mg once daily", "10-20mg once daily (age 10+ only)"
            ),
            (
                "Cetirizine", .respiratory,
                "Additive CNS depression with alcohol, sedatives.",
                "Safe for all ages. Lower dose in elderly with renal impairment.",
                "Loratadine (less sedating), Fexofenadine",
                "10mg once daily", "5mg once daily (age 6+), 2.5mg (age 2-5)"
            ),
        ]
        
        for (name, cat, interactions, age, alternatives, maxAd, maxCh) in medicines {
            let med = Medicine(
                name: name,
                category: cat,
                commonInteractions: interactions,
                ageRestrictions: age,
                saferAlternatives: alternatives,
                maxDosageAdult: maxAd,
                maxDosageChild: maxCh
            )
            context.insert(med)
        }
        try? context.save()
    }
}
