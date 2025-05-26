import SwiftUI

struct SecurityView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case currentPassword, newPassword, confirmPassword
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Password")
                        .font(.headline)
                        .foregroundColor(.white)
                    SecureField("Enter your current password", text: $currentPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .currentPassword)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .newPassword
                        }
                }
                
                // New Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("New Password")
                        .font(.headline)
                        .foregroundColor(.white)
                    SecureField("Enter your new password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .newPassword)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }
                }
                
                // Confirm New Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm New Password")
                        .font(.headline)
                        .foregroundColor(.white)
                    SecureField("Confirm your new password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                            changePassword()
                        }
                }
                
                // Change Password Button
                Button(action: {
                    focusedField = nil
                    changePassword()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Change Password")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading)
            }
            .padding()
        }
        .navigationTitle("Security")
        .background(Color("CynaBg"))
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private func changePassword() {
        print("Starting password change process...")
        
        // Validation
        guard !currentPassword.isEmpty else {
            print("Validation failed: Current password is empty")
            alertMessage = "Please enter your current password"
            showAlert = true
            return
        }
        
        guard !newPassword.isEmpty else {
            print("Validation failed: New password is empty")
            alertMessage = "Please enter your new password"
            showAlert = true
            return
        }
        
        guard newPassword == confirmPassword else {
            print("Validation failed: New passwords do not match")
            alertMessage = "New passwords do not match"
            showAlert = true
            return
        }
        
        guard newPassword.count >= 12 else {
            print("Validation failed: New password is too short (length: \(newPassword.count))")
            alertMessage = "New password must be at least 12 characters long"
            showAlert = true
            return
        }
        
        print("All validations passed")
        isLoading = true
        
        // Get the auth token
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Error: No auth token found in UserDefaults")
            alertMessage = "You must be logged in to change your password"
            showAlert = true
            isLoading = false
            return
        }
        print("Auth token retrieved successfully")
        
        // Prepare the request
        let urlString = "\(AppConstants.baseURL)en/api/user/dashboard/security/password"
        print("Preparing request to URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL format")
            alertMessage = "Invalid URL"
            showAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("Request body prepared successfully")
        } catch {
            print("Error preparing request body: \(error.localizedDescription)")
            alertMessage = "Error preparing request"
            showAlert = true
            isLoading = false
            return
        }
        
        // Make the request
        print("Sending request to server...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error: Invalid response type")
                    alertMessage = "Invalid response"
                    showAlert = true
                    return
                }
                
                print("Server response status code: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Server response data: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    print("Password changed successfully")
                    alertMessage = "Password changed successfully"
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                } else {
                    print("Password change failed with status code: \(httpResponse.statusCode)")
                    alertMessage = "Failed to change password. Please try again."
                }
                
                showAlert = true
            }
        }.resume()
    }
}

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecurityView()
        }
    }
} 
