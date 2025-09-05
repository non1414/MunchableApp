////
////  Onboarding.swift
////  MUNCHABLE
////
////  Created by نوف بخيت الغامدي on 24/03/1445 AH.
import SwiftUI

// MARK: - Model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let titleKey: String
    let descriptionKey: String
}

// MARK: - Data
let onboardingData: [OnboardingPage] = [
    .init(
        imageName: "ai_icon",
        titleKey: "Latest Technologies",
        descriptionKey: "Use Make it to explore inspiring recipes to add a little fun to your dinner table by using AI."
    ),
    .init(
        imageName: "recipe_icon",
        titleKey: "Get Inspired!",
        descriptionKey: "Don’t know what to eat? we’ll suggest things to cook with the ingredients you have."
    )
]

// MARK: - View

struct Onboarding: View {
    @State private var currentPage = 0
    var onFinish: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Spacer()
                Button(action: { withAnimation { onFinish() } }) {
                    Text(NSLocalizedString("Skip", comment: "Onboarding skip"))
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("green"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingData.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(page.imageName)
                            .resizable()
                            .renderingMode(.original)   // بدون تينت
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                        
                        // العنوان
                        Text(NSLocalizedString(page.titleKey, comment: "Onboarding title"))
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // الوصف
                        Text(NSLocalizedString(page.descriptionKey, comment: "Onboarding description"))
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(width: 335)
                            .padding(.top, 4)
                        
                        Spacer()
                        
                        // نقاط التقدّم
                        HStack(spacing: 8) {
                            ForEach(0..<onboardingData.count, id: \.self) { dot in
                                Circle()
                                    .fill(dot == currentPage ? Color("green") : Color.gray.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, index == onboardingData.count - 1 ? 12 : 40)
                        
                        if index == onboardingData.count - 1 {
                            Button(action: { withAnimation { onFinish() } }) {
                                Text(NSLocalizedString("Start", comment: "Onboarding start"))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 281, height: 41)
                                    .background(Color("green"))
                                    .cornerRadius(10)
                            }
                            .padding(.top, 12)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            Spacer(minLength: 12)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
