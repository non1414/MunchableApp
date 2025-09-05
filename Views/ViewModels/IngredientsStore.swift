//
//  IngredientsStore.swift
//  MUNCHABLE
//
//  Created by نوف بخيت الغامدي on 12/03/1447 AH.
//

import Foundation
import Combine

final class IngredientsStore: ObservableObject {
    @Published var selected: [String] = []

    func add(names: [String]) {
        for n in names.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !n.isEmpty {
            if !selected.contains(n) { selected.append(n) }
        }
    }

    func remove(_ name: String) { selected.removeAll { $0 == name } }
    func clear() { selected.removeAll() }
}
