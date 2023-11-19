//
//  HomeScreenModel.swift
//  oCode
//
//  Created by Kamil Foatov on 18.11.2023.
//

import Foundation

struct HomeScreenModel {
    private(set) var programs: [ProgramData]?
    private let storage: Storage
    
    init(programs: [ProgramData]? = nil, storage: Storage) {
        self.programs = programs
        self.storage = storage
    }
    
    mutating func addNewProgram() -> ProgramData {
        let program = storage.newProgram()
        refreshPrograms()
        return program
    }
    
    mutating func refreshPrograms() {
        programs = storage.load()
    }
}
