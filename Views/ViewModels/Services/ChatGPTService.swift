import Foundation

class ChatGPTService {
    
    private let apiKey = ""  // اضيفي المفتاح بعد ماتنزلي البروجكت من القيت هب 
    
    func generateRecipe(from ingredients: [String], completion: @escaping (_ title: String?, _ recipe: String?) -> Void) {
        let prompt = """
        أنشئ وصفة طبخ باستخدام هذه المكونات: \(ingredients.joined(separator: ", ")). 
        ابدأ بعنوان مناسب للوصفة في سطر مستقل، ثم بعد ذلك قدم خطوات التحضير بشكل واضح ومرقم.
        مثال:
        العنوان: كبسة الدجاج بالخضار
        1. اغسل الدجاج جيدًا...
        """
        
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                let lines = content.components(separatedBy: "\n")
                let titleLine = lines.first { $0.contains("العنوان:") } ?? ""
                let title = titleLine.replacingOccurrences(of: "العنوان:", with: "").trimmingCharacters(in: .whitespaces)
                let recipe = content.replacingOccurrences(of: titleLine, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                // ✅ تسجيل KPI عند النجاح
                KPILogger.logKPI(
                    category: "User Engagement",
                    metric: "Recipe Generated",
                    target: "1 per request",
                    actual: "1",
                    notes: "Recipe created for: \(ingredients.joined(separator: ", "))"
                )
                
                DispatchQueue.main.async {
                    completion(title.isEmpty ? nil : title, recipe)
                }
            } else {
                print("❌ Failed to get response: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
        }.resume()
    }
}
