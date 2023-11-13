//
//  ProgramRunViewController.swift
//  oCode
//
//  Created by Kamil Foatov on 12.11.2023.
//

import Foundation
import UIKit
import SnapKit
import Combine

class ProgramRunViewController: UIViewController {
    private let inputField = UITextField()
    private let outputText = UILabel()
    
    private var viewModel: ProgramViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: ProgramViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(close)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Run",
            style: .done,
            target: self,
            action: #selector(runCode)
        )
        inputField.textAlignment = .center
        inputField.borderStyle = .roundedRect
        inputField.text = viewModel.input
        outputText.textAlignment = .left
        setView()
        setBinding()
    }
    
    private func setView() {
        view.addSubview(inputField)
        view.addSubview(outputText)
        
        inputField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        outputText.snp.makeConstraints { make in
            make.top.equalTo(inputField.snp.bottom).inset(-16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        // View -> ViewModel
        inputField.textPublisher
            .prepend([viewModel.input ?? inputField.text ?? ""])
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.input = text
            }
            .store(in: &subscriptions)
        
        // ViewModel -> View
        viewModel.$output
            .receive(on: RunLoop.main)
            .sink { [ weak self ] output in
                switch output {
                case let .oldEmpty(oldResult):
                    self?.outputText.text = "The last output was \(oldResult)"
                    self?.outputText.textColor = .secondaryLabel
                case .empty:
                    self?.outputText.text = "Enter some input text and press run"
                    self?.outputText.textColor = .secondaryLabel
                case .loading:
                    self?.outputText.text = "Loading..."
                    self?.outputText.textColor = .secondaryLabel
                case let .error(description):
                    self?.outputText.text = description
                    self?.outputText.textColor = .systemRed
                case let .data(output):
                    self?.outputText.text = output
                    self?.outputText.textColor = .label
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func runCode() {
        viewModel.runCode()
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
        switch self.viewModel.output {
        case let .data(output):
            self.viewModel.output = .oldEmpty(oldResult: output)
        default:
            self.viewModel.output = .empty
        }
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
