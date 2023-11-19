//
//  HomeScreenViewModel.swift
//  oCode
//
//  Created by Kamil Foatov on 16.11.2023.
//

import Foundation
import Combine

class HomeScreenViewModel {
    @Published var model: HomeScreenModel
    private let coordinator: Coordinator
    
    init(model: HomeScreenModel, coordinator: Coordinator) {
        self.model = model
        self.coordinator = coordinator
    }
    
    var newProgram: ProgramData {
        model.addNewProgram()
    }
    
    func refreshPrograms() {
        model.refreshPrograms()
    }
    
    func openProgram(withId id: Int) {
        coordinator.openProgram(withId: id)
    }
}
