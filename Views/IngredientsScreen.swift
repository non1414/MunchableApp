//
//MUNCHABLEApp
//Created by نوف بخيت الغامدي on 05/01/1447 AH.
//
//
//

import SwiftUI

struct IngredientsScreen: View {
    let categoryId: Int
    let categoryTitle: String
    
    @EnvironmentObject var api: APIService
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: IngredientsStore
    
    @State private var items: [IngredientItem] = []
    @State private var isLoading = false
    @State private var errorText: String?
    @State private var search: String = ""
    @State private var selectedIDs = Set<Int>()
    
    private let cols: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    searchField
                    
                    Text("Choose your \(categoryTitle)!")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundStyle(Color(hex: "#474747"))
                    
                    if isLoading {
                        ProgressView().controlSize(.large).padding(.top, 20)
                    } else if let err = errorText {
                        Text(err).foregroundStyle(.red).padding(.top, 8)
                    } else if filteredItems.isEmpty {
                        Text("No ingredients yet")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    } else {
                        LazyVGrid(columns: cols, spacing: 16) {
                            ForEach(filteredItems, id: \.id) { ing in
                                IngredientChip(
                                    title: ing.localizedName,
                                    isSelected: selectedIDs.contains(ing.id)
                                )
                                .onTapGesture { toggle(ing.id) }
                            }
                        }
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) { addButton }
        .navigationBarHidden(true)
        .task { load() }
    }
    
    // MARK: - Header & Search
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                        Text("Back").font(.system(size: 17))
                    }
                }
                .foregroundStyle(.black)
                Spacer()
            }
            
            Text("Select \(categoryTitle)")
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
            TextField("Search \(categoryTitle)", text: $search)
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
    
    private var addButton: some View {
        HStack {
            Spacer()
            Button {
                let picked = items
                    .filter { selectedIDs.contains($0.id) }
                    .map { $0.localizedName }
                
                store.add(names: picked)
                dismiss()
            } label: {
                Text(selectedIDs.isEmpty ? "Add" : "Add (\(selectedIDs.count))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 281, height: 41)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#53B674"))
                    )
            }
            .disabled(selectedIDs.isEmpty)
            .opacity(selectedIDs.isEmpty ? 0.7 : 1.0)
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }
    
    // MARK: - Data
    private var filteredItems: [IngredientItem] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { $0.localizedName.localizedCaseInsensitiveContains(q) }
    }
    
    private func toggle(_ id: Int) {
        if selectedIDs.contains(id) { selectedIDs.remove(id) }
        else { selectedIDs.insert(id) }
    }
    
    private func load() {
        isLoading = true
        errorText = nil
        api.fetchIngredients(forCategoryId: categoryId) { list in
            DispatchQueue.main.async {
                self.items = list
                self.isLoading = false
            }
        }
    }
}

// MARK: - Chip (بدون أيقونة)
fileprivate struct IngredientChip: View {
    let title: String
    let isSelected: Bool
    
    // ألوان من الموك
    private let borderGreen = Color(hex: "#53B674")
    private let bgSelected  = Color(hex: "#E9F6F1")          // أخضر فاتح عند التحديد
    private let textColor   = Color(hex: "#474747")
    private let idleBorder  = Color(hex: "#538674").opacity(0.15)
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 43) // العرض من الـGrid (قريب من 141×43)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? bgSelected : Color.white)
                .shadow(color: isSelected ? borderGreen.opacity(0.10) : Color.black.opacity(0.06),
                        radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? borderGreen : idleBorder,
                        lineWidth: isSelected ? 2 : 1)
        )
    }
}

// MARK: - Color helper
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
