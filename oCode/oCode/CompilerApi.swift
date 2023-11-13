//
//  CompilerApi.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation
import Moya

struct TargetLanguage {
    let compilerName: String
    let fullName: String
}

enum Compiler {
    case getSupportedTargets
    case runCode(code: String, target: String, input: String)
}

extension Compiler: TargetType {
    var baseURL: URL { URL(string: "https://api.codex.jaagrav.in")! }
    
    var path: String {
        switch self {
        case .getSupportedTargets: "list"
        case .runCode: ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSupportedTargets: .get
        case .runCode: .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getSupportedTargets: .requestPlain
        case let .runCode(code, target, input): .requestParameters(
            parameters: [
                "code": code,
                "language": target,
                "input": input
            ], 
            encoding: JSONEncoding.default
        )
        }
    }
    
    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }
}
