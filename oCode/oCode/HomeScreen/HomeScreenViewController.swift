//
//  HomeScreenViewController.swift
//  oCode
//
//  Created by Kamil Foatov on 09.11.2023.
//

import Foundation
import UIKit
import CoreData
import Combine

class HomeScreenViewController: UIViewController {
//    private let storage: Storage
//    private let programViewController: ProgramViewController
//    private let programViewModel: ProgramViewModel
    private let viewModel: HomeScreenViewModel
    private var bindings = Set<AnyCancellable>()
    private let list = ListController()
    private let label = UILabel()
    private let button = UIButton()
    
    
    init(
        homeScreenViewModel: HomeScreenViewModel
//        coordinator: Coordinator
//        storage: Storage,
//        programViewController: ProgramViewController,
//        programViewModel: ProgramViewModel
    ) {
        viewModel = homeScreenViewModel
//        self.coordinator = coordinator
//        self.storage = storage
//        self.programViewController = programViewController
//        self.programViewModel = programViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        viewModel.refreshPrograms()
        setBindings()
//        updateScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("homescreen.title", comment: "")
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        updateScreen()
//        super.viewDidAppear(animated)
//    }
    
    func updateScreen(optionalPrograms: [ProgramData]?) {
        view.subviews.forEach {
            $0.removeFromSuperview()
            $0.removeConstraints($0.constraints)
        }
        if let programs = optionalPrograms {
            if programs.isEmpty {
                setInitialView()
            } else {
                setListView(programs)
            }
        } else {
            setErrorView()
        }
    }
    
    func setBindings() {
        viewModel.$model
            .sink { [weak self] model in
                self?.updateScreen(optionalPrograms: model.programs)
            }
            .store(in: &bindings)
//        viewModel.model.programs
//            .sink(receiveValue: updateScreen)
//            .store(in: &bindings)
    }
    
    func setErrorView() {
        label.text = NSLocalizedString("homescreen.error", comment: "")
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
        label.text = NSLocalizedString("homescreen.no-programs", comment: "")
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        button.setTitle(NSLocalizedString("homescreen.create-button", comment: ""), for: .normal)
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
    
    func setListView(_ programs: [ProgramData]) {
        self.navigationItem.rightBarButtonItem = .init(
            title: NSLocalizedString("homescreen.new-button", comment: ""),
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
    
    func openProgram(_ program: ProgramData) {
//        programViewModel.update(
//            name: program.name,
//            code: program.code,
//            target: program.language?.tag != nil && program.language?.fullName != nil ?
//                .init(
//                    compilerName: program.language!.tag!,
//                    fullName: program.language!.fullName!
//                ) :
//                nil,
//            input: program.input,
//            output: program.output == nil ?
//                .empty :
//                .oldEmpty(oldResult: program.output!)
//        )
//        programViewController.onClose = { [weak self] in
//            program.name = self?.programViewModel.name
//            program.code = self?.programViewModel.code
//            program.language?.fullName = self?.programViewModel.target.fullName
//            program.language?.tag = self?.programViewModel.target.compilerName
//            program.input = self?.programViewModel.input
//            program.output = switch self?.programViewModel.output {
//            case .oldEmpty(let oldResult): oldResult
//            case .data(let output): output
//            default: nil
//            }
//            self?.storage.save()
//            self?.programViewModel.setDefault()
//        }
        viewModel.openProgram(withId: program.id)
//        navigationController?.pushViewController(
//            viewModel.getProgramViewController(withId: program.id),
//            animated: true
//        )
    }
    
    @objc func createNewProgram() {
        openProgram(viewModel.newProgram)
    }
}
