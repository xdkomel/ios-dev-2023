//
//  SupportedLanguages.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation

struct SupportedLanguages: Decodable {
    let timeStamp: Int
    let status: Int
    let supportedLanguages: [LanguageInfo]
}

struct LanguageInfo: Decodable {
    let language: String
    let info: String
}
