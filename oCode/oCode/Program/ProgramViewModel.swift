//
//  ProgramViewModel.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation
import Combine
import Moya
import UIKit
import HighlightSwift

//enum OutputState {
//    case empty
//    case oldEmpty(oldResult: String)
//    case loading
//    case error(description: String)
//    case data(output: String)
//}

final class ProgramViewModel {
    @Published var program: ProgramModel
    let coordinator: Coordinator
//    @Published var name: String
//    @Published var code: String
//    @Published var target: TargetLanguage
//    @Published var input: String?
//    @Published var output: OutputState
//    private let compilerApi: MoyaProvider<Compiler>
    
    init(
        program: ProgramModel,
        coordinator: Coordinator
//        compilerApi: MoyaProvider<Compiler>,
//        name: String,
//        code: String,
//        target: TargetLanguage,
//        input: String? = nil,
//        output: OutputState = .empty
    ) {
        self.program = program
        self.coordinator = coordinator
//        self.compilerApi = compilerApi
//        self.name = name
//        self.code = code
//        self.target = target
//        self.input = input
//        self.output = output
    }
    
//    init(compilerApi: MoyaProvider<Compiler>) {
//        self.compilerApi = compilerApi
//        name = "Program \(Int.random(in: 1...1000))"
//        code = "print(int(input()))"
//        target = .init(compilerName: "py", fullName: "Python")
//        input = nil
//        output = .empty
//    }
//    
//    func update(
//        name: String? = nil,
//        code: String? = nil,
//        target: TargetLanguage? = nil,
//        input: String? = nil,
//        output: OutputState = .empty
//    ) {
//        self.name = name ?? self.name
//        self.code = code ?? self.code
//        self.target = target ?? self.target
//        self.input = input ?? self.input
//        self.output = switch output {
//        case .empty: self.output
//        default: output
//        }
//    }
//    
//    func setDefault() {
//        name = "Program \(Int.random(in: 1...1000))"
//        code = "print(int(input()))"
//        target = .init(compilerName: "py", fullName: "Python")
//        input = nil
//        output = .empty
//    }
    
    func loadProgram(withId id: ObjectIdentifier) {
        program.loadProgram(withId: id)
    }
    
    func runCode() {
        program.runCode()
    }
    
    func highlightText(
        _ text: String,
        compilerName: String? = nil,
        style: HighlightStyle
    ) async -> NSAttributedString? {
        let lastSymbol = text.last
        do {
            let highlighted = try await Highlight.text(
                text,
                language: compilerName,
                style: style
            ).attributed
            let attributedString = NSMutableAttributedString(
                highlighted.mergingAttributes(
                    .init([
                        NSAttributedString.Key.font: UIFont.monospacedSystemFont(
                            ofSize: 18,
                            weight: .regular
                        )
                    ])
                )
            )
            attributedString.mutableString.append(
                lastSymbol?.isWhitespace ?? false || lastSymbol?.isNewline ?? false ?
                    lastSymbol?.description ?? "" :
                    ""
            )
            return attributedString
        } catch {
            print("error when highlighting")
            return nil
        }
    }
    
    func openRunModal() {
        coordinator.openProgramModal()
    }
    
    func closeRunModal(withOutput output: OutputState) {
        coordinator.closeProgramModal()
        program.updateOutput(output)
    }
}
