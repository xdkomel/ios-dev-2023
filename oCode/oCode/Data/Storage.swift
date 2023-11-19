//
//  Storage.swift
//  oCode
//
//  Created by Kamil Foatov on 12.11.2023.
//

import Foundation
import CoreData

class Storage {
    let context: NSManagedObjectContext
    var loadedPrograms: [ObjectIdentifier : ProgramDataModel] = [:]
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func dataToViewModel(_ dataModel: ProgramDataModel) -> ProgramData {
        .init(
            id: dataModel.id,
            name: dataModel.name ?? generatedProgramName,
            code: dataModel.code ?? defaultProgramCode,
            target: dataModel.language?.fullName != nil && dataModel.language?.tag != nil ?
                .init(
                    compilerName: dataModel.language!.tag!,
                    fullName: dataModel.language!.fullName!
                ) :
                defaultProgramTarget,
            output: dataModel.output != nil ?
                .oldEmpty(oldResult: dataModel.output!) :
                .empty,
            input: dataModel.input
        )
    }
    
    var generatedProgramName: String {
        "Program \(Int.random(in: 1...1000))"
    }
    let defaultProgramCode: String = "print(int(input()))"
    let defaultProgramTarget: TargetLanguage = .init(compilerName: "py", fullName: "Python")
    
    func load() -> [ProgramData]? {
        do {
            let programs = try context.fetch(ProgramDataModel.fetchRequest())
            for program in programs {
                loadedPrograms[program.id] = program
            }
            return programs.map(dataToViewModel)
        } catch {
            print("couldn't fetch data from CoreData")
        }
        return nil
    }
    
    func newProgram() -> ProgramData {
        let newProgram = ProgramDataModel(context: context)
        loadedPrograms[newProgram.id] = newProgram
        return dataToViewModel(newProgram)
    }
    
    func findProgram(withId id: ObjectIdentifier) -> ProgramData? {
        if context.hasChanges {
            load()
        }
        if let program = loadedPrograms[id] {
            return dataToViewModel(program)
        }
        return nil
    }
    
    func viewToDataModel(viewProgram program: ProgramData, coreDataProgram data: ProgramDataModel) {
        data.name = program.name
        data.code = program.code
        data.language?.fullName = program.target.fullName
        data.language?.tag = program.target.compilerName
        data.output = switch program.output {
        case .data(let output): output
        case .oldEmpty(let oldResult): oldResult
        case .empty: nil
        default: data.output
        }
        data.input = program.input
    }
    
    func save(_ program: ProgramData) {
        if let programDataModel = loadedPrograms[program.id] {
            viewToDataModel(viewProgram: program, coreDataProgram: programDataModel)
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("error while saving the CoreData context")
                }
            }
        } else {
            print("Cannot find a program with ID=\(program.id) in the storage")
        }
    }
}
