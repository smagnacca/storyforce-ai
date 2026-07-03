import SwiftUI

struct StoriesListView: View {
    @EnvironmentObject var storyManager: StoryManager
    @State private var showNewStorySheet = false
    @State private var searchText = ""

    var filteredStories: [Story] {
        if searchText.isEmpty {
            return storyManager.stories
        }
        return storyManager.stories.filter { story in
            story.clientName.localizedCaseInsensitiveContains(searchText) ||
            story.company.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search by client or company...")
                    .padding()

                if storyManager.isLoading && storyManager.stories.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your stories...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredStories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Stories Yet")
                            .font(.headline)
                        Text("Create your first AI-powered story to get started")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Button(action: { showNewStorySheet = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Story")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredStories, id: \.id) { story in
                            NavigationLink(destination: StoryDetailView(story: story)) {
                                StoryListItemView(story: story)
                            }
                        }
                        .onDelete(perform: deleteStories)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Stories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewStorySheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showNewStorySheet) {
                NewStorySheet()
                    .environmentObject(storyManager)
            }
            .onAppear {
                Task {
                    await storyManager.fetchStories()
                }
            }
        }
    }

    private func deleteStories(offsets: IndexSet) {
        // Implement delete logic
    }
}

struct StoryListItemView: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(story.clientName)
                        .font(.headline)
                        .fontWeight(.bold)

                    if !story.company.isEmpty {
                        Text(story.company)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formatDate(story.createdAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let score = story.deliveryScore, score > 0 {
                    VStack(alignment: .center, spacing: 4) {
                        Text(String(format: "%.1f", score))
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                }
            }

            Divider()

            HStack(spacing: 16) {
                Label("Practice", systemImage: "mic.circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.none)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct NewStorySheet: View {
    @EnvironmentObject var storyManager: StoryManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedClientProfile = ""
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create New Story")
                    .font(.title2)
                    .fontWeight(.bold)

                // Client Profile Selector (stub for now)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Client")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Picker("Client", selection: $selectedClientProfile) {
                        Text("Mike Johnson (TechCorp)").tag("1")
                        Text("Sarah Chen (FinanceCorp)").tag("2")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("About this client's situation:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Text("Our AI analyzes your client's pain points and vision to create a personalized Three-Act story tailored to their situation.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }

                Spacer()

                Button(action: generateStory) {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Generate Story")
                                .fontWeight(.semibold)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(isGenerating || selectedClientProfile.isEmpty)

                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func generateStory() {
        isGenerating = true
        Task {
            // Simulated story generation
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            isGenerating = false
            dismiss()
        }
    }
}

#Preview {
    StoriesListView()
        .environmentObject(StoryManager())
}
