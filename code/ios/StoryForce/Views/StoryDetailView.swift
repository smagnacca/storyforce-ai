import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @State private var selectedAct = 1
    @State private var showPracticeSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text(story.clientName)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let score = story.deliveryScore {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f/10", score))
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                // Act Selector
                Picker("Act", selection: $selectedAct) {
                    Text("Act 1: Hook").tag(1)
                    Text("Act 2: Bridge").tag(2)
                    Text("Act 3: Payoff").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()

                // Story Content
                VStack(alignment: .leading, spacing: 15) {
                    Text(getActTitle())
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(getActContent())
                        .font(.body)
                        .lineSpacing(8)
                        .foregroundColor(.primary)

                    Divider()

                    Text("Delivery Tip")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Text(getDeliveryTip())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()

                // Metaphors
                if !story.metaphors.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Related Metaphors")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ForEach(story.metaphors, id: \.self) { metaphor in
                            HStack(spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                                Text(metaphor)
                                    .font(.caption)
                                Spacer()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }

                // Practice Button
                Button(action: { showPracticeSheet = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "mic.circle.fill")
                        Text("Practice This Story")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()

                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Story Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPracticeSheet) {
            PracticeView(story: story)
        }
    }

    private func getActTitle() -> String {
        switch selectedAct {
        case 1:
            return "Act 1: The Hook"
        case 2:
            return "Act 2: The Bridge"
        case 3:
            return "Act 3: The Payoff"
        default:
            return ""
        }
    }

    private func getActContent() -> String {
        switch selectedAct {
        case 1:
            return story.act1Hook
        case 2:
            return story.act2Bridge
        case 3:
            return story.act3Payoff
        default:
            return ""
        }
    }

    private func getDeliveryTip() -> String {
        switch selectedAct {
        case 1:
            return "Pause for 2 seconds after delivering the hook to let it land emotionally."
        case 2:
            return "Tell the bridge story with warmth and specific details. Make it relatable."
        case 3:
            return "Paint the vision with emotion. Help them see, feel, and believe in the future."
        default:
            return ""
        }
    }
}

struct PracticeView: View {
    let story: Story
    @Environment(\.dismiss) var dismiss
    @State private var isRecording = false
    @State private var recordingTime = 0
    @State private var showFeedback = false
    @State private var deliveryScore = 0.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Practice Mode")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Read the story aloud and get real-time feedback")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()

                Spacer()

                // Recording Button
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(isRecording ? Color.red : Color.blue)
                            .frame(width: 100, height: 100)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }

                    Button(action: toggleRecording) {
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isRecording ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    if isRecording {
                        Text("\(recordingTime)s")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    recordingTime += 1
                                }
                            }
                    }
                }

                Spacer()

                // Close Button
                Button(action: { dismiss() }) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func toggleRecording() {
        isRecording.toggle()
        if !isRecording {
            recordingTime = 0
            showFeedback = true
            deliveryScore = 8.2
        }
    }
}

#Preview {
    StoryDetailView(story: Story(
        id: "1",
        clientName: "Mike Johnson",
        act1Hook: "I see your fear...",
        act2Bridge: "I had a client named Sarah...",
        act3Payoff: "By following the same approach...",
        metaphors: ["Like a gardener trimming branches..."],
        deliveryScore: 8.2
    ))
}
