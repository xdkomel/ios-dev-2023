//
//  ContactModel.swift
//  homework4
//
//  Created by Kamil Foatov on 07.10.2023.
//

import Foundation
import UIKit

struct ContactModel: Hashable {
    static func == (lhs: ContactModel, rhs: ContactModel) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    let name: String
    let picture: ContactPicture
}

enum ContactPicture {
    case photo(image: UIImage)
    case solid(background: UIColor)
}
