import Foundation

struct OllamaRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
}

struct OllamaResponse: Codable {
    let response: String
}

final class OllamaService {

    // Mac running Ollama
    private let endpoint = URL(string: "http://127.0.0.1:11434/api/generate")!

    func ask(_ prompt: String) async throws -> String {

        var request = URLRequest(url: endpoint)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body = OllamaRequest(
            model: "llama3.2:3b",
            prompt: prompt,
            stream: false
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try JSONDecoder().decode(
            OllamaResponse.self,
            from: data
        )

        return result.response
    }
}
