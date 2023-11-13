//
//  MainScreenViewController.swift
//  HomeWork3
//
//  Created by Kamil Foatov on 30.09.2023.
//

import Foundation
import UIKit

class CardView: UIView {
    private let image = UIImageView(image: UIImage(named: "cat.png"))
    private let label1 = UILabel()
    private let label2 = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        backgroundColor = .systemGray2
        layer.cornerRadius = 16
        
        image.contentMode = .scaleAspectFit
        
        image.translatesAutoresizingMaskIntoConstraints = false
        label1.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(image)
        addSubview(label1)
        addSubview(label2)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // image
            NSLayoutConstraint(
                item: image,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: image,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: image,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: image,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .width,
                multiplier: 1,
                constant: 120
            ),
            
            // label1
            NSLayoutConstraint(
                item: label1,
                attribute: .leading,
                relatedBy: .equal,
                toItem: image,
                attribute: .trailing,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: label1,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: label1,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: -16
            ),
            
            // label2
            NSLayoutConstraint(
                item: label2,
                attribute: .leading,
                relatedBy: .equal,
                toItem: image,
                attribute: .trailing,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: label2,
                attribute: .top,
                relatedBy: .equal,
                toItem: label1,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            NSLayoutConstraint(
                item: label2,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: -16
            )
        ])
    }
    
    func setLabel1(text: String) {
        label1.text = text
    }
    
    func setLabel2(text: String) {
        label2.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
