//
//  StaticSim.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI

struct StaticSim: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Image("nslogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height * 0.8)
                        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 2)
                    
                    Text("Nightinagle Sim")
                        .font(.system(size: geometry.size.height * 0.05, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
                }
                .frame(width: geometry.size.width * 1.0)
                
                
                
            }
            .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 1.0)
            .background(gradient)
        }
    }
}


extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}


