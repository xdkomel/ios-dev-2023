//
//  ListController.swift
//  oCode
//
//  Created by Kamil Foatov on 11.11.2023.
//

import Foundation
import UIKit

final class ListController: UICollectionViewController {
    var onListElementTap: ((ProgramData) -> Void)?
    var programs: [ProgramData] = [] {
        didSet {
            applySnapshot()
        }
    }
    
    private enum Section: CaseIterable {
        case main
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ProgramData> = {
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, ProgramData> { cell, _, program in
                var content = cell.defaultContentConfiguration()
                content.text = program.name
                content.secondaryText = program.target
                content.secondaryTextProperties.color = .secondaryLabel
                content.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
                cell.contentConfiguration = content
            }

        return UICollectionViewDiffableDataSource<Section, ProgramData>(
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProgramData>()
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
