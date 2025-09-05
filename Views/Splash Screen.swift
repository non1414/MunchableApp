//////
//////  Splash Screen.swift
//////  MUNCHABLE
//////
///  Created by نوف بخيت الغامدي on 24/03/1445 AH.

import SwiftUI

struct Splash_Screen: View {
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            if showOnboarding {
                Onboarding()
            } else {
                ZStack {
                    Color("green")
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 5) {
                        Image("Logo Munchable")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 228, height: 169)
                            .clipped()
                        
                        Text("MUNCHABLE")
                            .font(
                                Font.custom("SF Pro Text", size: 36)
                                    .weight(.semibold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                    .zIndex(1)
                    
                    VStack {
                        Spacer()
                        Image("Group 1046")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 407, height: 249)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            showOnboarding = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Splash_Screen()
}
