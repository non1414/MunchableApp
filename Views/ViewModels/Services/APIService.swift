//
//  APIService.swift
//  MUNCHABLE
//
//  Created by نوف بخيت الغامدي on 21/12/1446 AH.

import Foundation
import Combine

class APIService: ObservableObject {
    @Published var token: String = ""
    @Published var categories: [IngredientCategory] = []
    @Published var recipeImages: [RecipeImage] = []

    func login() {
        guard let url = URL(string: "https://api.munchable-sa.com/token") else {
            print("❌ Invalid login URL")
            self.fetchRecipeImages()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "grant_type=password&username=admin&password=%3C7nVO7y-5dZ2"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Login request error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data in login response")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔵 Server response: \(responseString)")
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = jsonObject["access_token"] as? String {
                    DispatchQueue.main.async {
                        self.token = token
                        self.fetchCategories()
                    }
                } else {
                    print("❌ Token not found in response")
                }
            } catch {
                print("❌ Failed to parse login response: \(error)")
            }
        }.resume()
    }
    
    func fetchCategories() {
        guard let url = URL(string: "https://api.munchable-sa.com/api/ingredient-categories") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Categories error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedCategories = try JSONDecoder().decode([IngredientCategory].self, from: data)
                
                DispatchQueue.main.async {
                    self.categories = decodedCategories
                }
                
                for category in decodedCategories {
                    self.fetchIngredients(forCategoryId: category.id) { ingredients in
                        DispatchQueue.main.async {
                            if let index = self.categories.firstIndex(where: { $0.id == category.id }) {
                                self.categories[index].ingredients = ingredients
                            }
                        }
                    }
                }
            } catch {
                print("❌ Decoding categories failed: \(error)")
            }
        }.resume()
    }
    
    func fetchRecipeImages() {
        guard let url = URL(string: "https://api.munchable-sa.com/api/images/category/1") else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch images: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                // فك التشفير من JSON إلى مصفوفة RecipeImage
                var decodedImages = try JSONDecoder().decode([RecipeImage].self, from: data)

                // إضافة base URL لكل صورة
                let baseURL = "https://api.munchable-sa.com"
                for i in 0..<decodedImages.count {
                    if !decodedImages[i].image_url.hasPrefix("http") {
                        decodedImages[i].image_url = baseURL + decodedImages[i].image_url
                    }
                }

                // حفظها في القائمة المنشورة
                DispatchQueue.main.async {
                    self.recipeImages = decodedImages
                }

            } catch {
                print("❌ JSON decoding failed: \(error)")
            }
        }.resume()
    }



    func fetchIngredients(forCategoryId id: Int, completion: @escaping ([IngredientItem]) -> Void) {
        guard let url = URL(string: "https://api.munchable-sa.com/api/ingredients/by-category/\(id)") else {
            print("❌ Invalid ingredients URL")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Error loading ingredients for category \(id)")
                completion([])
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([IngredientItem].self, from: data)
                completion(decoded)
            } catch {
                print("❌ Decoding failed for ingredients: \(error)")
                completion([])
            }
        }.resume()
    }
}
