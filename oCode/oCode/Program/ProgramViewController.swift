//
//  ViewController.swift
//  oCode
//
//  Created by Kamil Foatov on 08.11.2023.
//

import UIKit
import SnapKit
import Moya
import Combine
import HighlightSwift

class ProgramViewController: UIViewController {
    // UI
    private let codeText = UITextView()
    private let targetSelector = UIButton()
    // Business
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: ProgramViewModel
    var programIdToLoad: Int?
    
    init(viewModel: ProgramViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let programId = programIdToLoad {
            viewModel.loadProgram(withId: programId)
        }
        viewModel.loadTargets()
        view.backgroundColor = .systemBackground
        self.navigationItem.titleView = {
            let title = UILabel()
            title.text = viewModel.program.programData?.name
            title.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
            return title
        }()
//        setTargetLanguage()
        self.targetSelector.showsMenuAsPrimaryAction = true
        self.targetSelector.changesSelectionAsPrimaryAction = true
        self.targetSelector.isEnabled = true
        self.targetSelector.setTitleColor(.systemBlue, for: .normal)
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: NSLocalizedString("program.run-button", comment: ""),
                style: .done,
                target: self,
                action: #selector(openModal)
            ),
            UIBarButtonItem(customView: self.targetSelector)
        ]
        
        highlightText(viewModel.program.programData?.code ?? "")
        codeText.isScrollEnabled = true
        codeText.isEditable = true
        codeText.isSelectable = true
        codeText.font = .monospacedSystemFont(ofSize: 18, weight: .regular)
        codeText.autocapitalizationType = .none
        codeText.autocorrectionType = .no
        
        setView()
        setBindings()
        viewModel.save()
        super.viewWillAppear(animated)
    }
    
    func setAvailableTargets(_ targets: [String]) {
//        self.targetSelector.setTitle(
//            selectedName,
////            viewModel.program.programData?.target.fullName ?? "Unknown",
//            for: .normal
//        )
        
        self.targetSelector.menu = UIMenu(
            options: .displayInline,
            children: targets.map {
                UIAction(title: $0.uppercased(), handler: viewModel.selectTarget)
            }
//            children: viewModel.program.availableTargets.last().map { target in
//                UIAction(title: target.fullName, handler: viewModel.selectTarget)
//            }
        )
        self.navigationItem.rightBarButtonItems?.removeLast()
        self.navigationItem.rightBarButtonItems?.append(
            UIBarButtonItem(
                customView: self.targetSelector
            )
        )
    }
    
    func setView() {
        view.addSubview(codeText)
        codeText.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func setBindings() {
        // Update the viewModel
        codeText.textPublisher
            .sink { [weak self] text in
                self?.viewModel.program.programData?.code = text
            }
            .store(in: &subscriptions)
        
        // Highlight the text on change
        // Save the program
        codeText.textPublisher
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.highlightText(text)
                self?.viewModel.save()
            }
            .store(in: &subscriptions)
        
        // Update the targets
        viewModel.program.availableTargetsPublished
            .prepend([viewModel.program.lastAvailableTargets])
            .sink { [weak self] targets in
                self?.setAvailableTargets(targets)
            }
            .store(in: &subscriptions)
        
        // New target is selected
//        viewModel.program.targetChangePublished
//            .sink { [weak self] _ in
////                self?.highlightExistingText()
//            }
//            .store(in: &subscriptions)
    }
    
    func highlightExistingText() {
        highlightText(codeText.text)
    }
    
    func highlightText(_ text: String) {
        _Concurrency.Task {
            let cursor = codeText.selectedRange
            let style: HighlightStyle = view
                .window?
                .windowScene?
                .traitCollection
                .userInterfaceStyle == .dark ?
                    .dark(.google) :
                    .light(.google)
            let compiler = viewModel.program.programData?.target
            if let attributedString = await viewModel.highlightText(
                text,
                compilerName: compiler,
                style: style
            ) {
                codeText.attributedText = attributedString
                codeText.selectedRange = cursor
            } else {
                codeText.text = text
                codeText.selectedRange = cursor
            }
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            highlightExistingText()
        }
    }
    
    @objc func openModal() {
        viewModel.openRunModal()
    }
}

extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification,
            object: self
        )
        .compactMap { $0.object as? UITextView }
        .compactMap(\.text)
        .eraseToAnyPublisher()
    }
}
