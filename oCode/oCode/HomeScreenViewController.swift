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
    let storage = Storage(
        (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer
            .viewContext
    )
    var list = ListController()
    var label = UILabel()
    var button = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Programs"
        view.backgroundColor = .systemBackground
        list.collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(
                using: UICollectionLayoutListConfiguration(
                    appearance: .insetGrouped
                )
            )
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateScreen()
        super.viewDidAppear(animated)
    }
    
    func updateScreen() {
        view.subviews.forEach {
            $0.removeFromSuperview()
            $0.removeConstraints($0.constraints)
        }
        if let programs = storage.load() {
            if programs.isEmpty {
                setInitialView()
            } else {
                setListView(programs)
            }
        } else {
            setErrorView()
        }
    }
    
    func setErrorView() {
        label.text = "An error happened"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func setInitialView() {
        label.text = "You have no programs"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(createNewProgram), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(button)
        
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func setListView(_ programs: [ProgramDataModel]) {
        self.navigationItem.rightBarButtonItem = .init(
            title: "New",
            style: .done,
            target: self,
            action: #selector(createNewProgram)
        )
        list.programs = programs
        if list.onListElementTap == nil {
            list.onListElementTap = { [weak self] program in
                self?.openProgram(program)
            }
        }
        view.addSubview(list.collectionView)
        list.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func openProgram(_ program: ProgramDataModel) {
        navigationController?.pushViewController(
            ProgramViewController(program: program, storage: storage),
            animated: true
        )
    }
    
    @objc func createNewProgram() {
        openProgram(storage.newProgram())
    }
}
