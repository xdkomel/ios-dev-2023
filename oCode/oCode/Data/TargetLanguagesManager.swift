//
//  TargetLanguagesManager.swift
//  oCode
//
//  Created by Kamil Foatov on 20.11.2023.
//

import Foundation
import Moya

class TargetLanguagesManager {
    @Published var supportedLanguages: [TargetLanguage] = [
        .init(compilerName: "py", fullName: "Python")
    ]
    var lastUpdate: Date?
    let api: MoyaProvider<Compiler>
    
    init(api: MoyaProvider<Compiler>) {
        self.api = api
    }
    
    func loadLanguages() {
        if lastUpdate != nil && -lastUpdate!.timeIntervalSinceNow < 5*60  {
            // do not update when 5 minutes haven't passed
            return
        }
        api.request(.getSupportedTargets) { [weak self] result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 200: print(response)
                default: print(response)
                }
            case let .failure(error):
                print(error)
            }
            self?.supportedLanguages = [
                .init(compilerName: "py", fullName: "Python"),
                .init(compilerName: "gcc", fullName: "C++"),
                .init(compilerName: "java", fullName: "Java")
            ]
        }
        lastUpdate = .now
    }
}
