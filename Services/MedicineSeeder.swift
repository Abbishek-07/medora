import Foundation
import SwiftData

enum MedicineSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Medicine>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return }

        // (name, category, commonInteractions, ageRestrictions, saferAlternatives,
        //  maxDosageAdult, maxDosageChild, indications)
        let medicines: [(String, MedicineCategory, String, String, String, String, String, String)] = [

            // MARK: Analgesics / Antipyretics
            (
                "Paracetamol", .analgesic,
                "Hepatotoxicity risk with alcohol, enzyme-inducing drugs.",
                "Safe for all ages; weight-based in children. Max 4g/day adults.",
                "Ibuprofen (if anti-inflammatory needed), Tramadol (severe pain)",
                "1g 4x daily (max 4g/day)", "15mg/kg/dose every 4-6 hrs (max 75mg/kg/day)",
                "fever, mild fever, mild pain, headache, cold, common cold, flu, sore throat, migraine"
            ),
            (
                "Ibuprofen", .analgesic,
                "Increased bleeding with warfarin, aspirin. Reduces ACE inhibitor efficacy. Avoid other NSAIDs.",
                "Avoid in elderly with renal impairment. Lowest effective dose.",
                "Paracetamol (safer for elderly), Celecoxib (if NSAID needed)",
                "400mg 3x daily (max 2.4g/day)", "10mg/kg/dose every 6-8 hrs (not under 6mo)",
                "fever, mild pain, headache, arthritis, inflammation, migraine, minor burn"
            ),
            (
                "Aspirin", .analgesic,
                "Increased bleeding with warfarin, clopidogrel. GI ulcer risk with NSAIDs.",
                "Avoid in children (Reye's syndrome). Low dose (75-100mg) for elderly CV protection.",
                "Clopidogrel (antiplatelet), Paracetamol (pain relief)",
                "300-900mg every 4-6 hrs (max 4g/day)", "Not recommended under 16 years",
                "mild pain, headache, fever, cardiovascular protection"
            ),
            (
                "Diclofenac", .analgesic,
                "Increased bleeding with anticoagulants. GI ulcer risk with other NSAIDs/steroids.",
                "Avoid in elderly with cardiac or renal disease. Not recommended under 14 years.",
                "Paracetamol, Ibuprofen (lower GI risk)",
                "50mg 2-3x daily (max 150mg/day)", "Not recommended under 14 years",
                "arthritis, inflammation, muscle pain, joint pain, migraine"
            ),
            (
                "Tramadol", .analgesic,
                "Serotonin syndrome risk with SSRIs/SNRIs. Increased sedation with alcohol, benzodiazepines.",
                "Reduce dose in elderly. Not recommended under 12 years.",
                "Paracetamol, Codeine (alternative opioid)",
                "50-100mg every 4-6 hrs (max 400mg/day)", "Not recommended under 12 years",
                "moderate pain, severe pain, post-surgical pain"
            ),

            // MARK: Antibiotics
            (
                "Amoxicillin", .antibiotic,
                "Reduces efficacy of oral contraceptives. Increased rash risk with allopurinol.",
                "Safe for all ages; adjust dose by weight in children.",
                "Cefuroxime, Doxycycline (if penicillin-allergic)",
                "500mg 3x daily (max 3g/day severe)", "90mg/kg/day divided 2-3 doses",
                "bacterial infection, ear infection, throat infection, sinusitis, urinary tract infection, uti, pneumonia"
            ),
            (
                "Azithromycin", .antibiotic,
                "QT prolongation risk with antiarrhythmics. Reduced absorption with antacids.",
                "Generally safe for all ages; dose-adjust in severe hepatic impairment.",
                "Amoxicillin, Clarithromycin",
                "500mg once daily for 3 days", "10mg/kg once daily for 3 days",
                "bacterial infection, throat infection, sinusitis, bronchitis, pneumonia mild, typhoid"
            ),
            (
                "Ciprofloxacin", .antibiotic,
                "Increased tendon rupture risk with corticosteroids. Reduced absorption with antacids, dairy.",
                "Avoid in children and growing adolescents (tendon/cartilage risk) unless essential. Caution in elderly.",
                "Nitrofurantoin (for UTI), Azithromycin",
                "500mg 2x daily", "Not recommended under 18 years except specific indications",
                "urinary tract infection, uti, bacterial infection, gastroenteritis"
            ),
            (
                "Cefixime", .antibiotic,
                "May increase nephrotoxicity with aminoglycosides. Caution with anticoagulants.",
                "Weight-based dosing in children. Renal adjustment in elderly.",
                "Amoxicillin-clavulanate, Cefuroxime (alternative cephalosporin)",
                "400mg once daily", "8mg/kg once daily",
                "bacterial infection, urinary tract infection, uti, throat infection, bronchitis, pneumonia mild, typhoid"
            ),
            (
                "Metronidazole", .antibiotic,
                "Disulfiram-like reaction with alcohol. Increased bleeding with warfarin.",
                "Safe for all ages at adjusted doses. Avoid alcohol entirely during and after use.",
                "Tinidazole, Amoxicillin (for dental infections)",
                "400mg 3x daily", "7.5mg/kg 3x daily",
                "bacterial infection, dental infection, gastroenteritis, diarrhea, parasitic infection"
            ),

            // MARK: Gastrointestinal
            (
                "Cyclopam", .gastrointestinal,
                "Additive sedation with alcohol, sedatives. Caution with anticholinergic drugs.",
                "Avoid in infants under 6 months. Use lowest effective dose in elderly.",
                "Drotaverine, Hyoscine butylbromide",
                "1 tablet 2-3x daily", "Not recommended under 6 months; weight-based above",
                "abdominal pain, stomach cramps, indigestion, acidity, irritable bowel"
            ),
            (
                "Omeprazole", .gastrointestinal,
                "Reduces clopidogrel efficacy. Reduced absorption of iron, vitamin B12 with long-term use.",
                "Safe for all ages at adjusted doses. Long-term use in elderly linked to fracture/B12 risk.",
                "Pantoprazole, Ranitidine",
                "20-40mg once daily", "0.5-1mg/kg once daily (age 1+)",
                "acidity, gastritis, ulcer, indigestion, gerd, heartburn"
            ),
            (
                "Pantoprazole", .gastrointestinal,
                "Reduced absorption of drugs requiring gastric acid (e.g. ketoconazole).",
                "Safe for all ages at adjusted doses. Monitor long-term use in elderly.",
                "Omeprazole, Ranitidine",
                "40mg once daily", "Not typically first-line under 5 years",
                "acidity, gastritis, ulcer, indigestion, gerd, heartburn"
            ),
            (
                "Domperidone", .gastrointestinal,
                "QT prolongation risk with other QT-prolonging drugs (e.g. azithromycin, ketoconazole).",
                "Caution in elderly (cardiac risk). Weight-based dosing in children.",
                "Ondansetron",
                "10mg 3x daily before meals", "0.25mg/kg 3x daily before meals",
                "nausea, vomiting, indigestion, acidity, bloating"
            ),
            (
                "Ondansetron", .gastrointestinal,
                "QT prolongation risk with other QT-prolonging drugs. Serotonin syndrome risk with SSRIs.",
                "Safe for all ages at adjusted doses.",
                "Domperidone",
                "4-8mg 2-3x daily", "0.15mg/kg per dose (age 6mo+)",
                "nausea, vomiting, motion sickness"
            ),
            (
                "Ranitidine", .gastrointestinal,
                "Reduced absorption of drugs requiring gastric acid.",
                "Safe for all ages at adjusted doses.",
                "Omeprazole, Pantoprazole",
                "150mg 2x daily", "2-4mg/kg 2x daily",
                "acidity, gastritis, ulcer, indigestion, heartburn"
            ),

            // MARK: Antidiabetic
            (
                "Metformin", .antidiabetic,
                "Lactic acidosis risk with alcohol. Enhanced hypoglycemia with sulfonylureas.",
                "Safe for adults. Renal-adjusted dosing in elderly. Not first-line in children under 10.",
                "Pioglitazone, Dapagliflozin (SGLT2 inhibitor), Sitagliptin (DPP-4 inhibitor)",
                "500mg-1g 2x daily (max 2g/day)", "500mg 1-2x daily (age 10+ only)",
                "diabetes, type 2 diabetes"
            ),
            (
                "Glimepiride", .antidiabetic,
                "Increased hypoglycemia risk with alcohol, other antidiabetics. Reduced efficacy with steroids.",
                "Caution in elderly (hypoglycemia risk). Not recommended in children.",
                "Metformin, Sitagliptin",
                "1-4mg once daily", "Not recommended under 18 years",
                "diabetes, type 2 diabetes"
            ),

            // MARK: Cardiovascular
            (
                "Atorvastatin", .cardiovascular,
                "Myopathy risk with fibrates, cyclosporine. Reduced absorption with antacids.",
                "Start low in elderly. Not recommended under 10 years.",
                "Rosuvastatin, Pravastatin (less drug interactions)",
                "10-80mg once daily", "10-20mg once daily (age 10+ only)",
                "high cholesterol, hypertension, cardiovascular protection"
            ),
            (
                "Amlodipine", .cardiovascular,
                "Increased hypotension with other antihypertensives. Grapefruit juice increases levels.",
                "Start low in elderly (hypotension risk). Weight-based dosing in children with hypertension.",
                "Losartan, Atenolol",
                "5-10mg once daily", "0.1mg/kg once daily (specialist guidance)",
                "hypertension, high blood pressure, angina"
            ),
            (
                "Losartan", .cardiovascular,
                "Hyperkalemia risk with potassium-sparing diuretics, NSAIDs. Avoid with ACE inhibitors.",
                "Start low in elderly. Not recommended under 6 years.",
                "Amlodipine, Atenolol",
                "50-100mg once daily", "0.7mg/kg once daily (age 6+)",
                "hypertension, high blood pressure"
            ),
            (
                "Atenolol", .cardiovascular,
                "Masks hypoglycemia symptoms in diabetics. Bradycardia risk with other rate-limiting drugs.",
                "Reduce dose in elderly with renal impairment. Rarely used in children.",
                "Amlodipine, Losartan",
                "50-100mg once daily", "Specialist guidance only",
                "hypertension, high blood pressure, angina, arrhythmia"
            ),

            // MARK: Respiratory / Allergy
            (
                "Cetirizine", .respiratory,
                "Additive CNS depression with alcohol, sedatives.",
                "Safe for all ages. Lower dose in elderly with renal impairment.",
                "Loratadine (less sedating), Fexofenadine",
                "10mg once daily", "5mg once daily (age 6+), 2.5mg (age 2-5)",
                "allergy, allergies, seasonal allergy, rhinitis, cold, common cold"
            ),
            (
                "Levocetirizine", .respiratory,
                "Additive CNS depression with alcohol, sedatives.",
                "Safe for all ages. Lower dose in elderly with renal impairment.",
                "Cetirizine, Loratadine",
                "5mg once daily", "2.5mg once daily (age 6+)",
                "allergy, allergies, seasonal allergy, rhinitis, cold, common cold"
            ),
            (
                "Montelukast", .respiratory,
                "Rare mood/behavior changes reported; caution combining with other psychiatric medication.",
                "Safe for all ages at adjusted doses.",
                "Cetirizine, inhaled corticosteroids (specialist guidance)",
                "10mg once daily (evening)", "4-5mg once daily depending on age",
                "asthma, allergy, allergic rhinitis"
            ),
            (
                "Salbutamol", .respiratory,
                "Increased cardiac stimulation with other stimulants, MAO inhibitors.",
                "Caution in elderly with cardiac disease. Safe for children via inhaler/nebulizer.",
                "Levosalbutamol, Ipratropium",
                "100-200mcg inhaled as needed (max 8 puffs/day)", "100mcg inhaled as needed, weight-based nebulized dose",
                "asthma, bronchitis, wheeze, respiratory distress"
            ),

            // MARK: Psychiatric
            (
                "Sertraline", .psychiatric,
                "Serotonin syndrome risk with other SSRIs/MAOIs/tramadol. Increased bleeding with NSAIDs.",
                "Start low in elderly. Caution and specialist guidance under 18.",
                "Fluoxetine, Escitalopram",
                "50-200mg once daily", "Specialist guidance only",
                "depression, anxiety"
            ),
            (
                "Alprazolam", .psychiatric,
                "Severe CNS/respiratory depression with alcohol, opioids. Additive sedation with other sedatives.",
                "Avoid or use lowest dose in elderly (fall risk). Not recommended in children.",
                "Non-benzodiazepine options, specialist guidance",
                "0.25-0.5mg 2-3x daily", "Not recommended under 18 years",
                "anxiety, panic disorder, insomnia"
            ),

            // MARK: Vitamins & Supplements
            (
                "Vitamin D3", .vitamin,
                "Hypercalcemia risk with high-dose calcium supplements or thiazide diuretics.",
                "Safe for all ages at recommended doses.",
                "Multivitamin",
                "1000-2000 IU once daily", "400-1000 IU once daily depending on age",
                "vitamin d deficiency, bone health, rickets"
            ),
            (
                "Ferrous Sulfate", .vitamin,
                "Reduced absorption with antacids, calcium, tea/coffee. Reduces absorption of some antibiotics (e.g. ciprofloxacin) if taken together.",
                "Safe for all ages at weight-based doses. Constipation common in elderly.",
                "Ferrous fumarate, dietary iron sources",
                "325mg 1-3x daily", "3-6mg/kg/day of elemental iron",
                "anemia, iron deficiency"
            ),
            (
                "Multivitamin", .vitamin,
                "Generally minimal interactions; high-dose vitamin K may affect anticoagulants.",
                "Safe for all ages at recommended doses.",
                "Individual vitamin supplements as needed",
                "1 tablet once daily", "Age-appropriate pediatric formulation once daily",
                "nutritional deficiency, general wellness, fatigue"
            ),
            (
                "ORS", .other,
                "No significant drug interactions.",
                "Safe for all ages; first-line for dehydration in children.",
                "Homemade salt-sugar solution (if ORS unavailable)",
                "1 sachet per loose stool / as needed", "1 sachet per loose stool, weight-based volume",
                "diarrhea, dehydration, vomiting, gastroenteritis"
            ),
        ]

        for (name, cat, interactions, age, alternatives, maxAd, maxCh, indications) in medicines {
            let med = Medicine(
                name: name,
                category: cat,
                commonInteractions: interactions,
                ageRestrictions: age,
                saferAlternatives: alternatives,
                maxDosageAdult: maxAd,
                maxDosageChild: maxCh,
                indications: indications
            )
            context.insert(med)
        }
        try? context.save()
    }
}
