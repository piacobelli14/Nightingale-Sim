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
                
            }
            .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 1.0)
            .background(gradient)
        }
    }
}
