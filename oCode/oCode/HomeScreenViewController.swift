//
//  HomeScreenViewController.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation
import UIKit
import CoreData

class HomeScreenViewController: UIViewController {
    let list = ListController()
    let coreDataContext = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer
        .viewContext
    var programs: [ProgramDataModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        title = "Programs"
    }
    
    func setView() {
        list.collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(
                using: UICollectionLayoutListConfiguration(
                    appearance: .insetGrouped
                )
            )
        )
        list.programs = Array(1...100).map { i in
            let program = ProgramDataModel(context: coreDataContext)
            program.name = "Program \(i)"
            program.language = {
                let lang = LanguageDataModel(context: coreDataContext)
                lang.fullName = "Python"
                return lang
            }()
            return program
        }
        list.onListElementTap = { [weak self] program in
            self?.navigationController?.pushViewController(
                ProgramViewController(
                    programCode: program.code ?? "print(int(input()))",
                    programInput: program.input,
                    programName: program.name ?? "Untitled",
                    programTarget: .init(
                        compilerName: program.language?.tag ?? "py",
                        fullName: program.language?.fullName ?? "Python"
                    )
                ),
                animated: true
            )
        }
        view.addSubview(list.collectionView)
        list.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
