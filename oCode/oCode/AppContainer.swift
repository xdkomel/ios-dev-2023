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
    var coordinator: Coordinator?
    
    func build() {
        guard let coord = coordinator else {
            print("error building app container")
            return
        }
        register(withCoordinator: coord)
        initCoordinator(coord)
    }
    
    func register(withCoordinator coordinator: Coordinator) {
        container
            .record(Storage.self, name: "default") { _ in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                return Storage(appDelegate.persistentContainer.viewContext)
            }
            .inObjectScope(.container)
        container
            .record(MoyaProvider<Compiler>.self) { _ in
                MoyaProvider<Compiler>()
            }
            .inObjectScope(.container)
        // HomeScreen
        container
            .record(HomeScreenModel.self) { res in
                HomeScreenModel(
                    programs: nil,
                    storage: res.provide(Storage.self)
                )
            }
            .inObjectScope(.container)
        container
            .record(HomeScreenViewModel.self) { res in
                HomeScreenViewModel(
                    model: res.provide(HomeScreenModel.self),
                    coordinator: coordinator
                )
            }
            .inObjectScope(.container)
        container
            .record(HomeScreenViewController.self) { res in
                HomeScreenViewController(
                    homeScreenViewModel: res.provide(HomeScreenViewModel.self)
                )
            }
            .inObjectScope(.container)
        // Program
        container
            .record(ProgramModel.self) { res in
                ProgramModel(
                    compilerApi: res.provide(MoyaProvider<Compiler>.self),
                    storage: res.provide(Storage.self)
                )
            }
            .inObjectScope(.container)
        container
            .record(ProgramViewModel.self) { res in
                ProgramViewModel(
                    program: res.provide(ProgramModel.self),
                    coordinator: coordinator
                )
            }
            .inObjectScope(.container)
        container
            .record(ProgramViewController.self) { res in
                ProgramViewController(
                    viewModel: res.provide(ProgramViewModel.self)
                )
            }
            .inObjectScope(.container)
        container
            .record(ProgramRunModalViewController.self) { res in
                ProgramRunModalViewController(
                    viewModel: res.provide(ProgramViewModel.self)
                )
            }
            .inObjectScope(.container)
    }
    
    func initCoordinator(_ coordinator: Coordinator) {
        coordinator.homeScreenViewController =
            container.provide(HomeScreenViewController.self)
        coordinator.programViewController =
            container.provide(ProgramViewController.self)
        coordinator.programModalViewController =
            container.provide(ProgramRunModalViewController.self)
    }
}

extension Resolver {
    func provide<Service>(_ serviceType: Service.Type, name: String? = nil) -> Service {
        resolve(serviceType, name: name ?? "default")!
    }
}

extension Container {
    func record<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> {
        register(serviceType, name: name ?? "default", factory: factory)
    }
}
