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

class ProgramRunModalViewController: UIViewController {
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
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .systemBackground
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("program.close-button", comment: ""),
            style: .plain,
            target: self,
            action: #selector(close)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("program.run-button", comment: ""),
            style: .done,
            target: self,
            action: #selector(runCode)
        )
        inputField.textAlignment = .center
        inputField.borderStyle = .roundedRect
//        inputField.text = viewModel.program.program.input
        outputText.textAlignment = .center
        outputText.numberOfLines = 3
        setView()
        setBinding()
        super.viewWillAppear(animated)
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
            .prepend([viewModel.program.programData?.input ?? inputField.text ?? ""])
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.program.programData?.input = text
            }
            .store(in: &subscriptions)
        
        // ViewModel -> View
        viewModel.$program
            .receive(on: RunLoop.main)
            .sink { [ weak self ] program in
                
                switch program.programData?.output {
                case let .oldEmpty(oldResult):
                    self?.outputText.text = "\(NSLocalizedString("program.last-output", comment: "")) \(self?.filterOutput(oldResult) ?? oldResult)"
                    self?.outputText.textColor = .secondaryLabel
                case .loading:
                    self?.outputText.text = NSLocalizedString("program.loading", comment: "")
                    self?.outputText.textColor = .secondaryLabel
                case let .error(description):
                    self?.outputText.text = description
                    self?.outputText.textColor = .systemRed
                case let .data(output):
                    self?.outputText.text = self?.filterOutput(output) ?? output
                    self?.outputText.textColor = .label
                default:
                    // .empty + when programData is nil
                    self?.outputText.text = NSLocalizedString("program.enter-input", comment: "")
                    self?.outputText.textColor = .secondaryLabel
                }
            }
            .store(in: &subscriptions)
    }
    
    private func filterOutput(_ output: String) -> String {
        output.isEmpty ?
            NSLocalizedString("program.empty-output", comment: "") :
            output
    }
    
    @objc private func runCode() {
        viewModel.runCode()
    }
    
    @objc private func close() {
        let outputToStore: OutputState = switch viewModel.program.programData?.output {
        case let .oldEmpty(oldResult): .oldEmpty(oldResult: oldResult)
        case let .data(output): .oldEmpty(oldResult: output)
        default: .empty
        }
        viewModel.closeRunModal(withOutput: outputToStore)
//        dismiss(animated: true)
//        viewModel.output = switch viewModel.output {
//        case let .oldEmpty(oldResult): .oldEmpty(oldResult: oldResult)
//        case let .data(output): .oldEmpty(oldResult: output)
//        default: .empty
//        }
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
