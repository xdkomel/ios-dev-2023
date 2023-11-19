//
//  ProgramModel.swift
//  oCode
//
//  Created by Kamil Foatov on 18.11.2023.
//

import Foundation
import Moya
import Combine

struct ProgramData: Hashable {
    var id: Int
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
    @Published var programData: ProgramData?
    private let compilerApi: MoyaProvider<Compiler>
    private let storage: Storage
    
    init(programData: ProgramData? = nil, compilerApi: MoyaProvider<Compiler>, storage: Storage) {
        self.programData = programData
        self.compilerApi = compilerApi
        self.storage = storage
    }
    
    func loadProgram(withId id: Int) {
        if let program = storage.findProgram(withId: id) {
            self.programData = program
            return
        }
        print("couldn't load a program with this id")
    }
    
    func runCode() {
        guard let program = programData else {
            print("not found a program to run")
            return
        }
        // update UI
        programData?.output = .loading
        
        // request
        compilerApi.request(
            .runCode(
                code: program.code,
                target: program.target.compilerName,
                input: program.input ?? "0"
            )
        ) { [weak self] result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 200: do {
                    let output = try JSONDecoder().decode(ProgramOutput.self, from: response.data)
                    self?.updateOutput(
                        .data(output: output.output)
                    )
                } catch {
                    self?.updateOutput(
                        .error(description: "The app is outdated for the following backend")
                    )
                }
                default: 
                    self?.updateOutput(
                        .error(description: "Request error, recieved code \(response.statusCode)")
                    )
                    do {
                        print(try response.mapJSON())
                    } catch {
                        print()
                    }
                }
            case .failure:
                self?.updateOutput(
                    .error(description: "No internet connection")
                )
            }
        }
    }
    
    func updateOutput(_ newOutput: OutputState) {
        programData?.output = newOutput
    }
    
    func save() {
        guard let program = programData else {
            return
        }
        storage.save(program)
    }
}
