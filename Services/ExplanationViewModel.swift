import Foundation
import SwiftUI
import Combine

@MainActor
final class ExplanationViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var explanation: String = ""

    // Configure the Ollama model and system behavior for clinical explanations
    private let systemPrompt: String = "You are a pharmacist assistant. Use clinically sound, patient-safe language. Be concise and clear."

    private let ollama = OllamaService()

    func makeExplanation(for result: VerificationResult) async {
        isLoading = true
        defer { isLoading = false }

        var prompt = "System: \(systemPrompt)\n\n"
        prompt += "Task: Explain the verification result in clear, patient-safe terms.\n\n"
        prompt += "Prescription: \(result.prescriptionRef)\n"
        prompt += "Risk level: \(result.riskLevel.rawValue)\n\n"
        if !result.interactionWarnings.isEmpty {
            prompt += "Drug interactions: \(result.interactionWarnings)\n"
        }
        if !result.duplicateWarning.isEmpty {
            prompt += "Duplicate warning: \(result.duplicateWarning)\n"
        }
        if !result.dosageAssessment.isEmpty {
            prompt += "Dosage assessment: \(result.dosageAssessment)\n"
        }
        if !result.alternativeSuggestions.isEmpty {
            prompt += "Alternatives: \(result.alternativeSuggestions)\n"
        }
        prompt += "\nOutput: Provide a brief explanation (3-6 sentences). If risk is low, reassure safety. If medium or higher, highlight what to watch for and any monitoring or counseling points."

        do {
            let text = try await ollama.ask(prompt)
            self.explanation = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } catch {
            self.explanation = "Failed to generate explanation: \(error.localizedDescription)"
        }
    }
}

