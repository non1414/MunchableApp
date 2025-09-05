import SwiftUI

struct RecipeStep: Identifiable {
    let id: Int
    let ingredients: [String]
    let directions: [String]
}

struct RecipeFromAi: View {
    var recipeText: String
    var title: String
    
    // ارتفاع الهيدر
    private let headerHeight: CGFloat = UIScreen.main.bounds.height * 0.35
    
    @State private var currentStep: Int = 1
    @State private var startingOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    @State private var endOffset: CGFloat = 0
    @StateObject private var apiService = APIService()
    @State private var selectedImageUrl: String?
    var selectedIngredients: [String]
    
    // ألوان الستايل
    private let green      = Color("green")
    private let titleColor = Self.color("#474747")
    private let bodyGray   = Self.color("#666666")
    private let stepFill   = Self.color("#D9D9D9").opacity(0.5)
    
    private var steps: [RecipeStep] { parseRecipe(recipeText) }
    private var isArabic: Bool { Locale.preferredLanguages.first?.hasPrefix("ar") == true }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection()
                    Spacer()
                }
                
                bottomSheetView()
                    .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                startingOffset = headerHeight - 24
                apiService.fetchRecipeImages()
            }
            .onReceive(apiService.$recipeImages) { images in
                if selectedImageUrl == nil, let randomImage = images.randomElement() {
                    selectedImageUrl = randomImage.image_url
                }
            }
        }
    }
    
    // MARK: - Header
    @ViewBuilder
    private func headerSection() -> some View {
        recipeHeaderImage()
    }
    
    // MARK: - Bottom Sheet
    @ViewBuilder
    private func bottomSheetView() -> some View {
        VStack(spacing: 12) {
            Capsule()
                .frame(width: 50, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)
            
            ScrollView {
                contentSection()
                    .padding(.bottom, 8)
            }
            
            ctaButtons()
                .padding(.horizontal)
                .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -2)
        .offset(y: startingOffset + currentOffset + endOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.spring()) { currentOffset = value.translation.height }
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        if currentOffset < -150 { endOffset = -startingOffset }
                        else if endOffset != 0 && currentOffset > 150 { endOffset = 0 }
                        currentOffset = 0
                    }
                }
        )
    }
    
    // MARK: - المحتوى
    @ViewBuilder
    private func contentSection() -> some View {
        VStack(alignment: .center, spacing: 20) {
            Text(title)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(titleColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            stepSelector()
            
            if let step = steps.first(where: { $0.id == currentStep }) {
                stepDetails(step: step)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - مؤشّر المراحل
    @ViewBuilder
    private func stepSelector() -> some View {
        HStack(spacing: 10) {
            ForEach(steps) { step in
                Button(action: { currentStep = step.id }) {
                    ZStack {
                        Circle()
                            .fill(step.id == currentStep ? Color.white : stepFill)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle().stroke(step.id == currentStep ? green : Color.black.opacity(0.5), lineWidth: 1)
                            )
                        Text("\(step.id)")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(step.id == currentStep ? green : titleColor.opacity(0.5))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    // MARK: - تفاصيل الخطوة
    @ViewBuilder
    private func stepDetails(step: RecipeStep) -> some View {
        VStack(alignment: .trailing, spacing: 14) {
            Text(NSLocalizedString("Ingredients", comment: "ingredients title"))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(titleColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            if step.ingredients.isEmpty {
                Text(NSLocalizedString("No ingredients found", comment: "empty ingredients"))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(step.ingredients, id: \.self) { ingredient in
                        if isArabic {
                            HStack(spacing: 8) {
                                Text(ingredient)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(titleColor)
                                    .multilineTextAlignment(.trailing)
                                Circle().fill(green).frame(width: 6, height: 6)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Circle().fill(green).frame(width: 6, height: 6)
                                Text(ingredient)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(titleColor)
                            }
                        }
                    }
                }
            }
            
            Text(NSLocalizedString("Directions", comment: "directions title"))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(titleColor)
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .trailing, spacing: 12) {
                ForEach(step.directions, id: \.self) { direction in
                    if isArabic {
                        HStack(alignment: .top, spacing: 8) {
                            Text(direction)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(bodyGray)
                                .multilineTextAlignment(.trailing)
                            Circle().fill(green).frame(width: 6, height: 6)
                        }
                    } else {
                        HStack(alignment: .top, spacing: 8) {
                            Circle().fill(green).frame(width: 6, height: 6)
                            Text(direction)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(bodyGray)
                        }
                    }
                }
            }
        }
    }
    
    // MARK:
    @ViewBuilder
    private func ctaButtons() -> some View {
        if currentStep == 1 {
            HStack(spacing: 12) {
                Button {
                    // تغيير الوصفة
                } label: {
                    Text(NSLocalizedString("Change recipe", comment: "change recipe"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(titleColor)                 // #474747
                        .frame(width: 135, height: 41)               // W:135 H:41
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(titleColor.opacity(0.4), lineWidth: 1))
                }
                
                Button {
                    currentStep += 1
                } label: {
                    Text(NSLocalizedString("Next", comment: "next step"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 135, height: 41)
                        .background(RoundedRectangle(cornerRadius: 10).fill(green))
                }
            }
            
        } else if currentStep < steps.count {
            HStack(spacing: 12) {
                Button {
                    currentStep -= 1
                } label: {
                    Text(NSLocalizedString("Previous", comment: "previous step"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(titleColor)
                        .frame(width: 135, height: 41)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(titleColor.opacity(0.4), lineWidth: 1))
                }
                
                Button {
                    currentStep += 1
                } label: {
                    Text(NSLocalizedString("Next", comment: "next step"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 135, height: 41)
                        .background(RoundedRectangle(cornerRadius: 10).fill(green))
                }
            }
            
        } else {
            HStack {
                Spacer(minLength: 0)
                NavigationLink {
                    Make_it_()
                } label: {
                    Text(NSLocalizedString("Done", comment: "done"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 281, height: 41)
                        .background(RoundedRectangle(cornerRadius: 10).fill(green))
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    // MARK: - صورة الهيدر
    @ViewBuilder
    private func recipeHeaderImage() -> some View {
        if let imageUrl = selectedImageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: headerHeight)
                    .clipped()
            } placeholder: {
                ProgressView().frame(height: headerHeight)
            }
        } else {
            Color.gray.frame(height: headerHeight)
        }
    }
    
    // MARK: - Parsing
    private func parseRecipe(_ text: String) -> [RecipeStep] {
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var steps: [RecipeStep] = []
        var stepId = 1
        for line in lines {
            if line.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                let direction = line
                let ingredientsInStep = extractIngredients(from: direction)
                steps.append(RecipeStep(id: stepId, ingredients: ingredientsInStep, directions: [direction]))
                stepId += 1
            }
        }
        return steps
    }
    
    private func extractIngredients(from text: String) -> [String] {
        let prefixes = ["ال", "وال", "أو ال", "أو", "و", "بال", "ب"]
        var matched: [String] = []
        for ingredient in selectedIngredients {
            let patterns = prefixes.map { "\\b\($0)?\(NSRegularExpression.escapedPattern(for: ingredient))\\b" }
            for pattern in patterns {
                if text.range(of: pattern, options: .regularExpression) != nil {
                    matched.append(ingredient)
                    break
                }
            }
        }
        return matched
    }
    
    private static func color(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var i: UInt64 = 0
        Scanner(string: s).scanHexInt64(&i)
        let a, r, g, b: UInt64
        switch s.count {
        case 3:  (a, r, g, b) = (255, (i >> 8) * 17, (i >> 4 & 0xF) * 17, (i & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, i >> 16, i >> 8 & 0xFF, i & 0xFF)
        case 8:  (a, r, g, b) = (i >> 24, i >> 16 & 0xFF, i >> 8 & 0xFF, i & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
