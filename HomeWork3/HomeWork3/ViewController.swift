//
//  ViewController.swift
//  HomeWork3
//
//  Created by Kamil Foatov on 30.09.2023.
//

import UIKit

class ViewController: UIViewController {
    let card = CardView()
    let inputs = InputsView()
    let setButton = UIButton(type: .system)
    
    override func loadView() {
        super.loadView()
        print("load view".uppercased())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load".uppercased())
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear".uppercased())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear".uppercased())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disappear".uppercased())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view did disappear".uppercased())
    }
    
    private func setup() {
        card.setLabel1(text: "Default Name")
        card.setLabel2(text: "Default Education")
        card.translatesAutoresizingMaskIntoConstraints = false
        
        inputs.setInput1(placeholder: "Name")
        inputs.setInput2(placeholder: "Education")
        inputs.translatesAutoresizingMaskIntoConstraints = false
        
        setButton.setTitle("Set", for: .normal)
        setButton.addTarget(self, action: #selector(onSetTap), for: .touchUpInside)
        setButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(card)
        view.addSubview(inputs)
        view.addSubview(setButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // card
            NSLayoutConstraint(
                item: card,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: card,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: -16
            ),
            NSLayoutConstraint(
                item: card,
                attribute: .top,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .top,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: card,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: 152
            ),
            
            // inputs
            NSLayoutConstraint(
                item: inputs,
                attribute: .top,
                relatedBy: .equal,
                toItem: card,
                attribute: .bottom,
                multiplier: 1,
                constant: 24
            ),
            NSLayoutConstraint(
                item: inputs,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: inputs,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: -16
            ),
            
            // setButton
            NSLayoutConstraint(
                item: setButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: inputs,
                attribute: .bottom,
                multiplier: 1,
                constant: 24
            ),
            NSLayoutConstraint(
                item: setButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: setButton,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: -16
            ),
        ])
    }
    
    @objc func onSetTap(sender: UIButton!) {
        guard let text1 = inputs.getInput1() else {
            return
        }
        guard let text2 = inputs.getInput2() else {
            return
        }
        if text1.isEmpty || text2.isEmpty {
            return
        }
        card.setLabel1(text: text1)
        card.setLabel2(text: text2)
    }
    
}

