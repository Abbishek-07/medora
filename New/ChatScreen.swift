import SwiftUI

// MARK: - Models

struct ChatMessage: Identifiable {
    let id: Int
    let role: String
    let text: String
    let time: String
}

let QUICK_PROMPTS = [
    "Can I take Ibuprofen with Warfarin?",
    "What is the max dose of Metformin?",
    "Alternatives to Omeprazole?",
    "Side effects of Lisinopril?",
]

let RESPONSES: [String: String] = [
    "Can I take Ibuprofen with Warfarin?": """
    ⚠️ **Avoid this combination.** Ibuprofen (an NSAID) interacts dangerously with Warfarin:

    • NSAIDs inhibit platelet aggregation, increasing bleeding risk
    • Ibuprofen displaces Warfarin from protein-binding sites, raising its free concentration
    • This can cause serious or life-threatening bleeding events

    **Safer alternative:** Paracetamol (Acetaminophen) 500–1000mg is the preferred pain reliever for patients on Warfarin. Always consult your physician before switching medications.
    """,
    "What is the max dose of Metformin?": """
    📋 **Metformin dosing guidelines:**

    • Standard adult maximum: **2000–2550mg/day** in divided doses
    • For adults aged 65+: maximum recommended is **1500mg/day** due to reduced renal clearance
    • Always take with meals to reduce GI side effects

    **Note:** Dose must be adjusted if eGFR < 45 mL/min/1.73m². Metformin is contraindicated when eGFR < 30. Your current prescription of 1000mg twice daily (2000mg total) should be reviewed if you are over 65.
    """,
    "Alternatives to Omeprazole?": """
    💊 **Proton Pump Inhibitor alternatives to Omeprazole:**

    • **Pantoprazole 40mg** — similar efficacy, fewer drug interactions
    • **Esomeprazole 20–40mg** — slightly longer duration of action
    • **Lansoprazole 30mg** — well-tolerated, widely available
    • **Rabeprazole 20mg** — fewer CYP2C19 interactions

    **H2 Blockers (milder):** Famotidine 20mg is suitable for mild reflux and has fewer long-term concerns.

    Note: You currently have Omeprazole listed twice in your prescriptions — this duplicate should be resolved with your prescribing physician.
    """,
    "Side effects of Lisinopril?": """
    📌 **Common side effects of Lisinopril (ACE Inhibitor):**

    • **Dry persistent cough** — affects ~10–15% of patients; most common reason for switching
    • **Dizziness / hypotension** — especially with first dose or if dehydrated
    • **Elevated potassium (hyperkalemia)** — avoid high-potassium foods in excess
    • **Angioedema** (rare but serious) — swelling of lips, throat, tongue; seek emergency care immediately

    **When to contact your doctor:** If cough is bothersome, your physician may switch you to an ARB (e.g. Losartan 50mg) which has equivalent blood pressure control without the cough.
    """,
]

let DEFAULT_RESPONSE = """
I'm Medora AI, your prescription safety assistant. I can help you with:

• Drug interaction checks
• Dosage guidance and safety ranges
• Medication alternatives
• Side effect information
• Prescription error explanations

Please note: I provide general medical information only. Always consult your physician or pharmacist before making any changes to your medications.
"""

// MARK: - ChatScreen

