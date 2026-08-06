import SwiftUI
import Combine

// MARK: - Dedicated Local Message Model
struct MedoraChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - View Model
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [MedoraChatMessage] = []
    @Published var inputMessage: String = ""
    
    init() {
        // Welcome message on load
        messages.append(MedoraChatMessage(content: "Hi! I am Medora, how can I help you today?", isUser: false))
    }
    
    func sendMessage() {
        let text = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add User Message
        let userMsg = MedoraChatMessage(content: text, isUser: true)
        messages.append(userMsg)
        inputMessage = ""
        
        // Fetch answer from offline rule engine
        let replyText = MedicalEngine.shared.processQuery(text)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.messages.append(MedoraChatMessage(content: replyText, isUser: false))
        }
    }
}

// MARK: - SwiftUI Chat Sheet Interface
struct MedoraChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.medoraBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let last = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input Bar
                    VStack(spacing: 6) {
                        HStack(spacing: 10) {
                            TextField("Ask about symptoms, medicines...", text: $viewModel.inputMessage)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(20)
                                .foregroundStyle(Color.medoraInk)
                                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
                            
                            Button(action: viewModel.sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(Color.medoraPinkDeep)
                                    .clipShape(Circle())
                            }
                            .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        Text("Medora Local Assistant • Informational Use Only")
                            .font(.caption2)
                            .foregroundStyle(Color.medoraGraySubtle)
                    }
                    .padding()
                    .background(Color.white.opacity(0.85))
                }
            }
            .navigationTitle("Medora AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.medoraGraySubtle)
                    }
                }
            }
        }
    }
}

// MARK: - Message Bubble UI
struct MessageBubble: View {
    let message: MedoraChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .font(.subheadline)
                .padding(12)
                .background(message.isUser ? Color.medoraPinkDeep : Color.white)
                .foregroundStyle(message.isUser ? .white : Color.medoraInk)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            
            if !message.isUser { Spacer() }
        }
    }
}
