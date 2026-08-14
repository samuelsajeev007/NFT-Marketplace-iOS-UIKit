//
//  WalletViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

/// Wallet hub VC — layout defined in Main.storyboard.
/// Contains Sub-Nav (My NFTs / Coins toggle + Create NFT button)
/// and swaps between MyNFTsViewController and CoinsViewController.
final class WalletViewController: UIViewController {

    // MARK: - Dependencies

    var container: AppContainer = AppContainer()
    var viewModel: WalletViewModel!

    // MARK: - IBOutlets

    @IBOutlet weak var myNFTsButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
    @IBOutlet weak var createNFTButton: UIButton!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var pillBackground: UIView!

    // MARK: - State

    private var selectedWalletTab: WalletTab = .myNFTs

    // MARK: - Child VCs

    private lazy var myNFTsVC: MyNFTsViewController = {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyNFTsViewController") as? MyNFTsViewController ?? MyNFTsViewController()
        vc.viewModel = self.viewModel
        vc.container = self.container
        return vc
    }()

    private lazy var coinsVC: CoinsViewController = {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CoinsViewController") as? CoinsViewController ?? CoinsViewController()
        vc.viewModel = self.viewModel
        return vc
    }()

    private var currentChildVC: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = container.walletViewModel
        }
        setupUI()
        showWalletTab(.myNFTs, animated: false)

        Task {
            if let viewModel, viewModel.ownedNFTs.isEmpty {
                await viewModel.loadWalletData()
            }
        }
    }

    // MARK: - Setup

    private func setupUI() {
        pillBackground?.layer.cornerRadius = 17.5
        pillBackground?.clipsToBounds = true

        myNFTsButton?.layer.cornerRadius = 15.5
        myNFTsButton?.clipsToBounds = true

        coinsButton?.layer.cornerRadius = 15.5
        coinsButton?.clipsToBounds = true

        createNFTButton?.layer.cornerRadius = 17.5
        createNFTButton?.layer.borderWidth = 1
        createNFTButton?.layer.borderColor = UIColor.techbankBlue.cgColor
        createNFTButton?.clipsToBounds = true

        updatePillSelection()
    }

    // MARK: - IBActions

    @IBAction func myNFTsButtonTapped(_ sender: UIButton) {
        selectedWalletTab = .myNFTs
        updatePillSelection()
        showWalletTab(.myNFTs, animated: true)
    }

    @IBAction func coinsButtonTapped(_ sender: UIButton) {
        selectedWalletTab = .coins
        updatePillSelection()
        showWalletTab(.coins, animated: true)
    }

    @IBAction func createNFTButtonTapped(_ sender: UIButton) {
        let createVC = storyboard?.instantiateViewController(withIdentifier: "CreateNFTViewController") as? CreateNFTViewController ?? CreateNFTViewController()
        createVC.viewModel = container.createNFTViewModel
        navigationController?.pushViewController(createVC, animated: true)
    }

    // MARK: - Helpers

    private func updatePillSelection() {
        let isNFTs = (selectedWalletTab == .myNFTs)
        myNFTsButton?.backgroundColor = isNFTs ? .techbankBlue : .clear
        myNFTsButton?.setTitleColor(isNFTs ? .white : .black, for: .normal)

        coinsButton?.backgroundColor = isNFTs ? .clear : .techbankBlue
        coinsButton?.setTitleColor(isNFTs ? .black : .white, for: .normal)

        createNFTButton?.isHidden = !isNFTs
    }

    private func showWalletTab(_ tab: WalletTab, animated: Bool) {
        guard let contentContainerView else { return }
        let targetVC: UIViewController = tab == .myNFTs ? myNFTsVC : coinsVC
        if let current = currentChildVC, current === targetVC { return }

        addChild(targetVC)
        targetVC.view.frame = contentContainerView.bounds
        targetVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if animated {
            targetVC.view.alpha = 0
            contentContainerView.addSubview(targetVC.view)
            UIView.animate(withDuration: 0.2) { targetVC.view.alpha = 1 }
            currentChildVC?.view.removeFromSuperview()
            currentChildVC?.removeFromParent()
        } else {
            contentContainerView.addSubview(targetVC.view)
            currentChildVC?.view.removeFromSuperview()
            currentChildVC?.removeFromParent()
        }
        targetVC.didMove(toParent: self)
        currentChildVC = targetVC
    }
}
