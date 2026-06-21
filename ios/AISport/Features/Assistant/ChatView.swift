import SwiftUI

@Observable
final class ChatViewModel {
    struct Bubble: Identifiable {
        let id = UUID()
        let role: String   // "user" | "assistant"
        let text: String
    }

    var bubbles: [Bubble] = []
    var input = ""
    var isSending = false
    var errorText: String?

    private var history: [ChatMessage] = []

    @MainActor
    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        input = ""
        errorText = nil
        bubbles.append(Bubble(role: "user", text: text))
        history.append(ChatMessage(role: "user", content: text))
        isSending = true

        do {
            let reply = try await APIClient.shared.chat(messages: history)
            history.append(ChatMessage(role: "assistant", content: reply))
            bubbles.append(Bubble(role: "assistant", text: reply))
        } catch {
            errorText = error.localizedDescription
        }
        isSending = false
    }
}

struct ChatView: View {
    @State private var vm = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            if vm.bubbles.isEmpty {
                                ContentUnavailableView(
                                    "AI-асистент",
                                    systemImage: "bubble.left.and.bubble.right",
                                    description: Text("Спитай про тренування, харчування або попроси скласти план.")
                                )
                                .padding(.top, 60)
                            }
                            ForEach(vm.bubbles) { bubble in
                                ChatBubbleView(bubble: bubble).id(bubble.id)
                            }
                            if vm.isSending {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: vm.bubbles.count) {
                        if let last = vm.bubbles.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                if let error = vm.errorText {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                inputBar
            }
            .navigationTitle("Асистент")
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Повідомлення…", text: $vm.input, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
            Button {
                Task { await vm.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill").font(.title)
            }
            .disabled(vm.input.trimmingCharacters(in: .whitespaces).isEmpty || vm.isSending)
        }
        .padding()
    }
}

private struct ChatBubbleView: View {
    let bubble: ChatViewModel.Bubble
    private var isUser: Bool { bubble.role == "user" }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(bubble.text)
                .padding(10)
                .background(
                    isUser ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .textSelection(.enabled)
            if !isUser { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    ChatView()
}
