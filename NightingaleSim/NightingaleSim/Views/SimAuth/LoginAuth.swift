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
                        .font(.system(size: geometry.size.height * 0.025, weight: .semibold))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.06)
                .padding(.vertical, 0)
                
                HStack {
                    Text("Nightingale Sim")
                        .font(.system(size: geometry.size.height * 0.06, weight: .bold))
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
                                .padding(.leading, geometry.size.width * 0.008)
                                .padding(.bottom, geometry.size.height * 0.01)
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
                                .cornerRadius(geometry.size.height * 0.01)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                        .stroke(Color.black.opacity(0.4), lineWidth: geometry.size.width * 0.008)
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
                                .font(.system(size: geometry.size.height * 0.014, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.7)
                                .padding(.leading, geometry.size.width * 0.005)
                            
                            Text("Click here to reset.")
                                .font(.system(size: geometry.size.height * 0.014, weight: .bold))
                                .foregroundColor(Color(hex: 0xE44DD5))
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
                                .padding(.leading, geometry.size.width * 0.008)
                                .padding(.bottom, geometry.size.height * 0.01)
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
                                        .cornerRadius(geometry.size.height * 0.01)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                                .stroke(Color.black.opacity(0.4), lineWidth: geometry.size.width * 0.008)
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
                                        .cornerRadius(geometry.size.height * 0.01)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                                .stroke(Color.black.opacity(0.4), lineWidth: geometry.size.width * 0.008)
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
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: geometry.size.height * 0.018)
                                            .foregroundColor(Color(hex: 0x828B8E))
                                            .padding(.bottom, geometry.size.height * 0.008)
                                    }
                                    .padding(.trailing, geometry.size.width * 0.03)
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
                    .padding(.horizontal,  geometry.size.width * 0.01)
                    .background(Color(hex: 0xE44DD5))
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
                if let token = loadTokenFromKeychain() {
                    if let decodedToken = decodeJWT(token: token) {
                        self.authenticatedUsername = decodedToken.userid
                        self.authenticatedOrgID = decodedToken.orgid
                        self.currentView = .StaticSim
                    }
                } else {
                    self.authenticatedUsername = ""
                }
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
        
        guard let url = URL(string: "https://www.nightingale-health.org/vektor/vektor-web-api/user-authentication") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.isLoginSuccessful = false
                self.errorMessage = "An error occurred. Please try again."
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.isLoginSuccessful = false
                self.errorMessage = "That username or password is incorrect."
                return
            }

            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                saveTokenToKeychain(token: loginResponse.token)

                if let decodedToken = decodeJWT(token: loginResponse.token) {
                    DispatchQueue.main.async {
                        self.isLoginSuccessful = true
                        self.authenticatedUsername = decodedToken.userid
                        self.authenticatedOrgID = decodedToken.orgid
                        self.currentView = .StaticSim
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoginSuccessful = false
                        self.errorMessage = "Failed to decode token."
                    }
                }
            } catch {
                self.isLoginSuccessful = false
                self.errorMessage = "That username or password is incorrect."
            }
        }.resume()
    }
    private func decodeJWT(token: String) -> (userid: String, orgid: String)? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else {
            return nil
        }

        let payload = parts[1]
        var base64String = String(payload)
        while base64String.count % 4 != 0 {
            base64String.append("=")
        }

        guard let decodedData = Data(base64Encoded: base64String) else {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: decodedData, options: []),
              let dict = json as? [String: Any],
              let userid = dict["userid"] as? String,
              let orgid = dict["orgid"] as? String else {
            return nil
        }

        return (userid, orgid)
    }
}





