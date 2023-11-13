//
//  SceneDelegate.swift
//  oCode
//
//  Created by Kamil Foatov on 08.11.2023.
//

import UIKit
import Swinject
import Moya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let container = {
        let container = Container()
        container.register(Storage.self) { _ in
            Storage(
                (UIApplication.shared.delegate as! AppDelegate)
                    .persistentContainer
                    .viewContext
            )
        }
        container.register(MoyaProvider<Compiler>.self) { _ in
            MoyaProvider<Compiler>()
        }
        container.register(ProgramViewModel.self) { ref in
            ProgramViewModel(
                compilerApi: ref.resolve(MoyaProvider<Compiler>.self)!
            )
        }
        container.register(HomeScreenViewController.self) { ref in
            HomeScreenViewController(
                storage: ref.resolve(Storage.self)!,
                programViewController: ref.resolve(ProgramViewController.self)!,
                programViewModel: ref.resolve(ProgramViewModel.self)!
            )
        }
        container.register(ProgramViewController.self) { ref in
            ProgramViewController(
                viewModel: ref.resolve(ProgramViewModel.self)!,
                programRunModal: ref.resolve(ProgramRunModalViewController.self)!
            )
        }
        container.register(ProgramRunModalViewController.self) { ref in
            ProgramRunModalViewController(
                viewModel: ref.resolve(ProgramViewModel.self)!
            )
        }
        return container
    }()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(
            rootViewController: container.resolve(HomeScreenViewController.self)!
        )
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}