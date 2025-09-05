//
//MUNCHABLEApp
//Created by نوف بخيت الغامدي on 05/01/1447 AH.
//
//
//
//

import SwiftUI

struct CategoryItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconName: String
    let categoryId: Int
}

struct CategorysPage: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var api: APIService
    @EnvironmentObject var store: IngredientsStore
    @State private var searchText: String = ""
    
    private let categories: [CategoryItem] = [
        .init(title: "Vegetables", iconName: "ic_vegetables", categoryId: 1),
        .init(title: "Fruits",     iconName: "ic_fruits",     categoryId: 2),
        .init(title: "Meats",      iconName: "ic_meats",      categoryId: 3),
        .init(title: "Dairy",      iconName: "ic_dairy",      categoryId: 4),
        .init(title: "Spices",     iconName: "ic_spices",     categoryId: 5),
        .init(title: "Sea food",   iconName: "ic_seafood",    categoryId: 6)
    ]
    
    private var gridCols: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    searchField
                    
                    Text(NSLocalizedString("choose_ingredient_title", comment: ""))
                        .font(.system(size: 26, weight: .regular))
                        .foregroundStyle(Color(hex: "#474747"))
                        .multilineTextAlignment(layoutDirection == .rightToLeft ? .trailing : .leading)
                    
                    LazyVGrid(columns: gridCols, spacing: 18) {
                        ForEach(filtered(categories)) { item in
                            NavigationLink {
                                IngredientsScreen(
                                    categoryId: resolvedId(for: item),
                                    categoryTitle: apiName(for: item)
                                )
                            } label: {
                                CategoryCard(item: CategoryItem(
                                    title: apiName(for: item),
                                    iconName: item.iconName,
                                    categoryId: item.categoryId
                                ))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { nextBar }
        .navigationBarHidden(true)
    }
    
    private var topBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 2) {
                        Image(systemName: layoutDirection == .rightToLeft ? "chevron.right" : "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 27)     // W:25 H:27
                            .foregroundColor(.black)
                        Text(NSLocalizedString("Back", comment: ""))
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .baselineOffset(1)
                    }
                }
                Spacer()
            }
            
            Text(NSLocalizedString("step_title", comment: ""))
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(Color(hex: "#474747"))
        }
        .padding(.top, 14)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
    
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
               
                .foregroundStyle(Color(hex: "#474747").opacity(0.55))
            TextField(NSLocalizedString("search_placeholder", comment: ""), text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(.system(size: 16))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#EEEEEEED"))
                .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }
    
    private var nextBar: some View {
        HStack {
            Spacer()
            NavigationLink {
                IngredientsPage(selectedIngredients: $store.selected)
            } label: {
                Text(NSLocalizedString("next_button", comment: "Next"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 281, height: 41)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#53B674"))
                    )
            }
            .disabled(store.selected.isEmpty)
            .opacity(store.selected.isEmpty ? 0.7 : 1.0)
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }
    
    private func filtered(_ items: [CategoryItem]) -> [CategoryItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { apiName(for: $0).localizedCaseInsensitiveContains(q) }
    }
    
    private func matchAPICategory(for item: CategoryItem) -> IngredientCategory? {
        let norm = normalize(item.title)
        return api.categories.first(where: { c in
            normalize(c.name_en) == norm ||
            normalize(c.name_ar) == norm ||
            normalize(c.slug)    == norm
        })
    }
    
    private func resolvedId(for item: CategoryItem) -> Int {
        matchAPICategory(for: item)?.id ?? item.categoryId
    }
    
    private func apiName(for item: CategoryItem) -> String {
        matchAPICategory(for: item)?.localizedName ?? item.title
    }
    
    private func normalize(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}

// بطاقة الفئة
fileprivate struct CategoryCard: View {
    let item: CategoryItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
                )
                .frame(height: 75)
            
            VStack(spacing: 10) {
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                
                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#474747"))
                    .shadow(color: .black.opacity(0.10), radius: 1, x: 0, y: 1)
            }
            .padding(.vertical, 8)
        }
    }
}

// Color helper
fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 8: (a,r,g,b) = (int>>24, (int>>16)&0xff, (int>>8)&0xff, int&0xff)
        case 6: (a,r,g,b) = (255, int>>16, (int>>8)&0xff, int&0xff)
        default:(a,r,g,b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}
