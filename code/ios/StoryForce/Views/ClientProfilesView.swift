import SwiftUI

struct ClientProfilesView: View {
    @State private var profiles: [ClientProfile] = []
    @State private var showNewProfileSheet = false
    @State private var searchText = ""
    @State private var isLoading = false

    var filteredProfiles: [ClientProfile] {
        if searchText.isEmpty {
            return profiles
        }
        return profiles.filter { profile in
            profile.clientName.localizedCaseInsensitiveContains(searchText) ||
            profile.company.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search clients or companies...")
                    .padding()

                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading client profiles...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if profiles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Client Profiles")
                            .font(.headline)
                        Text("Create profiles to capture client needs and vision")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Button(action: { showNewProfileSheet = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                Text("New Profile")
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
                        ForEach(filteredProfiles, id: \.id) { profile in
                            NavigationLink(destination: ClientProfileDetailView(profile: profile)) {
                                ClientProfileListItemView(profile: profile)
                            }
                        }
                        .onDelete(perform: deleteProfile)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Client Profiles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewProfileSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showNewProfileSheet) {
                NewClientProfileSheet()
            }
            .onAppear {
                loadProfiles()
            }
        }
    }

    private func loadProfiles() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            profiles = [
                ClientProfile(
                    id: "1",
                    clientName: "Mike Johnson",
                    company: "TechCorp",
                    industry: "Technology",
                    winterState: WinterState(
                        fear: "Missing sales targets",
                        pain: "Lengthy sales cycles",
                        frustration: "Inconsistent messaging"
                    ),
                    springState: SpringState(
                        vision: "Close deals faster",
                        outcome: "20% revenue increase",
                        feeling: "Confident and aligned"
                    )
                ),
                ClientProfile(
                    id: "2",
                    clientName: "Sarah Chen",
                    company: "FinanceCorp",
                    industry: "Finance",
                    winterState: WinterState(
                        fear: "Client churn",
                        pain: "Weak client relationships",
                        frustration: "Generic pitches"
                    ),
                    springState: SpringState(
                        vision: "Deep client partnerships",
                        outcome: "Higher retention rates",
                        feeling: "Connected and valued"
                    )
                ),
            ]
            isLoading = false
        }
    }

    private func deleteProfile(offsets: IndexSet) {
        profiles.remove(atOffsets: offsets)
    }
}

struct ClientProfileListItemView: View {
    let profile: ClientProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.clientName)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(profile.company)
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let industry = profile.industry {
                        HStack(spacing: 4) {
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(industry)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Divider()

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current State")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text("Winter")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Desired State")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text("Spring")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

struct ClientProfileDetailView: View {
    let profile: ClientProfile
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.clientName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(profile.company)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if let industry = profile.industry {
                        HStack(spacing: 4) {
                            Image(systemName: "building.2")
                            Text(industry)
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                .padding()

                Divider()

                // Winter State
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "snowflake")
                            .foregroundColor(.blue)
                        Text("Current State (Winter)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ProfileStateRow(label: "Fear", value: profile.winterState.fear)
                        ProfileStateRow(label: "Pain", value: profile.winterState.pain)
                        ProfileStateRow(label: "Frustration", value: profile.winterState.frustration)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()

                // Spring State
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "leaf")
                            .foregroundColor(.green)
                        Text("Desired State (Spring)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ProfileStateRow(label: "Vision", value: profile.springState.vision)
                        ProfileStateRow(label: "Outcome", value: profile.springState.outcome)
                        ProfileStateRow(label: "Feeling", value: profile.springState.feeling)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
        }
        .navigationTitle("Client Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileStateRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            Text(value)
                .font(.body)
                .lineSpacing(2)
        }
    }
}

struct NewClientProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var clientName = ""
    @State private var company = ""
    @State private var industry = ""
    @State private var winterFear = ""
    @State private var winterPain = ""
    @State private var springVision = ""
    @State private var springOutcome = ""
    @State private var isSaving = false

    var isFormValid: Bool {
        !clientName.isEmpty && !company.isEmpty && !winterFear.isEmpty && !springVision.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Basic Information")
                            .font(.headline)
                            .fontWeight(.bold)

                        TextField("Client Name", text: $clientName)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        TextField("Company", text: $company)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        TextField("Industry (optional)", text: $industry)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()

                    // Winter State
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "snowflake")
                                .foregroundColor(.blue)
                            Text("Current State (Winter)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }

                        TextField("What's their biggest fear?", text: $winterFear, axis: .vertical)
                            .lineLimit(3...)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        TextField("What pain are they experiencing?", text: $winterPain, axis: .vertical)
                            .lineLimit(3...)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()

                    // Spring State
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "leaf")
                                .foregroundColor(.green)
                            Text("Desired State (Spring)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }

                        TextField("What's their vision?", text: $springVision, axis: .vertical)
                            .lineLimit(3...)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        TextField("What outcome do they want?", text: $springOutcome, axis: .vertical)
                            .lineLimit(3...)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()

                    // Save Button
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Profile")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isFormValid || isSaving)
                    .padding()
                }
            }
            .navigationTitle("New Client Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveProfile() {
        isSaving = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
            dismiss()
        }
    }
}

#Preview {
    ClientProfilesView()
}