struct ChatScreen: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            id: 1,
            role: "assistant",
            text: "Hello! I'm **Medora AI**, your prescription safety assistant. Ask me about drug interactions, dosage guidelines, side effects, or medication alternatives.",
            time: "Now"
        )
    ]
    @State private var input = ""
    @State private var typing = false
    @State private var msgId = 2
    @State private var scrollToBottom = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.teal900, AppTheme.teal700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Text("💊")
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Medora AI")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.slate900)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(AppTheme.emerald400)
                            .frame(width: 6, height: 6)
                        Text("Online · Prescription Assistant")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.emerald600)
                    }
                }

                Spacer()

                Button {
                    resetChat()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.slate500)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.slate100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 16)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(AppTheme.slate100)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            )

            // Messages
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Quick prompts
                        if messages.count == 1 {
                            VStack(spacing: 6) {
                                Text("COMMON QUESTIONS")
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundColor(AppTheme.slate400)
                                    .tracking(1)
                                VStack(spacing: 6) {
                                    ForEach(QUICK_PROMPTS, id: \.self) { q in
                                        Button {
                                            send(text: q)
                                        } label: {
                                            Text(q)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(AppTheme.teal700)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                                .background(AppTheme.teal50)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(AppTheme.teal100, lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.bottom, 4)
                        }

                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                        }

                        if typing {
                            TypingIndicator()
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: typing) { _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }

            // Input bar
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("Ask about drug interactions, dosage…", text: $input, axis: .vertical)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.slate700)
                            .lineLimit(1...4)
                            .onSubmit {
                                send(text: input)
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppTheme.slate50)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.slate200, lineWidth: 1)
                    )

                    Button {
                        send(text: input)
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor((!input.trimmingCharacters(in: .whitespaces).isEmpty && !typing) ? .white : AppTheme.slate400)
                            .frame(width: 40, height: 40)
                            .background(
                                Group {
                                    if !input.trimmingCharacters(in: .whitespaces).isEmpty && !typing {
                                        LinearGradient(
                                            colors: [AppTheme.teal900, AppTheme.teal700],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        AppTheme.slate200
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || typing)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Text("For informational use only · Consult your physician for medical advice")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(AppTheme.slate400)
                    .padding(.bottom, 12)
            }
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(AppTheme.slate100)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            )
        }
        .background(AppTheme.slate50)
    }

    private func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMsg = ChatMessage(id: msgId, role: "user", text: trimmed, time: "Now")
        msgId += 1
        messages.append(userMsg)
        input = ""
        typing = true

        let delay = 0.9 + Double.random(in: 0...0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let reply = RESPONSES[trimmed] ?? DEFAULT_RESPONSE
            typing = false
            messages.append(ChatMessage(id: msgId, role: "assistant", text: reply, time: "Now"))
            msgId += 1
        }
    }

    private func resetChat() {
        messages = [
            ChatMessage(
                id: msgId,
                role: "assistant",
                text: "Hello! I'm **Medora AI**, your prescription safety assistant. Ask me about drug interactions, dosage guidelines, side effects, or medication alternatives.",
                time: "Now"
            )
        ]
        msgId += 1
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    let isUser: Bool

    init(message: ChatMessage) {
        self.message = message
        self.isUser = message.role == "user"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isUser {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.teal900, AppTheme.teal700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    Text("💊")
                        .font(.system(size: 12))
                }
                .padding(.top, 4)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 0) {
                if isUser {
                    Text(message.text)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(parseMessage(message.text), id: \.self) { line in
                            if line.hasPrefix("• ") {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.teal700)
                                    Text(attributedText(from: String(line.dropFirst(2))))
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.slate800)
                                        .lineSpacing(4)
                                }
                            } else if line.isEmpty {
                                Color.clear.frame(height: 6)
                            } else {
                                Text(attributedText(from: line))
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.slate800)
                                    .lineSpacing(4)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            .background(
                Group {
                    if isUser {
                        LinearGradient(
                            colors: [AppTheme.teal900, AppTheme.teal700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private func parseMessage(_ text: String) -> [String] {
        text.components(separatedBy: "\n")
    }

    private func attributedText(from text: String) -> AttributedString {
        var result = AttributedString(text)
        result.font = .system(size: 12)
        // Simple bold parsing for **text**
        let pattern = "\\*\\*(.*?)\\*\\*"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            for match in matches {
                let innerRange = match.range(at: 1)
                if let innerSwiftRange = Range(innerRange, in: text) {
                    if let start = AttributedString.Index(innerSwiftRange.lowerBound, within: result),
                       let end = AttributedString.Index(innerSwiftRange.upperBound, within: result) {
                        result[start..<end].font = .system(size: 12, weight: .bold)
                    }
                }
            }
        }
        // Clean up leftover ** markers
        result = AttributedString(result.characters.filter { $0 != "*" }.map(String.init).joined())
        return result
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.teal900, AppTheme.teal700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                Text("💊")
                    .font(.system(size: 12))
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(AppTheme.teal400)
                        .frame(width: 6, height: 6)
                        .offset(y: animate ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: animate
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ChatScreen()
}
