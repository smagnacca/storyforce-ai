import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var storyManager: StoryManager
    @State private var showNewStorySheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Good morning")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(authManager.user?.firstName ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    .padding()

                    // Stats
                    VStack(spacing: 12) {
                        StatCard(
                            label: "Stories This Month",
                            value: "12",
                            icon: "book.fill",
                            color: .blue
                        )
                        StatCard(
                            label: "Conversion Rate",
                            value: "67%",
                            icon: "arrow.up.right",
                            color: .green
                        )
                        StatCard(
                            label: "Avg Delivery Score",
                            value: "7.8/10",
                            icon: "star.fill",
                            color: .orange
                        )
                    }
                    .padding()

                    // New Story Button
                    Button(action: { showNewStorySheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("New Story")
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

                    // Recent Stories
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Stories")
                            .font(.headline)
                            .padding(.horizontal)

                        if storyManager.stories.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No stories yet")
                                    .font(.headline)
                                Text("Create your first story to get started")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding()
                        } else {
                            ForEach(storyManager.stories.prefix(3)) { story in
                                NavigationLink(destination: StoryDetailView(story: story)) {
                                    StoryRow(story: story)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showNewStorySheet) {
                NewStorySheet()
                    .environmentObject(authManager)
                    .environmentObject(storyManager)
            }
            .onAppear {
                if let token = authManager.token {
                    Task {
                        await storyManager.fetchStories(token: token)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StoryRow: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(story.clientName)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if let score = story.deliveryScore {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", score))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(6)
                }
            }

            Text("Generated: Today")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthManager())
        .environmentObject(StoryManager())
}
