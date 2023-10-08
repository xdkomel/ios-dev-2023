//
//  ViewController.swift
//  homework4
//
//  Created by Kamil Foatov on 07.10.2023.
//

import UIKit

class ViewController: UIViewController {
    // Доля контактов без дефолтных аватарок
    let contactsGenerator = ContactsGenerator(solidColorProbability: 0.2)
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, ContactModel>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, ContactModel>!
    let imageSize = CGSize(width: 48, height: 48)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Контактлар"
        
        let contacts = contactsGenerator.generate(for: [
            "Айрат", "Салават", "Камил", "Алмаз", "Фарид", "Мадина", "Джамиля", "Эни", "Эти", "Альфия", "Алия", "Дамир", "Исмагил", "Иван"
        ].shuffled())
        
        setUICollectionView(contacts)
    }
    
    private func setUICollectionView(_ contacts: [ContactModel]) {
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
        ])
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ContactModel> {
            (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.image = self.produceImage(item.picture)?.imageWith(newSize: self.imageSize)
            content.text = item.name
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, ContactModel>(collectionView: collectionView) {
            (view, index, item) in
            let cell = view.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: item)
            cell.accessories = [.disclosureIndicator()]
            return cell
        }
        
        snapshot = NSDiffableDataSourceSnapshot<Section, ContactModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(contacts, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

enum Section {
    case main
}


extension ViewController: UICollectionViewDelegate {
    private func produceImage(_ picture: ContactPicture) -> UIImage? {
        let contactImage = switch picture {
            case .photo(let image): image
            case .solid(let background): UIImage(color: background)
        }
        return contactImage
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let contactInfo = ContactInfoViewController(
            name: selectedItem.name,
            image: produceImage(selectedItem.picture)
        )
        self.navigationController?.pushViewController(contactInfo, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image.withRenderingMode(renderingMode)
    }
}
