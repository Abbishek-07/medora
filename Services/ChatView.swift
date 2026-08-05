import SwiftUI

struct ChatView: View {
    @StateObject private var vm = ChatViewModel()
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.messages) { msg in
                            HStack(alignment: .top) {
                                if msg.role == .assistant { Spacer(minLength: 0) }
                                Text(msg.text)
                                    .padding(10)
                                    .foregroundStyle(.primary)
                                    .background(bubbleColor(for: msg))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                if msg.role == .user { Spacer(minLength: 0) }
                            }
                            .id(msg.id)
                        }
                        if vm.isSending {
                            HStack { Spacer(); ProgressView(); Spacer() }
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .onChange(of: vm.messages) { _ in
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            HStack(alignment: .bottom, spacing: 8) {
                TextField("Type a message…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                Button(action: send) {
                    if vm.isSending { ProgressView() } else { Text("Send") }
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            }
            .padding(12)
            .background(.bar)
        }
        .navigationTitle("Pharmacist Assistant")
        .toolbar {
            Button("Clear") { vm.clear() }
        }
    }

    private func bubbleColor(for msg: ChatMessage) -> Color {
        msg.role == .user ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15)
    }

    private func send() {
        let text = input
        input = ""
        Task { await vm.send(text) }
    }
}

#Preview {
    NavigationStack { ChatView() }
}
