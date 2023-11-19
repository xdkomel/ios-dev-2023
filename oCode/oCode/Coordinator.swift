//
//  Coordinator.swift
//  oCode
//
//  Created by Kamil Foatov on 19.11.2023.
//

import Foundation
import UIKit

class Coordinator {
    var navigationController: UINavigationController?
    var programViewController: ProgramViewController?
    var programModalViewController: ProgramRunModalViewController? 
    var homeScreenViewController: HomeScreenViewController?
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let viewController = homeScreenViewController else {
            return
        }
        navigationController?.show(viewController, sender: self)
    }
    
    func openProgram(withId id: ObjectIdentifier) {
        guard let viewController = programViewController else {
            return
        }
        viewController.programIdToLoad = id
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func openProgramModal() {
        guard let viewController = programModalViewController else {
            return
        }
        viewController.modalPresentationStyle = .pageSheet
        navigationController?.present(
            viewController,
            animated: true
        )
    }
    
    func closeProgramModal() {
        programModalViewController?.dismiss(animated: true)
    }
}
