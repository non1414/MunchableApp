//
//  Helpers.swift .swift
//  MUNCHABLE
//
//  Created by نوف بخيت الغامدي on 05/02/1447 AH.
//

import SwiftUI

// MARK: - WrapView (لعرض العناصر بشكل مرن ومتنقل)
struct WrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var items: Data
    var content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.self) { item in
                self.content(item)
                    .padding(5)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if item == self.items.last {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in height })
            }
        }
        .background(GeometryReader {
            Color.clear.preference(key: ViewHeightKey.self, value: $0.size.height)
        })
        .onPreferenceChange(ViewHeightKey.self) { totalHeight = $0 }
    }
}

// MARK: - ViewHeightKey (لمعرفة ارتفاع المحتوى داخل WrapView)
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Color Extension (تفسير اللون من Hex)
//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//
//        let r = Double((rgb >> 16) & 0xFF) / 255
//        let g = Double((rgb >> 8) & 0xFF) / 255
//        let b = Double(rgb & 0xFF) / 255
//
//        self.init(red: r, green: g, blue: b)
//    }
//}
