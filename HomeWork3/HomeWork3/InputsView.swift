//
//  InputsView.swift
//  HomeWork3
//
//  Created by Kamil Foatov on 01.10.2023.
//

import Foundation
import UIKit

class InputsView: UIView {
    private let input1 = UITextField()
    private let input2 = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        input1.borderStyle = .roundedRect
        input2.borderStyle = .roundedRect
        
        input1.translatesAutoresizingMaskIntoConstraints = false
        input2.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(input1)
        addSubview(input2)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: 80
            ),
            
            // input1
            NSLayoutConstraint(
                item: input1,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: input1,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            ),
            
            // input2
            NSLayoutConstraint(
                item: input2,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: input2,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: input2,
                attribute: .top,
                relatedBy: .equal,
                toItem: input1,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
        ])
    }
    
    func setInput1(placeholder: String) {
        input1.placeholder = placeholder
    }
    
    func setInput2(placeholder: String) {
        input2.placeholder = placeholder
    }
    
    func clearInput1() {
        input1.text = ""
    }
    
    func clearInput2() {
        input2.text = ""
    }
    
    func getInput1() -> String? {
        return input1.text
    }
    
    func getInput2() -> String? {
        return input2.text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
