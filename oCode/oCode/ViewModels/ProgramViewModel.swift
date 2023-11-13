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
    case oldEmpty(oldResult: String)
    case loading
    case error(description: String)
    case data(output: String)
}

final class ProgramViewModel {
    @Published var name: String
    @Published var code: String
    @Published var target: TargetLanguage
    @Published var input: String?
    @Published var output: OutputState
    private let compilerApi: MoyaProvider<Compiler>
    
    init(
        compilerApi: MoyaProvider<Compiler>,
        name: String,
        code: String,
        target: TargetLanguage,
        input: String? = nil,
        output: OutputState = .empty
    ) {
        self.compilerApi = compilerApi
        self.name = name
        self.code = code
        self.target = target
        self.input = input
        self.output = output
    }
    
    init(compilerApi: MoyaProvider<Compiler>) {
        self.compilerApi = compilerApi
        name = "Program \(Int.random(in: 1...1000))"
        code = "print(int(input()))"
        target = .init(compilerName: "py", fullName: "Python")
        input = nil
        output = .empty
    }
    
    func update(
        name: String? = nil,
        code: String? = nil,
        target: TargetLanguage? = nil,
        input: String? = nil,
        output: OutputState = .empty
    ) {
        self.name = name ?? self.name
        self.code = code ?? self.code
        self.target = target ?? self.target
        self.input = input ?? self.input
        self.output = switch output {
        case .empty: self.output
        default: output
        }
    }
    
    func setDefault() {
        name = "Program \(Int.random(in: 1...1000))"
        code = "print(int(input()))"
        target = .init(compilerName: "py", fullName: "Python")
        input = nil
        output = .empty
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
