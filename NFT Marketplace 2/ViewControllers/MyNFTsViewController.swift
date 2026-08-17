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
    var container: AppContainer = AppContainer()
    weak var coordinator: AppCoordinator?

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel {
            self.ownedNFTs = viewModel.ownedNFTs
            self.collectionView?.reloadData()
            self.emptyLabel?.isHidden = !viewModel.ownedNFTs.isEmpty
            Task { await viewModel.loadWalletData() }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        guard let collectionView else { return }
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
            while !Task.isCancelled {
                guard let self, let viewModel = self.viewModel else { return }
                await withCheckedContinuation { continuation in
                    var hasResumed = false
                    withObservationTracking {
                        let nfts      = viewModel.ownedNFTs
                        let isLoading = viewModel.isLoading

                        if nfts != self.ownedNFTs {
                            self.ownedNFTs = nfts
                            self.collectionView?.reloadData()
                            self.emptyLabel?.isHidden = !nfts.isEmpty
                        }

                        if isLoading {
                            self.loadingIndicator?.startAnimating()
                        } else {
                            self.loadingIndicator?.stopAnimating()
                            self.refreshControl.endRefreshing()
                        }
                    } onChange: {
                        Task { @MainActor in
                            if !hasResumed {
                                hasResumed = true
                                continuation.resume()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        Task { await viewModel?.loadWalletData() }
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
        coordinator?.navigate(to: .nftDetail(nft: nft))
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
        let width = max(100, (collectionView.bounds.width - padding) / 2)
        return CGSize(width: width, height: width + 52)
    }
}
