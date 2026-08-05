import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isSending: Bool = false

    private let systemPrompt: String = "You are a helpful pharmacist assistant. Answer clearly and safely. Keep responses concise unless asked for more detail."

    private let ollama = OllamaService()

    func send(_ userText: String) async {
        let trimmed = userText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Append the user's message immediately for optimistic UI
        let userMsg = ChatMessage(role: .user, text: trimmed)
        messages.append(userMsg)

        isSending = true
        defer { isSending = false }

        do {
            // Build a single prompt that includes a short system instruction and a brief history.
            // For simplicity, we concatenate the last few turns. You can switch to a structured chat format later if OllamaService supports it.
            let historySnippet = messages.suffix(8).map { msg in
                let speaker = (msg.role == .user) ? "User" : "Assistant"
                return "\(speaker): \(msg.text)"
            }.joined(separator: "\n")

            let prompt = """
            System: \(systemPrompt)

            Conversation so far:
            \(historySnippet)

            Assistant: 
            """

            let reply = try await ollama.ask(prompt)
            let assistantMsg = ChatMessage(role: .assistant, text: reply.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            messages.append(assistantMsg)
        } catch {
            let assistantMsg = ChatMessage(role: .assistant, text: "Sorry, I couldn't process that request: \(error.localizedDescription)")
            messages.append(assistantMsg)
        }
    }

    func clear() {
        messages.removeAll()
    }
}
