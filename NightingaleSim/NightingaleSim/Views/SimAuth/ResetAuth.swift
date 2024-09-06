//
//  ResetAuth.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/13/24.
//

import SwiftUI

struct ResetAuth: View {
    @Binding var currentView: AppView
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var errorMessage: String? = nil
    @State private var resetEmail: String = ""
    @State private var resetCode: String = ""
    @State private var resetExpiration: String = ""
    @State private var enteredResetCode: String = ""
    @State private var isReset = true
    @State private var isResetValid = false
    @State private var currentPassword: String = ""
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        self.currentView = .LoginAuth
                    }) {
                        Image(systemName: "arrow.backward.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: geometry.size.height * 0.03)
                            .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                            .padding(.leading, geometry.size.width * 0.03)
                            .padding(.top, geometry.size.height * 0.03)
                            .foregroundColor(Color.white)
                    }
                    
                    Spacer()
                }
                ZStack {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            VStack {
                                HStack {
                                    
                                    Text("Forgot Password?")
                                        .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                        .foregroundStyle(Color.black).opacity(0.8)
                                        .multilineTextAlignment(.center)
                                        .padding(.leading, geometry.size.width * 0.04)
                                    
                                    Spacer()
                                }
                                .frame(width: geometry.size.width * 0.8)
                                .frame(height: geometry.size.height * 0.06)
                                .background(Color(hex: 0xDFDFDF))
                                
                                VStack {
                                    if isReset {
                                        HStack {
                                            Text("Email Address")
                                                .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                                .foregroundColor(Color.black).opacity(0.6)
                                            
                                            Spacer()
                                        }
                                        .frame(width: geometry.size.width * 0.5)
                                        .padding(.top, geometry.size.height * 0.04)
                                        
                                        
                                        TextField("", text: $resetEmail)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .foregroundColor(.black)
                                            .font(.system(size: geometry.size.height * 0.018, weight: .light, design: .default))
                                            .multilineTextAlignment(.leading)
                                            .padding(geometry.size.height * 0.01)
                                            .background(Color.white)
                                            .border(Color(hex: 0xDFE6E9), width: geometry.size.width * 0.003)
                                            .cornerRadius(geometry.size.width * 0.01)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                    .stroke(Color(hex: 0xDFE6E9), lineWidth: geometry.size.width * 0.004)
                                            )
                                            .frame(width: geometry.size.width * 0.5)
                                        
                                        Button(action: {
                                            self.initiatePasswordReset()
                                        }) {
                                            Text("Send Reset Code")
                                                .font(.system(size: geometry.size.height * 0.016, weight: resetEmail != "" && resetEmail.contains("@") ? .bold : .regular))
                                                .foregroundColor(resetEmail != "" && resetEmail.contains("@") ? .white : .black.opacity(0.8))
                                                .frame(width: geometry.size.width * 0.4)
                                                .padding(.vertical, geometry.size.height * 0.012)
                                                .background(resetEmail != "" && resetEmail.contains("@") ? Color(hex: 0x5C2BE2) : Color(hex: 0xDFDFDF))
                                                .cornerRadius(geometry.size.width * 0.01)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                        .stroke(resetEmail != "" && resetEmail.contains("@") ? Color(hex: 0x5C2BE2) : Color.black.opacity(0.8), lineWidth: geometry.size.height * 0.0006)
                                                )
                                        }
                                        .padding(.top, geometry.size.height * 0.04)
                                    } else {
                                        if !isResetValid {
                                            HStack {
                                                Text("Enter Your Password Reset Code")
                                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                                    .foregroundColor(Color.black).opacity(0.6)
                                                
                                                Spacer()
                                            }
                                            .frame(width: geometry.size.width * 0.5)
                                            .padding(.top, geometry.size.height * 0.04)
                                            
                                            
                                            TextField("", text: $enteredResetCode)
                                                .disableAutocorrection(true)
                                                .foregroundColor(.black)
                                                .font(.system(size: geometry.size.height * 0.018, weight: .light, design: .default))
                                                .multilineTextAlignment(.leading)
                                                .padding(geometry.size.height * 0.01)
                                                .background(Color.white)
                                                .border(Color(hex: 0xDFE6E9), width: geometry.size.width * 0.003)
                                                .cornerRadius(geometry.size.width * 0.01)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                        .stroke(Color(hex: 0xDFE6E9), lineWidth: geometry.size.width * 0.004)
                                                )
                                                .frame(width: geometry.size.width * 0.5)
                                                .onChange(of: enteredResetCode) { newValue in
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

                                                    if let expirationTime = dateFormatter.date(from: resetExpiration), newValue == resetCode {
                                                        let currentTime = Date()
                                                        if currentTime < expirationTime {
                                                            isResetValid = true
                                                            errorMessage = ""
                                                        } else {
                                                            isResetValid = false
                                                            errorMessage = "Reset code has expired."
                                                        }
                                                    } else {
                                                        isResetValid = false
                                                        errorMessage = ""
                                                    }
                                                }
                                        } else {
                                            HStack {
                                                ZStack {
                                                    if isNewPasswordVisible {
                                                        TextField("", text: $newPassword)
                                                            .autocapitalization(.none)
                                                            .disableAutocorrection(true)
                                                            .foregroundColor(.black)
                                                            .font(.system(size: geometry.size.height * 0.018, weight: .light, design: .default))
                                                            .multilineTextAlignment(.leading)
                                                            .padding(geometry.size.height * 0.01)
                                                            .background(Color.white)
                                                            .border(Color(hex: 0xDFE6E9), width: geometry.size.width * 0.003)
                                                            .cornerRadius(geometry.size.width * 0.01)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                                    .stroke(Color(hex: 0xDFE6E9), lineWidth: geometry.size.width * 0.004)
                                                            )
                                                            .frame(width: geometry.size.width * 0.5)
                                                    } else {
                                                        SecureField("", text: $newPassword)
                                                            .autocapitalization(.none)
                                                            .disableAutocorrection(true)
                                                            .foregroundColor(.black)
                                                            .font(.system(size: geometry.size.height * 0.018, weight: .light, design: .default))
                                                            .multilineTextAlignment(.leading)
                                                            .padding(geometry.size.height * 0.01)
                                                            .background(Color.white)
                                                            .border(Color(hex: 0xDFE6E9), width: geometry.size.width * 0.003)
                                                            .cornerRadius(geometry.size.width * 0.01)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                                    .stroke(Color(hex: 0xDFE6E9), lineWidth: geometry.size.width * 0.004)
                                                            )
                                                            .frame(width: geometry.size.width * 0.5)
                                                    }
                                                    
                                                    HStack {
                                                        Spacer()
                                                        Button(action: {
                                                            isNewPasswordVisible.toggle()
                                                        }) {
                                                            Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: geometry.size.width * 0.016)
                                                                .frame(height: geometry.size.height * 0.016)
                                                                .foregroundColor(Color(hex: 0x828B8E))
                                                        }
                                                        .padding(.trailing, geometry.size.width * 0.03)
                                                    }
                                                    .frame(width: geometry.size.width * 0.5)
                                                }
                                            }
                                            .padding(.top, geometry.size.height * 0.04)
                                            
                                            HStack {
                                                ZStack {
                                                    if isConfirmPasswordVisible {
                                                        TextField("", text: $confirmPassword)
                                                            .autocapitalization(.none)
                                                            .disableAutocorrection(true)
                                                            .foregroundColor(.black)
                                                            .font(.system(size: geometry.size.height * 0.018, weight: .light, design: .default))
                                                            .multilineTextAlignment(.leading)
                                                            .padding(geometry.size.height * 0.01)
                                                            .background(Color.white)
                                                            .border(Color(hex: 0xDFE6E9), width: geometry.size.width * 0.003)
                                                            .cornerRadius(geometry.size.width * 0.01)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                                    .stroke(Color(hex: 0xDFE6E9), lineWidth: geometry.size.width * 0.004)
                                                            )
                                                            .frame(width: geometry.size.width * 0.5)
                                                    } else {
                                                        SecureField("", text: $confirmPassword)
                                                            .autocapitalization(.none)
                                                            .disableAutocorrection(true)
                                                            .foregroundColor(.black)
                                                            .font(.system(size: geometry.size.height * 0.018, weight: .light, design: .default))
                                                            .multilineTextAlignment(.leading)
                                                            .padding(geometry.size.height * 0.01)
                                                            .background(Color.white)
                                                            .border(Color(hex: 0xDFE6E9), width: geometry.size.width * 0.003)
                                                            .cornerRadius(geometry.size.width * 0.01)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                                    .stroke(Color(hex: 0xDFE6E9), lineWidth: geometry.size.width * 0.004)
                                                            )
                                                            .frame(width: geometry.size.width * 0.5)
                                                    }
                                                    
                                                    HStack {
                                                        Spacer()
                                                        Button(action: {
                                                            isConfirmPasswordVisible.toggle()
                                                        }) {
                                                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: geometry.size.width * 0.016)
                                                                .frame(height: geometry.size.height * 0.016)
                                                                .foregroundColor(Color(hex: 0x828B8E))
                                                        }
                                                        .padding(.trailing, geometry.size.width * 0.03)
                                                    }
                                                    .frame(width: geometry.size.width * 0.5)
                                                }
                                            }
                                            .padding(.top, geometry.size.height * 0.02)
                                            
                                            Button(action: {
                                                self.validateNewPassword()
                                            }) {
                                                Text("Save New Password")
                                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: geometry.size.width * 0.4)
                                                    .padding(.vertical, geometry.size.height * 0.012)
                                                    .background(Color(hex: 0x5C2BE2))
                                                    .cornerRadius(geometry.size.width * 0.01)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                                            .stroke(Color(hex: 0x5C2BE2), lineWidth: geometry.size.height * 0.0006)
                                                    )
                                            }
                                            .padding(.top, geometry.size.height * 0.04)
                                        }
                                    }
                                    
                                    if let errorMessage = errorMessage {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                            .font(.system(size: geometry.size.height * 0.012))
                                            .padding(.top, geometry.size.height * 0.02)
                                            .background(Color.clear)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                            .frame(width: geometry.size.width * 0.8)
                            .padding(.bottom, geometry.size.height * 0.06)
                            .background(Color.white)
                            .cornerRadius(geometry.size.width * 0.01)
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.01)
                                    .stroke(Color.black.opacity(0.2), lineWidth: geometry.size.height * 0.0006)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 6, y: 6)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
            }
            .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 1.0)
            .background(gradient)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    private func initiatePasswordReset() {
        guard let url = URL(string: "https://nightingale-health.duckdns.org/nightingale/api/reset-password") else {
            return
        }

        let requestBody: [String: Any] = ["email": resetEmail]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Error: \(error.localizedDescription)"
                    } else if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let message = jsonResponse["message"] as? String {
                                    
                                    if message == "Password reset code sent." {
                                        self.resetCode = jsonResponse["resetCode"] as? String ?? "N/A"
                                        self.resetExpiration = jsonResponse["resetExpiration"] as? String ?? "N/A"
                                        self.currentPassword = jsonResponse["currentPassword"] as? String ?? "N/A"
                                        self.isReset = false
                                        self.isResetValid = false
                                    } else {
                                        self.resetCode = ""
                                        self.resetExpiration = ""
                                        self.isReset = true
                                    }
                                }
                            } else {
                                self.errorMessage = "Invalid API response."
                            }
                        } catch {
                            self.errorMessage = "Failed to parse JSON response."
                        }
                    }
                }
            }.resume()
        } catch {
            errorMessage = "Failed to serialize request body."
        }
    }
    private func validateNewPassword() {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            self.errorMessage = "All fields are required."
            return
        }

        guard newPassword == confirmPassword else {
            self.errorMessage = "Passwords do not match."
            return
        }

        guard isValidPassword(newPassword) else {
            self.errorMessage = "Password must contain at least 8 characters, including uppercase, lowercase, digits, and special characters."
            return
        }
        self.setNewPassword()
    }
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    private func setNewPassword() {
        let requestBody: [String: Any] = [
            "newPassword": newPassword,
            "email": resetEmail
        ]
        
        let url = URL(string: "https://nightingale-health.duckdns.org/nightingale/api/change-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.errorMessage = "Password reset failed: \(error.localizedDescription)."
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                self.errorMessage = "Password reset failed: No response received."
                return
            }
            
            if response.statusCode == 200 {
                currentView = .LoginAuth
            }
        }
        .resume()
    }
}
