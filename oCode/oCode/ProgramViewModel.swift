//
//  ProgramViewModel.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation
import Combine
import Moya

enum OutputState {
    case empty
    case loading
    case error(description: String)
    case data(output: String)
}

final class ProgramViewModel {
    @Published var name: String
    @Published var code: String
    @Published var target: TargetLanguage
    @Published var input: String?
    @Published private(set) var output: OutputState = .empty
    @Published private(set) var untouched = true
    private var bindings = Set<AnyCancellable>()
    private let compilerApi = MoyaProvider<Compiler>()
    
    init(
        name: String,
        code: String,
        target: TargetLanguage,
        input: String? = nil,
        untouched: Bool = true
    ) {
        self.name = name
        self.code = code
        self.target = target
        self.input = input
        self.untouched = untouched
    }
    
    func runCode() {
        // update UI
        output = .loading
        
        // request
        compilerApi.request(
            .runCode(
                code: code,
                target: target.compilerName,
                input: input ?? "0"
            )
        ) { [weak self] result in
            switch result {
            case let .success(response): 
                switch response.statusCode {
                case 200: do {
                    let output = try JSONDecoder().decode(ProgramOutput.self, from: response.data)
                    self?.output = .data(output: output.output)
                } catch {
                    self?.output = .error(description: "The app is outdated for the following backend")
                }
                default: self?.output = .error(description: "Request error, recieved code \(response.statusCode)")
                    do {
                        print(try response.mapJSON())
                    } catch {
                        print()
                    }
                }
            case .failure: self?.output = .error(description: "No internet connection")
            }
        }
    }
}
