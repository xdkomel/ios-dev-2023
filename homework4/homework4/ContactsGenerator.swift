//
//  ContactsGenerator.swift
//  homework4
//
//  Created by Kamil Foatov on 07.10.2023.
//

import Foundation
import UIKit

struct ContactsGenerator {
    private let images: [UIImage]
    private let colors: [UIColor] = [.red, .blue, .cyan, .green, .gray, .magenta, .orange]
    private let solidColorProbability: Double
    
    init(solidColorProbability: Double = 0.0) {
        images = [
            UIImage(named: "duck"),
            UIImage(named: "kamil")
        ].filter { $0 != nil }.map { $0! }
        self.solidColorProbability = solidColorProbability
    }
    
    func generate(for names: [String]) -> [ContactModel] {
        return names.map(generateContact)
    }
    
    private func generateContact(_ name: String) -> ContactModel {
        let randomNumber = Double.random(in: 0...1)
        if images.isEmpty || randomNumber <= solidColorProbability {
            return .init(
                name: name,
                picture: .solid(background: colors.randomElement()!)
            )
        }
        return .init(
            name: name,
            picture: .photo(image: images.randomElement()!)
        )
    }
}
