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
    // Business
    private let compilerApi = MoyaProvider<Compiler>()
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: ProgramViewModel
    // Persistence
    private let storage: Storage
    private let program: ProgramDataModel
    
    init(program: ProgramDataModel, storage: Storage) {
        viewModel = .init(
            name: program.name ?? "Program \(Int.random(in: 1...1000))",
            code: program.code ?? "print(int(input()))",
            target: .init(
                compilerName: program.language?.tag ?? "py",
                fullName: program.language?.fullName ?? "Python"
            ),
            input: program.input,
            output: program.output == nil ?
                .empty :
                .oldEmpty(oldResult: program.output!)
        )
        self.program = program
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        program.name = viewModel.name
        program.code = viewModel.code
        program.language?.fullName = viewModel.target.fullName
        program.language?.tag = viewModel.target.compilerName
        program.input = viewModel.input
        program.output = switch viewModel.output {
        case .oldEmpty(let oldResult): oldResult
        default: nil
        }
        storage.save()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.navigationItem.titleView = {
            let title = UILabel()
            title.text = viewModel.name
            title.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
            return title
        }()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Run",
            style: .done,
            target: self,
            action: #selector(openModal)
        )
        
        codeText.text = viewModel.code
        highlightText(viewModel.code)
        codeText.isScrollEnabled = true
        codeText.isEditable = true
        codeText.isSelectable = true
        codeText.font = .monospacedSystemFont(ofSize: 18, weight: .regular)
        codeText.autocapitalizationType = .none
        codeText.autocorrectionType = .no
        
        setView()
        setBindings()
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
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.code = text
            }
            .store(in: &subscriptions)
        
        // Highlight the text on change
        codeText.textPublisher
            .receive(on: RunLoop.main)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.highlightText(text)
            }
            .store(in: &subscriptions)
    }
    
    func highlightExistingText() {
        highlightText(codeText.text)
    }
    
    func highlightText(_ text: String) {
        _Concurrency.Task {
            let cursor = codeText.selectedRange
            let lastSymbol = text.last
            let style: HighlightStyle = view
                .window?
                .windowScene?
                .traitCollection
                .userInterfaceStyle == .dark ?
                    .dark(.google) :
                    .light(.google)
            do {
                let highlighted = try await Highlight.text(
                    text,
                    language: self.viewModel.target.compilerName, 
                    style: style
                ).attributed
                let attributedString = NSMutableAttributedString(
                    highlighted.mergingAttributes(.init([
                        NSAttributedString.Key.font: UIFont.monospacedSystemFont(
                            ofSize: 18,
                            weight: .regular
                        )
                    ]))
                )
                attributedString.mutableString.append(
                    lastSymbol?.isWhitespace ?? false || lastSymbol?.isNewline ?? false ?
                        lastSymbol?.description ?? "" :
                        ""
                )
                codeText.attributedText = attributedString
                codeText.selectedRange = cursor
            } catch {
                codeText.text = text
                codeText.selectedRange = cursor
                print("error when highlighting")
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
        self.navigationController?.present(
            {
                let modal = UINavigationController(
                    rootViewController: ProgramRunViewController(
                        viewModel: viewModel
                    )
                )
                modal.modalPresentationStyle = .pageSheet
                return modal
            }(),
            animated: true
        )
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
