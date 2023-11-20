//
//  TargetLanguagesManager.swift
//  oCode
//
//  Created by Kamil Foatov on 20.11.2023.
//

import Foundation
import Moya

class TargetLanguagesManager {
    @Published var supportedLanguages: [String] = [
        "py"
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
                case 200: 
                    do {
                        let result = try JSONDecoder().decode(SupportedLanguages.self, from: response.data)
                        self?.supportedLanguages = result.supportedLanguages.map {
                            $0.language
                        }
                        self?.lastUpdate = .now
                    } catch {
                        print("Error happened while decoding")
                    }
                    
                default: print(response)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}
