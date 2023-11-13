//
//  ProgramOutput.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation

struct ProgramOutput: Decodable {
    let timeStamp: Int
    let status: Int
    let output: String
    let error: String
    let language: String
    let info: String
}
