//
//  ProfileView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Russ Hooper on 8/16/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentPremiumStatus = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userID: user.userID, isPremium: !currentPremiumStatus)
            self.user = try await UserManager.shared.getUser(userID: user.userID)
        }
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserPreference(userID: user.userID, preference: text)
            self.user = try await UserManager.shared.getUser(userID: user.userID)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeUserPreference(userID: user.userID, preference: text)
            self.user = try await UserManager.shared.getUser(userID: user.userID)
        }
    }
    
    func addFavoriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Dune", isPopular: true)

        Task {
            try await UserManager.shared.addFavoriteMovie(userID: user.userID, movie: movie)
            self.user = try await UserManager.shared.getUser(userID: user.userID)
        }
    }
    
    func removeFavoriteMovie() {
        guard let user else { return }

        Task {
            try await UserManager.shared.removeFavoriteMovie(userID: user.userID)
            self.user = try await UserManager.shared.getUser(userID: user.userID)
        }
    }
    
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserID: \(user.userID)'")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { option in
                            
                            Button(option) {
                                if preferenceIsSelected(text: option) {
                                    viewModel.removeUserPreference(text: option)
                                } else {
                                    viewModel.addUserPreference(text: option)
                                }
                                
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(text: option) ? .green : .red)
                            
                        }
                    }
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favoriteMovie == nil {
                        viewModel.addFavoriteMovie()
                        
                    } else {
                        viewModel.removeFavoriteMovie()
                    }
                } label: {
                  //  Text("Favorite movie: \(user.favoriteMovie?.title ?? "")")
                    Text("Favorite movie: \(user.favoriteMovie?.title ?? "")") // issue with this. Can upload, but not download/decode map. Might need to use custom encoding after all.
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
