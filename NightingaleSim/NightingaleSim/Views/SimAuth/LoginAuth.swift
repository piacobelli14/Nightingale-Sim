//
//  AuthLogin.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/13/24.
//

import SwiftUI

struct LoginAuth: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String
    @Binding var authenticatedOrgID: String
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var errorMessage: String? = nil
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoginSuccessful: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Text("Welcome to")
                        .font(.system(size: geometry.size.height * 0.03, weight: .semibold))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                .padding(.vertical, 0)
                
                HStack {
                    Text("Nightingale Sim")
                        .font(.system(size: geometry.size.height * 0.05, weight: .bold))
                        .foregroundColor(Color.white)
                        .opacity(1.0)
                        .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 0)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                .padding(.vertical, 0)
                
                HStack {
                    VStack {
                        HStack {
                            Text("Username")
                                .font(.system(size: geometry.size.height * 0.022, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                                .shadow(color: .gray.opacity(0.3), radius: 0, x: 0, y: 2)
                                .padding(.leading, geometry.size.width * 0.005)
                            Spacer()
                        }
                        
                        HStack {
                            TextField("", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .font(.system(size: geometry.size.height * 0.02, weight: .light, design: .default))
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, geometry.size.height * 0.016)
                                .padding(.horizontal, geometry.size.width * 0.02)
                                .background(Color(hex: 0xF5F5F5).opacity(0.9))
                                .border(Color(hex: 0x504F51), width: geometry.size.width * 0.002)
                                .cornerRadius(geometry.size.height * 0.01)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                        .stroke(Color(hex: 0x504F51), lineWidth: geometry.size.width * 0.002)
                                )
                                .frame(width: geometry.size.width * 0.7)
                                .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
                                .padding(.top, geometry.size.height * -0.01)
                            
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                .padding(.top, geometry.size.height * 0.04)
                
                HStack {
                    Button(action: {
                        self.currentView = .ResetAuth
                    }) {
                        HStack {
                            Text("Forgot password?")
                                .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                                .padding(.leading, geometry.size.width * 0.005)
                            
                            Text("Click here to reset.")
                                .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                .foregroundColor(Color(hex: 0xDA64ED))
                                .padding(0)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                
                HStack {
                    VStack {
                        HStack {
                            Text("Password")
                                .font(.system(size: geometry.size.height * 0.022, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                                .shadow(color: .gray.opacity(0.3), radius: 0, x: 0, y: 2)
                                .padding(.leading, geometry.size.width * 0.005)
                            Spacer()
                        }
                        
                        HStack {
                            ZStack {
                                if isPasswordVisible {
                                    TextField("", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.black)
                                        .font(.system(size: geometry.size.height * 0.02, weight: .light, design: .default))
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, geometry.size.height * 0.016)
                                        .padding(.horizontal, geometry.size.width * 0.02)
                                        .background(Color(hex: 0xF5F5F5).opacity(0.9))
                                        .border(Color(hex: 0x504F51), width: geometry.size.width * 0.002)
                                        .cornerRadius(geometry.size.height * 0.01)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                                .stroke(Color(hex: 0x504F51), lineWidth: geometry.size.width * 0.002)
                                        )
                                        .frame(width: geometry.size.width * 0.7)
                                        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
                                        .padding(.top, geometry.size.height * -0.01)
                                } else {
                                    SecureField("", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.black)
                                        .font(.system(size: geometry.size.height * 0.02, weight: .light, design: .default))
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, geometry.size.height * 0.016)
                                        .padding(.horizontal, geometry.size.width * 0.02)
                                        .background(Color(hex: 0xF5F5F5).opacity(0.9))
                                        .border(Color(hex: 0x504F51), width: geometry.size.width * 0.002)
                                        .cornerRadius(geometry.size.height * 0.01)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                                .stroke(Color(hex: 0x504F51), lineWidth: geometry.size.width * 0.002)
                                        )
                                        .frame(width: geometry.size.width * 0.7)
                                        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
                                        .padding(.top, geometry.size.height * -0.01)
                                }
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width * 0.016)
                                            .frame(height: geometry.size.height * 0.016)
                                            .foregroundColor(Color(hex: 0x828B8E))
                                    }
                                    .padding(.trailing, geometry.size.width * 0.03)
                                    .padding(.bottom, geometry.size.height * 0.01)
                                }
                                .frame(width: geometry.size.width * 0.7)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                .padding(.top, geometry.size.height * 0.02)
                
                HStack {
                    Button(action: {
                        self.authenticateUser()
                    }) {
                        HStack {
                            Text("Login")
                                .font(.system(size: geometry.size.height * 0.018, weight: .bold))
                                .foregroundColor(Color.white)
                                .padding(.leading, geometry.size.width * 0.02)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.forward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: geometry.size.height * 0.016)
                                .foregroundColor(Color.white)
                                .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                                .padding(.trailing, geometry.size.width * 0.02)
                        }
                    }
                    .frame(width: geometry.size.width * 0.5)
                    .padding(.vertical, geometry.size.height * 0.018)
                    .background(Color(hex: 0xDA64ED))
                    .cornerRadius(geometry.size.height * 0.01)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                .padding(.top, geometry.size.height * 0.04)
                .padding(.bottom, geometry.size.height * 0.01)
                
                
                
                Spacer()
            }
            .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 1.0)
            .background(gradient)
            .onAppear {
                self.authenticatedUsername = ""
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    private func authenticateUser() {
        let requestBody: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        guard let url = URL(string: "http://172.20.10.2:5000/user-authentication") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.isLoginSuccessful = false
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.isLoginSuccessful = false
                return
            }

            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                saveTokenToKeychain(token: loginResponse.token)
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = true
                    self.authenticatedUsername = loginResponse.userid
                    self.authenticatedOrgID = loginResponse.orgid
                    self.currentView = .StaticSim
                }
            } catch {
                self.isLoginSuccessful = false
                self.errorMessage = "That username or password is incorrect."
            }
        }.resume()
    }
}
