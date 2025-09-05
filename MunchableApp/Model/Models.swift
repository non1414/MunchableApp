//
//  Models.swift
//  MUNCHABLE
//
//  Created by نوف بخيت الغامدي on 21/12/1446 AH.
//
import Foundation

struct IngredientItem: Identifiable, Decodable {
    let id: Int
    let name_ar: String
    let name_en: String
    
    var name: String {
        return name_ar
    }
}

struct RecipeImage: Codable, Identifiable {
    let id: Int
    let title_ar: String
    let title_en: String
    let category_id: Int
    var image_url: String
}


struct IngredientCategory: Identifiable, Decodable {
    let id: Int
    let name_ar: String
    let name_en: String
    let description_ar: String
    let description_en: String
    let slug: String
    var ingredients: [IngredientItem]? = nil
    
    var name: String {
        return name_ar
    }
}
