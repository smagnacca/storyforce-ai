import SwiftUI

@main
struct StoryForceApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var storyManager = StoryManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(storyManager)
            } else {
                AuthView()
                    .environmentObject(authManager)
            }
        }
    }
}

// ============================================================================
// AUTH MANAGER
// ============================================================================
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var token: String?
    @Published var isLoading = false
    @Published var error: String?

    private let apiBaseURL = "http://localhost:3000/api"

    func signup(email: String, password: String, firstName: String, lastName: String, company: String?, role: String?) async {
        DispatchQueue.main.async { self.isLoading = true }

        let payload = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "company": company as Any,
            "role": role as Any
        ] as [String : Any]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async {
                self.error = "Failed to create request"
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: URL(string: "\(apiBaseURL)/auth/signup")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw NSError(domain: "APIError", code: -1)
            }

            let decoder = JSONDecoder()
            let authResponse = try decoder.decode(AuthResponse.self, from: data)

            DispatchQueue.main.async {
                self.user = authResponse.user
                self.token = authResponse.token
                self.isAuthenticated = true
                self.isLoading = false
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func login(email: String, password: String) async {
        DispatchQueue.main.async { self.isLoading = true }

        let payload = ["email": email, "password": password]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async {
                self.error = "Failed to create request"
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: URL(string: "\(apiBaseURL)/auth/login")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "APIError", code: -1)
            }

            let decoder = JSONDecoder()
            let authResponse = try decoder.decode(AuthResponse.self, from: data)

            DispatchQueue.main.async {
                self.user = authResponse.user
                self.token = authResponse.token
                self.isAuthenticated = true
                self.isLoading = false
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func logout() {
        isAuthenticated = false
        user = nil
        token = nil
    }
}

// ============================================================================
// STORY MANAGER
// ============================================================================
class StoryManager: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var error: String?

    private let apiBaseURL = "http://localhost:3000/api"

    func generateStory(clientProfile: ClientProfile, token: String) async {
        DispatchQueue.main.async { self.isLoading = true }

        guard let jsonData = try? JSONEncoder().encode(clientProfile) else {
            DispatchQueue.main.async {
                self.error = "Failed to encode profile"
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: URL(string: "\(apiBaseURL)/stories/generate")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                throw NSError(domain: "APIError", code: -1)
            }

            let decoder = JSONDecoder()
            let story = try decoder.decode(Story.self, from: data)

            DispatchQueue.main.async {
                self.stories.append(story)
                self.isLoading = false
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func fetchStories(token: String) async {
        DispatchQueue.main.async { self.isLoading = true }

        var request = URLRequest(url: URL(string: "\(apiBaseURL)/stories")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "APIError", code: -1)
            }

            let decoder = JSONDecoder()
            let storiesResponse = try decoder.decode([Story].self, from: data)

            DispatchQueue.main.async {
                self.stories = storiesResponse
                self.isLoading = false
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// ============================================================================
// DATA MODELS
// ============================================================================
struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let company: String?
    let role: String?
    let subscriptionTier: String

    enum CodingKeys: String, CodingKey {
        case id, email, company, role
        case firstName = "firstName"
        case lastName = "lastName"
        case subscriptionTier = "subscriptionTier"
    }
}

struct ClientProfile: Codable, Identifiable {
    let id: String
    let clientName: String
    let clientRole: String
    let company: String
    let industry: String
    let currentWinter: WinterState
    let desiredSpring: SpringState

    enum CodingKeys: String, CodingKey {
        case id
        case clientName = "clientName"
        case clientRole = "clientRole"
        case company, industry
        case currentWinter = "currentWinter"
        case desiredSpring = "desiredSpring"
    }
}

struct WinterState: Codable {
    let primaryFear: String
    let painPoints: [String]
    let decisionStyle: String
    let timeline: String

    enum CodingKeys: String, CodingKey {
        case primaryFear = "primaryFear"
        case painPoints = "painPoints"
        case decisionStyle = "decisionStyle"
        case timeline
    }
}

struct SpringState: Codable {
    let mainGoal: String
    let successMetrics: [String]
    let emotionalOutcome: String

    enum CodingKeys: String, CodingKey {
        case mainGoal = "mainGoal"
        case successMetrics = "successMetrics"
        case emotionalOutcome = "emotionalOutcome"
    }
}

struct Story: Codable, Identifiable {
    let id: String
    let clientName: String
    let act1Hook: String
    let act2Bridge: String
    let act3Payoff: String
    let metaphors: [String]
    let deliveryScore: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case clientName = "clientName"
        case act1Hook = "act1Hook"
        case act2Bridge = "act2Bridge"
        case act3Payoff = "act3Payoff"
        case metaphors
        case deliveryScore = "deliveryScore"
    }
}
