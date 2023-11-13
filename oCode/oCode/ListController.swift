//
//  ListController.swift
//  oCode
//
//  Created by Kamil Foatov on 11.11.2023.
//

import Foundation
import UIKit

final class ListController: UICollectionViewController {
    var onListElementTap: ((ProgramDataModel) -> Void)?
    var programs: [ProgramDataModel] = [] {
        didSet {
            applySnapshot()
        }
    }
    
    private enum Section: CaseIterable {
        case main
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ProgramDataModel> = {
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, ProgramDataModel> { cell, _, program in
                var content = cell.defaultContentConfiguration()
                content.text = program.name
                if program.language != nil {
                    content.secondaryText = program.language?.fullName
                    content.secondaryTextProperties.color = .secondaryLabel
                    content.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
                }
                cell.contentConfiguration = content
            }

        return UICollectionViewDiffableDataSource<Section, ProgramDataModel>(
            collectionView: collectionView
        ) { collectionView, indexPath, country -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: country
            )
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        applySnapshot(animatingDifferences: false)
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProgramDataModel>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(programs)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let program = dataSource.itemIdentifier(for: indexPath) {
            if let onTap = onListElementTap {
                onTap(program)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
