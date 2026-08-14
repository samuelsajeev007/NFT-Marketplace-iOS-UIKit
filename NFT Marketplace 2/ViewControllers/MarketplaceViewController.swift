//
//  MarketplaceViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import Observation

/// Shows the paginated NFT marketplace grid — layout defined in Main.storyboard.
final class MarketplaceViewController: UIViewController {

    // MARK: - Dependencies

    var container: AppContainer = AppContainer()
    var viewModel: MarketplaceViewModel!

    // MARK: - IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    // MARK: - State

    private let refreshControl = UIRefreshControl()
    private var nfts: [NFT] = []
    private var observationTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = container.marketplaceViewModel
        }
        setupCollectionView()
        startObserving()

        Task {
            if let viewModel, viewModel.nfts.isEmpty {
                await viewModel.loadNFTs()
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        guard let collectionView else { return }
        collectionView.backgroundColor = .clear
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
        guard let viewModel else { return }
        observationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                withObservationTracking {
                    let newNFTs   = self.viewModel.nfts
                    let isLoading = self.viewModel.isLoading

                    if newNFTs != self.nfts {
                        self.nfts = newNFTs
                        self.collectionView?.reloadData()
                    }

                    if isLoading {
                        self.loadingIndicator?.startAnimating()
                    } else {
                        self.loadingIndicator?.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                } onChange: {}
                await Task.yield()
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        Task { await viewModel?.loadNFTs() }
    }
}

// MARK: - UICollectionViewDataSource

extension MarketplaceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nfts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NFTCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! NFTCollectionViewCell
        cell.configure(with: nfts[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MarketplaceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nft = nfts[indexPath.item]
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "NFTDetailViewController") as? NFTDetailViewController ?? NFTDetailViewController()
        detailVC.nft = nft
        detailVC.container = container
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == nfts.count - 3, let viewModel else { return }
        Task { await viewModel.loadMoreIfNeeded(currentItem: nfts[indexPath.item]) }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MarketplaceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let padding: CGFloat = 16 * 2 + 16
        let width = max(100, (collectionView.bounds.width - padding) / 2)
        return CGSize(width: width, height: width + 52)
    }
}
