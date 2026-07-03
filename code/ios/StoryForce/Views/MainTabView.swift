import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var storyManager: StoryManager
    @State private var selectedTab: Tab = .dashboard

    enum Tab {
        case dashboard
        case stories
        case profiles
        case analytics
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            Dashboard()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(Tab.dashboard)

            // Stories Tab
            StoriesListView()
                .environmentObject(storyManager)
                .tabItem {
                    Label("Stories", systemImage: "book.fill")
                }
                .tag(Tab.stories)

            // Client Profiles Tab
            ClientProfilesView()
                .tabItem {
                    Label("Profiles", systemImage: "person.2.fill")
                }
                .tag(Tab.profiles)

            // Analytics Tab
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(Tab.analytics)

            // Settings Tab
            SettingsView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        .accentColor(.blue)
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // User Profile Section
                Section("Profile") {
                    if let user = authManager.user {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(user.firstName + " " + user.lastName)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(user.company ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }

                // Account Section
                Section("Account") {
                    NavigationLink(destination: SubscriptionView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 18))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Subscription")
                                    .font(.body)
                                if let user = authManager.user {
                                    Text(user.subscriptionTier.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    NavigationLink(destination: UsageView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 18))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Usage")
                                    .font(.body)
                                Text("Stories & practice sessions")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                // Support Section
                Section("Support") {
                    Link(destination: URL(string: "https://storyforce.ai/help")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 18))

                            Text("Help & Support")
                        }
                    }

                    Link(destination: URL(string: "https://storyforce.ai/privacy")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))

                            Text("Privacy Policy")
                        }
                    }
                }

                // Logout Section
                Section {
                    Button(role: .destructive, action: { showLogoutConfirm = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Logout")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Logout", isPresented: $showLogoutConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct SubscriptionView: View {
    var body: some View {
        List {
            Section("Current Plan") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Professional")
                            .font(.headline)
                        Spacer()
                        Text("$12.99/mo")
                            .fontWeight(.bold)
                    }
                    Text("Unlimited stories • AI coaching • Analytics")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }

            Section("Available Plans") {
                VStack(alignment: .leading, spacing: 12) {
                    PlanOption(
                        name: "Free",
                        price: "$0",
                        features: ["5 stories/month", "Basic practice"],
                        isCurrent: false
                    )

                    PlanOption(
                        name: "Professional",
                        price: "$12.99/mo",
                        features: [
                            "Unlimited stories",
                            "AI coaching",
                            "Analytics",
                            "Priority support",
                        ],
                        isCurrent: true
                    )

                    PlanOption(
                        name: "Team",
                        price: "$99/mo",
                        features: [
                            "Everything in Pro",
                            "Team management",
                            "Advanced analytics",
                            "Dedicated support",
                        ],
                        isCurrent: false
                    )
                }
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlanOption: View {
    let name: String
    let price: String
    let features: [String]
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if isCurrent {
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(isCurrent ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct UsageView: View {
    var body: some View {
        List {
            Section("Stories This Month") {
                HStack {
                    Text("Used")
                    Spacer()
                    Text("12 / Unlimited")
                        .fontWeight(.semibold)
                }

                ProgressView(value: 0.12)
                    .tint(.blue)
            }

            Section("Practice Sessions") {
                HStack {
                    Text("This Month")
                    Spacer()
                    Text("34 sessions")
                        .fontWeight(.semibold)
                }
            }

            Section("Storage") {
                HStack {
                    Text("Audio Files")
                    Spacer()
                    Text("512 MB / 2 GB")
                        .fontWeight(.semibold)
                }

                ProgressView(value: 0.256)
                    .tint(.green)
            }
        }
        .navigationTitle("Usage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
        .environmentObject(StoryManager())
}
