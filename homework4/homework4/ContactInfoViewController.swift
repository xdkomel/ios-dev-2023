//
//  ContactInfoViewController.swift
//  homework4
//
//  Created by Kamil Foatov on 08.10.2023.
//

import Foundation
import UIKit

class ContactInfoViewController: UIViewController, UIScrollViewDelegate {
    private let name: String
    private let image: UIImageView
    private lazy var scrollView: UIScrollView = produceScrollView()
    
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        name = "undefined"
        image = UIImageView()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = name
        
        scrollView.addSubview(setImage())
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
        ])
    }
    
    private func produceScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentMode = .center

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.isScrollEnabled = true
        return scrollView
    }
    
    private func setImage() -> UIImageView {
        image.translatesAutoresizingMaskIntoConstraints = false
        guard let uiImage = image.image else {
            return image
        }
        image.image = uiImage.imageWith(newSize: .init(
            width: view.frame.width,
            height: uiImage.size.height / uiImage.size.width * view.frame.width
        ))
        return image
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return image
    }
}
