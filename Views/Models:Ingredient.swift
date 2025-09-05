//
//MUNCHABLEApp
//Created by نوف بخيت الغامدي on 05/01/1447 AH.
//



import Foundation

// MARK: - Helper: تحديد اللغة بشكل أدق
fileprivate var isArabicUI: Bool {
    if let appLang = Bundle.main.preferredLocalizations.first?.lowercased(),
       appLang.hasPrefix("ar") || appLang == "ar" { return true }
    if let appLang = Bundle.main.preferredLocalizations.first?.lowercased(),
       appLang.hasPrefix("en") || appLang == "en" { return false }
    
    if #available(iOS 16.0, *) {
        if let code = Locale.current.language.languageCode?.identifier.lowercased() {
            if code.hasPrefix("ar") { return true }
            if code.hasPrefix("en") { return false }
        }
    } else {
        if let code = Locale.current.languageCode?.lowercased() {
            if code.hasPrefix("ar") { return true }
            if code.hasPrefix("en") { return false }
        }
    }
    
    if let first = Locale.preferredLanguages.first?.lowercased() {
        if first.hasPrefix("ar") { return true }
        if first.hasPrefix("en") { return false }
    }
    
    // افتراضي
    return false
}

// MARK: - المكوّنات
extension IngredientItem {
    var localizedName: String {
        let ar = name_ar.trimmingCharacters(in: .whitespacesAndNewlines)
        let en = name_en.trimmingCharacters(in: .whitespacesAndNewlines)
        return isArabicUI ? (ar.isEmpty ? en : ar)
        : (en.isEmpty ? ar : en)
    }
    
    var displayName: String { localizedName }
}

// MARK: - الفئات
extension IngredientCategory {
    var localizedName: String {
        let ar = name_ar.trimmingCharacters(in: .whitespacesAndNewlines)
        let en = name_en.trimmingCharacters(in: .whitespacesAndNewlines)
        return isArabicUI ? (ar.isEmpty ? en : ar)
        : (en.isEmpty ? ar : en)
    }
    
    var displayName: String { localizedName }
}
