//
//MUNCHABLEApp
//Created by نوف بخيت الغامدي on 05/01/1447 AH.
//
import SwiftUI

struct IngredientsPage: View {
    @Binding var selectedIngredients: [String]
    @State private var isEditing: Bool = false
    @State private var navigateToLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header (Back + Edit/Done + Title)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Back
                    Button { dismiss() } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .frame(width: 25, height: 27)
                            Text(NSLocalizedString("Back", comment: ""))
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .baselineOffset(1)
                            
                        }
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Button { isEditing.toggle() } label: {
                        Text(isEditing
                             ? NSLocalizedString("done_button", comment: "")
                             : NSLocalizedString("edit_button", comment: ""))
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(isEditing
                                         ? Color(hex: "#3478F6")
                                         : Color("green"))
                    }
                }
                
                Text(NSLocalizedString("step_2_title", comment: "Step 2"))
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(Color(hex: "#474747"))
            }
            .padding(.top, 14)
            .padding(.horizontal, 20)
            .padding(.bottom, 6)
            
            // MARK: - Content
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(NSLocalizedString("your_ingredients_title", comment: "Your ingredients are"))
                        .font(.system(size: 26, weight: .regular))
                        .foregroundStyle(Color(hex: "#474747"))
                        .padding(.horizontal, 20)
                    
                    // List
                    List {
                        ForEach(selectedIngredients, id: \.self) { ingredient in
                            HStack {
                                Text(ingredient)
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundStyle(Color(hex: "#474747"))
                                Spacer()
                                if isEditing {
                                    Button(action: { deleteIngredient(ingredient) }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .listRowSeparator(.visible)
                        }
                    }
                    .listStyle(.plain)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button { navigateToLoading = true } label: {
                            Text(NSLocalizedString("make_it_button", comment: "Make it"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 281, height: 41)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#53B674"))
                                )
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color.white.ignoresSafeArea(edges: .bottom))
                    
                    NavigationLink(
                        destination: LoadingRecipesPage(selectedIngredients: selectedIngredients),
                        isActive: $navigateToLoading
                    ) { EmptyView() }
                        .hidden()
                }
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func deleteIngredient(_ ingredient: String) {
        selectedIngredients.removeAll { $0 == ingredient }
    }
}

// MARK: - Color hex helper
fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 8: (a,r,g,b) = (int>>24, (int>>16)&0xff, (int>>8)&0xff, int&0xff)
        case 6: (a,r,g,b) = (255, int>>16, (int>>8)&0xff, int&0xff)
        default: (a,r,g,b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}
