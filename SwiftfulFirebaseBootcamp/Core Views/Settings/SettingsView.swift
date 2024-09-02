//
//  SettingsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Russ Hooper on 7/21/24.
//

import SwiftUI


struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                        
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        // need to ask for conformation and re-authorize user to delete. Would also need to delete them from the Firestore database
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
                
            } label: {
                Text("Delete account")
            }
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}


//
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            SettingsView(showSignInView: .constant(false))
//        }
//    }
//}

extension SettingsView {
    
    private var emailSection: some View {
        
        Section {
            
            Button("Reset password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password reset")
                    } catch {
                        print(error)
                        
                    }
                }
            }
            
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("Password updated")
                    } catch {
                        print(error)
                        
                    }
                }
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Email updated")
                    } catch {
                        print(error)
                        
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
        
        
    }
}
