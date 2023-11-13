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

class ProgramViewController: UIViewController {
    // UI
    private let codeField = UITextField()
    private let runButton = UIButton()
    private let outputText = UILabel()
    // Business
    private let compilerApi = MoyaProvider<Compiler>()
    private var subsctiptions = Set<AnyCancellable>()
    private var viewModel = ProgramViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeField.text = "print(int(input()) + 1)"
        runButton.setTitle("Run", for: .normal)
        runButton.addTarget(self, action: #selector(self.onRunCode), for: .touchUpInside)
        outputText.text = "Default"
        
        setView()
        setBindings()
    }
    
    func setView() {
        view.addSubview(codeField)
        view.addSubview(runButton)
        view.addSubview(outputText)
        
        codeField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        runButton.snp.makeConstraints { make in
            make.top.equalTo(codeField.snp.bottom).inset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        outputText.snp.makeConstraints { make in
            make.top.equalTo(runButton.snp.bottom).inset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func setBindings() {
        // View -> ViewModel
        codeField.textPublisher
            .prepend([codeField.text ?? ""])
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.code = text
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

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { $0.object as? UITextField }
        .compactMap(\.text)
        .eraseToAnyPublisher()
    }
}
