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
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var username: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Text("Welcome to")
                        .font(.system(size: geometry.size.height * 0.04, weight: .semibold))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.04)
                .padding(.vertical, 0)
                
                HStack {
                    Text("Nightingale Sim")
                        .font(.system(size: geometry.size.height * 0.07, weight: .bold))
                        .foregroundColor(Color.white)
                        .opacity(1.0)
                        .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 0)
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.04)
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
                                .padding(.vertical, geometry.size.height * 0.014)
                                .padding(.horizontal, geometry.size.width * 0.02)
                                .background(Color(hex: 0xF5F5F5).opacity(0.9))
                                .border(Color(hex: 0x504F51), width: geometry.size.width * 0.004)
                                .cornerRadius(geometry.size.height * 0.01)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                        .stroke(Color(hex: 0x504F51), lineWidth: geometry.size.width * 0.004)
                                )
                                .frame(width: geometry.size.width * 0.7)
                                .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
                                .padding(.top, geometry.size.height * -0.01)
                            
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.04)
                .padding(.top, geometry.size.height * 0.04)
                
                HStack {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Text("Forgot password?")
                                .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.9)
                                .padding(0)
                            
                            Text("Click here to reset.")
                                .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                .foregroundColor(Color(hex: 0xDA64ED))
                                .padding(0)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.04)
                
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
                            TextField("", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .font(.system(size: geometry.size.height * 0.02, weight: .light, design: .default))
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, geometry.size.height * 0.014)
                                .padding(.horizontal, geometry.size.width * 0.02)
                                .background(Color(hex: 0xF5F5F5).opacity(0.9))
                                .border(Color(hex: 0x504F51), width: geometry.size.width * 0.004)
                                .cornerRadius(geometry.size.height * 0.01)
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                        .stroke(Color(hex: 0x504F51), lineWidth: geometry.size.width * 0.004)
                                )
                                .frame(width: geometry.size.width * 0.7)
                                .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
                                .padding(.top, geometry.size.height * -0.01)
                            
                            Spacer()
                        }
                    }
                    
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.04)
                .padding(.top, geometry.size.height * 0.02)
                
                
                
                Spacer()
            }
            .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 1.0)
            .background(gradient)
        }
    }
}
