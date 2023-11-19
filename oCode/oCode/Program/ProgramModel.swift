//
//  ProgramModel.swift
//  oCode
//
//  Created by Kamil Foatov on 18.11.2023.
//

import Foundation
import Moya

struct ProgramData: Hashable {
    var id: ObjectIdentifier
    var name: String
    var code: String
    var target: TargetLanguage
    var output: OutputState
    var input: String?
    
    static func == (lhs: ProgramData, rhs: ProgramData) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum OutputState {
    case empty
    case oldEmpty(oldResult: String)
    case loading
    case error(description: String)
    case data(output: String)
}

class ProgramModel {
    var programData: ProgramData?
    private let compilerApi: MoyaProvider<Compiler>
    private let storage: Storage
//    private let coordinator: Coordinator
    
    init(programData: ProgramData? = nil, compilerApi: MoyaProvider<Compiler>, storage: Storage) {
        self.programData = programData
        self.compilerApi = compilerApi
        self.storage = storage
    }
    
    func loadProgram(withId id: ObjectIdentifier) {
        if let program = storage.findProgram(withId: id) {
            self.programData = program
        }
        print("couldn't load a program with this id")
        // TODO couldn't load a program with this id, error state
    }
    
    func runCode() {
        guard var program = programData else {
            print("not found a program to run")
            return
        }
        // update UI
        program.output = .loading
        
        // request
        compilerApi.request(
            .runCode(
                code: program.code,
                target: program.target.compilerName,
                input: program.input ?? "0"
            )
        ) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 200: do {
                    let output = try JSONDecoder().decode(ProgramOutput.self, from: response.data)
                    self.programData?.output = .data(output: output.output)
                } catch {
                    self.programData?.output = .error(description: "The app is outdated for the following backend")
                }
                default: self.programData?.output = .error(description: "Request error, recieved code \(response.statusCode)")
                    do {
                        print(try response.mapJSON())
                    } catch {
                        print()
                    }
                }
            case .failure: self.programData?.output = .error(description: "No internet connection")
            }
        }
    }
    
    func updateOutput(_ newOutput: OutputState) {
        programData?.output = newOutput
    }
}
