//
//  ProfileEditSheet.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//
import SwiftUI

/// Sheet for editing user profile
struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private var settings = UserSettings.shared
    
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Avatar Preview
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.accentBlue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Text(name.prefix(1).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Personal Info") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        settings.userName = name
                        settings.userEmail = email
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                name = settings.userName
                email = settings.userEmail
            }
        }
    }
}

#Preview {
    ProfileEditSheet()
        .preferredColorScheme(.dark)
}
