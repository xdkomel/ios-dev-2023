//
//  Container.swift
//  oCode
//
//  Created by Kamil Foatov on 19.11.2023.
//

import Foundation
import Swinject
import Moya

class AppContainer {
    let container = Container()
    
    func build(withCoordinator coordinator: Coordinator) {
        register(withCoordinator: coordinator)
        initCoordinator(coordinator)
    }
    
    func register(withCoordinator coordinator: Coordinator) {
        // Managers
//        container.register(UINavigationController.self) { res in
//            UINavigationController(
//                rootViewController: res.provide(HomeScreenViewController.self)
//            )
//        }
        container.register(Storage.self) { _ in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return Storage(appDelegate.persistentContainer.viewContext)
        }
        container.register(MoyaProvider<Compiler>.self) { _ in
            MoyaProvider<Compiler>()
        }
//        container
//            .register(Coordinator.self) { _ in
//                Coordinator()
//            }
//            .initCompleted { res, coordinator in
//                coordinator.programModalViewController = res.provide(ProgramRunModalViewController.self)
//                coordinator.programViewController = res.provide(ProgramViewController.self)
//                coordinator.navigationController = res.provide(UINavigationController.self)
//            }
        // HomeScreen
        container.register(HomeScreenModel.self) { res in
            HomeScreenModel(
                programs: nil,
                storage: res.provide(Storage.self)
            )
        }
        container.register(HomeScreenViewModel.self) { res in
            HomeScreenViewModel(
                model: res.provide(HomeScreenModel.self),
                coordinator: coordinator
            )
        }
        container.register(HomeScreenViewController.self) { res in
            HomeScreenViewController(
                homeScreenViewModel: res.provide(HomeScreenViewModel.self)
            )
        }
        // Program
        container.register(ProgramModel.self) { res in
            ProgramModel(
                compilerApi: res.provide(MoyaProvider<Compiler>.self),
                storage: res.provide(Storage.self)
            )
        }
        container.register(ProgramViewModel.self) { res in
            ProgramViewModel(
                program: res.provide(ProgramModel.self),
                coordinator: coordinator
            )
        }
        container.register(ProgramViewController.self) { res in
            ProgramViewController(
                viewModel: res.provide(ProgramViewModel.self)
            )
        }
        container.register(ProgramRunModalViewController.self) { res in
            ProgramRunModalViewController(
                viewModel: res.provide(ProgramViewModel.self)
            )
        }
    }
    
    func initCoordinator(_ coordinator: Coordinator) {
        coordinator.homeScreenViewController =
            container.provide(HomeScreenViewController.self)
        coordinator.programViewController =
            container.provide(ProgramViewController.self)
        coordinator.programModalViewController =
            container.provide(ProgramRunModalViewController.self)
    }
    
//    func provide<Service>(_ serviceType: Service.Type) -> Service {
//        container.provide(serviceType)
//    }
}

extension Resolver {
    func provide<Service>(_ serviceType: Service.Type) -> Service {
        resolve(serviceType, name: nil)!
    }
}
