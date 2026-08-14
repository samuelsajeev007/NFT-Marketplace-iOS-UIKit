//
//  MyNFTsViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import Observation

/// Grid of owned NFTs — layout defined in Main.storyboard.
final class MyNFTsViewController: UIViewController {

    // MARK: - Dependencies

    var viewModel: WalletViewModel!
    var container: AppContainer!

    // MARK: - IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!

    // MARK: - State

    private let refreshControl = UIRefreshControl()
    private var ownedNFTs: [NFT] = []
    private var observationTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        startObserving()
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.register(
            UINib(nibName: NFTCollectionViewCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: NFTCollectionViewCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    // MARK: - Observation

    private func startObserving() {
        observationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                withObservationTracking {
                    let nfts      = self.viewModel.ownedNFTs
                    let isLoading = self.viewModel.isLoading

                    if nfts != self.ownedNFTs {
                        self.ownedNFTs = nfts
                        self.collectionView.reloadData()
                        self.emptyLabel.isHidden = !nfts.isEmpty
                    }

                    if isLoading {
                        self.loadingIndicator.startAnimating()
                    } else {
                        self.loadingIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                } onChange: {}
                await Task.yield()
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        Task { await viewModel.loadWalletData() }
    }
}

// MARK: - UICollectionViewDataSource

extension MyNFTsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ownedNFTs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NFTCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! NFTCollectionViewCell
        cell.configure(with: ownedNFTs[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MyNFTsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nft = ownedNFTs[indexPath.item]
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "NFTDetailViewController") as! NFTDetailViewController
        detailVC.nft = nft
        detailVC.container = container
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MyNFTsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let padding: CGFloat = 16 * 2 + 16
        let width = (collectionView.bounds.width - padding) / 2
        return CGSize(width: width, height: width + 52)
    }
}
