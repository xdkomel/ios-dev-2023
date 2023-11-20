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
import SwiftUI

final class ProgramViewModel {
    let program: ProgramModel
    let coordinator: Coordinator
    
    init(program: ProgramModel, coordinator: Coordinator) {
        self.program = program
        self.coordinator = coordinator
    }
    
    func loadProgram(withId id: Int) {
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
        let firstSymbol = text.first
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
            let mutableString = attributedString.mutableString
            mutableString.append(
                lastSymbol?.isWhitespace ?? false || lastSymbol?.isNewline ?? false ?
                    lastSymbol?.description ?? "" :
                    ""
            )
            mutableString.insert(
                firstSymbol?.isWhitespace ?? false || firstSymbol?.isNewline ?? false ?
                    firstSymbol?.description ?? "" :
                     "",
                at: 0
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
    
    func save() {
        program.save()
    }
}
