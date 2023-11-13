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
    private let outputText = UILabel()
    // Business
    private let compilerApi = MoyaProvider<Compiler>()
    private var subsctiptions = Set<AnyCancellable>()
    private var viewModel: ProgramViewModel
    // Program model
    private let programCode: String
    private let programInput: String?
    private let programName: String
    private let programTarget: TargetLanguage
    
    init(
        programCode: String,
        programInput: String?,
        programName: String,
        programTarget: TargetLanguage
    ) {
        self.programCode = programCode
        self.programInput = programInput
        self.programName = programName
        self.programTarget = programTarget
        viewModel = .init(
            name: programName,
            code: programCode,
            target: programTarget,
            input: programInput
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = programName
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Run",
            style: .done,
            target: self,
            action: #selector(onRunCode)
        )
        
        codeText.isScrollEnabled = true
        codeText.isEditable = true
        codeText.isSelectable = true
        codeText.font = .systemFont(ofSize: 24)
        outputText.text = "Default"
        
        setView()
        setBindings()
    }
    
    func highlightText(_ text: String) {
        _Concurrency.Task {
            do {
                let attributedString = try await Highlight.text(text, style: .light(.google)).attributed
                codeText.text = text
                codeText.attributedText = NSAttributedString(attributedString)
            } catch {
                codeText.text = text
                print("error when highlighting")
            }
        }
    }
    
    func setView() {
        view.addSubview(codeText)
//        view.addSubview(outputText)
        
        codeText.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
//            make.leading.trailing.equalToSuperview().inset(16)
        }
//        outputText.snp.makeConstraints { make in
//            make.top.equalTo(codeText.snp.bottom).inset(-16)
//            make.leading.trailing.equalToSuperview().inset(16)
//        }
    }
    
    func setBindings() {
        // View -> (ViewModel + View)
        codeText.textPublisher
            .prepend([codeText.text ?? ""])
            .receive(on: RunLoop.main)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.viewModel.code = text
                self?.highlightText(text)
            }
            .store(in: &subsctiptions)
        
        // ViewModel -> View
        viewModel.$output
            .receive(on: RunLoop.main)
            .sink { [ weak self ] output in
                self?.outputText.text = switch output {
                case .empty: "Default"
                case .loading: "Loading..."
                case let .error(description): description
                case let .data(output): output
                }
            }
            .store(in: &subsctiptions)
    }
    
    @objc func onRunCode() {
        viewModel.runCode()
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
