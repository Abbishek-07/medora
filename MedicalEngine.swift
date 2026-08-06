import Foundation

// MARK: - Local Medical Data Models
struct MedicalItem: Identifiable {
    let id = UUID()
    let name: String
    let category: ItemCategory
    let keywords: [String]
    let symptoms: [String]
    let overview: String
    let usageOrTreatment: String
    let precautions: String

    enum ItemCategory {
        case disease
        case medicine
    }
}

// MARK: - Rule Engine & Local Database
class MedicalEngine {
    static let shared = MedicalEngine()
    
    // Expandable local database of diseases and medicines
    private let database: [MedicalItem] = [
        MedicalItem(
            name: "Paracetamol (Acetaminophen)",
            category: .medicine,
            keywords: ["paracetamol", "acetaminophen", "crocin", "tylenol", "fever pill", "painkiller"],
            symptoms: ["fever", "headache", "mild pain", "body ache"],
            overview: "Paracetamol is an analgesic (pain reliever) and antipyretic (fever reducer) used to treat mild to moderate pain and fever.",
            usageOrTreatment: "Typical adult dose is 500mg to 1000mg every 4 to 6 hours as needed. Do not exceed 4000mg in 24 hours.",
            precautions: "Overuse can cause severe liver injury. Avoid taking with other drugs containing acetaminophen or alcohol."
        ),
        MedicalItem(
            name: "Ibuprofen",
            category: .medicine,
            keywords: ["ibuprofen", "advil", "motrin", "anti-inflammatory", "nsaid"],
            symptoms: ["inflammation", "joint pain", "toothache", "fever", "swelling", "cramps"],
            overview: "Ibuprofen is a Non-Steroidal Anti-Inflammatory Drug (NSAID) that reduces inflammation, pain, and fever.",
            usageOrTreatment: "Typical adult dose is 200mg to 400mg every 4 to 6 hours with food or milk.",
            precautions: "May cause stomach upset or gastrointestinal bleeding. Take with food. Caution in patients with kidney problems."
        ),
        MedicalItem(
            name: "Migraine",
            category: .disease,
            keywords: ["migraine", "severe headache", "throbbing head", "headache"],
            symptoms: ["throbbing headache", "nausea", "sensitivity to light", "sensitivity to sound", "aura"],
            overview: "A neurological condition causing intense, throbbing headaches usually on one side of the head.",
            usageOrTreatment: "Rest in a quiet, dark room. Hydration, OTC pain relievers (Ibuprofen, Acetaminophen), or prescription triptans.",
            precautions: "Seek immediate emergency help if accompanied by sudden numbness, loss of vision, or confusion."
        ),
        MedicalItem(
            name: "Common Cold",
            category: .disease,
            keywords: ["cold", "common cold", "runny nose", "sneezing", "cough"],
            symptoms: ["runny nose", "stuffy nose", "sneezing", "sore throat", "cough", "mild fever"],
            overview: "A contagious viral infection affecting the upper respiratory tract.",
            usageOrTreatment: "Plenty of rest, hydration, saline nasal sprays, and decongestants or pain relievers for symptom relief.",
            precautions: "Antibiotics do not cure viral colds. Consult a physician if symptoms last longer than 10 days."
        ),
        MedicalItem(
            name: "Hypertension (High Blood Pressure)",
            category: .disease,
            keywords: ["hypertension", "high blood pressure", "high bp", "bp"],
            symptoms: ["dizziness", "shortness of breath", "chest discomfort", "headache", "often symptomless"],
            overview: "A chronic condition where the force of the blood against artery walls is consistently too high.",
            usageOrTreatment: "Lifestyle modifications (low sodium diet, exercise) and prescribed antihypertensive medications.",
            precautions: "Often called a 'silent killer' because it may display no obvious symptoms. Requires regular monitoring."
        ),
        MedicalItem(
            name: "Asthma",
            category: .disease,
            keywords: ["asthma", "wheezing", "breathlessness", "breathing issue"],
            symptoms: ["shortness of breath", "chest tightness", "wheezing", "coughing"],
            overview: "A chronic condition in which your airways narrow, swell, and produce extra mucus.",
            usageOrTreatment: "Rescue inhalers (Albuterol) for acute attacks and daily controller inhalers (steroids) for prevention.",
            precautions: "Always carry a rescue inhaler. Seek immediate emergency care if breathing becomes extremely difficult."
        )
    ]
    
    // Rule matching engine
    func processQuery(_ query: String) -> String {
        let cleanedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedQuery.isEmpty {
            return "Please type a symptom, disease, or medication name."
        }
        
        // Rule 1: Greetings / Conversational Rules
        if isGreeting(cleanedQuery) {
            return "Hello! You can ask me about medications (e.g., Paracetamol, Ibuprofen), medical conditions (e.g., Asthma, Migraine), or tell me your symptoms!"
        }
        
        // Rule 2: Search for Exact or Keyword Matches
        let keywordMatches = database.filter { item in
            item.keywords.contains { keyword in cleanedQuery.contains(keyword) }
        }
        
        if let bestMatch = keywordMatches.first {
            return formatItemResponse(bestMatch)
        }
        
        // Rule 3: Search by Symptom Matches
        let symptomMatches = database.filter { item in
            item.symptoms.contains { symptom in cleanedQuery.contains(symptom) }
        }
        
        if !symptomMatches.isEmpty {
            var response = "Based on your symptoms, here are relevant conditions or medications in my offline database:\n\n"
            for item in symptomMatches {
                response += "• **\(item.name)** (\(item.category == .disease ? "Condition" : "Medication"))\n"
                response += "  *Overview:* \(item.overview)\n\n"
            }
            response += "⚠️ *Disclaimer: Medora provides local informational guidance only. Always consult a physician for clinical diagnosis.*"
            return response
        }
        
        // Rule 4: Fallback Rule
        return """
        I couldn't find an exact match for "\(query)" in my local database.
        
        Try searching for:
        • Symptoms: *fever, headache, coughing, sore throat*
        • Conditions: *migraine, asthma, common cold, high bp*
        • Medications: *paracetamol, ibuprofen*
        """
    }
    
    private func isGreeting(_ text: String) -> Bool {
        let greetings = ["hi", "hello", "hey", "who are you", "help", "medora", "start"]
        return greetings.contains { text == $0 || text.hasPrefix($0) }
    }
    
    private func formatItemResponse(_ item: MedicalItem) -> String {
        let categoryLabel = item.category == .disease ? "Medical Condition" : "Medication"
        
        return """
        📋 **\(item.name)** (\(categoryLabel))
        
        • **Overview:**
        \(item.overview)
        
        • **Associated Symptoms:**
        \(item.symptoms.joined(separator: ", "))
        
        • **\(item.category == .disease ? "Typical Treatment" : "Standard Usage"):**
        \(item.usageOrTreatment)
        
        • **Precautions & Warnings:**
        \(item.precautions)
        
        ⚠️ *Medora is for educational purposes only. Always verify with a certified medical provider.*
        """
    }
}
