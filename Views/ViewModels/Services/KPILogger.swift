//
//  KPILogger.swift
//  MUNCHABLE
//
//  Created by نوف بخيت الغامدي on 14/01/1447 AH.
//

import Foundation

struct KPILogger {
    static func logKPI(
        category: String,
        metric: String,
        target: String,
        actual: String,
        notes: String
    ) {
        guard let url = URL(string: "https://script.google.com/macros/s/AKfycbxBQ961IadMtpY8IEaP3acDBwBIEH3zjSwq-3PCA7tTgTnrHUf70JJ74irXi966gVd1Mg/exec") else {
            print("❌ Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "category": category,
            "metric": metric,
            "target": target,
            "actual": actual,
            "notes": notes
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error sending KPI: \(error.localizedDescription)")
            } else {
                print("✅ KPI sent successfully")
            }
        }.resume()
    }
}

