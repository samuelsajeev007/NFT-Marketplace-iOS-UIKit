//
//  CoinsViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import Observation

/// Displays cryptocurrency balances — layout defined in Main.storyboard.
final class CoinsViewController: UIViewController {

    // MARK: - Dependencies

    var viewModel: WalletViewModel!

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    // MARK: - State

    private let refreshControl = UIRefreshControl()
    private var balances: [WalletBalance] = []
    private var observationTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        startObserving()
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.register(
            UINib(nibName: CoinCell.nibName, bundle: nil),
            forCellReuseIdentifier: CoinCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // MARK: - Observation

    private func startObserving() {
        observationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                withObservationTracking {
                    let newBalances = self.viewModel.balances
                    let isLoading   = self.viewModel.isLoading

                    if newBalances != self.balances {
                        self.balances = newBalances
                        self.tableView.reloadData()
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

// MARK: - UITableViewDataSource

extension CoinsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balances.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CoinCell.reuseIdentifier,
            for: indexPath
        ) as! CoinCell
        cell.configure(with: balances[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CoinsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
