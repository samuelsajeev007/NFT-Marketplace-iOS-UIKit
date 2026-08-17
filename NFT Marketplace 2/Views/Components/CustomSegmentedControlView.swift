//
//  CustomSegmentedControlView.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit

// MARK: - HomeTab

enum HomeTab: Int, CaseIterable {
    case marketplace = 0
    case myWallets   = 1

    var title: String {
        switch self {
        case .marketplace: return "Marketplace"
        case .myWallets:   return "My Wallets"
        }
    }
}

// MARK: - Delegate

protocol CustomSegmentedControlDelegate: AnyObject {
    func segmentedControl(_ control: CustomSegmentedControlView, didSelect tab: HomeTab)
}

// MARK: - CustomSegmentedControlView

/// Animated underline segmented control matching the SwiftUI CustomSegmentedControl design.
final class CustomSegmentedControlView: UIView {

    // MARK: - Properties

    weak var delegate: CustomSegmentedControlDelegate?

    private(set) var selectedTab: HomeTab = .marketplace {
        didSet { updateSelection(animated: true) }
    }

    // MARK: - Subviews

    private let stackView       = UIStackView()
    private let indicatorView   = UIView()
    private let dividerView     = UIView()
    private var buttons: [UIButton] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .white

        // Divider at bottom
        dividerView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false

        // Stack
        stackView.axis         = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing      = 0
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Indicator
        indicatorView.backgroundColor = UIColor(red: 51/255.0, green: 137/255.0, blue: 251/255.0, alpha: 1.0)
        indicatorView.layer.cornerRadius = 3
        indicatorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        indicatorView.clipsToBounds = true
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),

            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 3)
        ])

        // Buttons
        for tab in HomeTab.allCases {
            let button = UIButton(type: .custom)
            button.tag = tab.rawValue
            button.setTitle(tab.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont(name: "SofiaProMedium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }

        // Initial indicator constraint (will be updated)
        updateSelection(animated: false)
    }

    // MARK: - Selection

    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorWidth: NSLayoutConstraint?
    private var indicatorSetup = false
    private let indicatorInset: CGFloat = 16

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0 else { return }
        let segWidth = bounds.width / CGFloat(max(HomeTab.allCases.count, 1))
        let targetX = (CGFloat(selectedTab.rawValue) * segWidth) + indicatorInset
        let targetW = max(0, segWidth - (indicatorInset * 2))
        if !indicatorSetup {
            indicatorSetup = true
            indicatorLeading = indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: targetX)
            indicatorWidth   = indicatorView.widthAnchor.constraint(equalToConstant: targetW)
            NSLayoutConstraint.activate([indicatorLeading!, indicatorWidth!])
        } else {
            indicatorWidth?.constant = targetW
            indicatorLeading?.constant = targetX
        }
    }

    private func updateSelection(animated: Bool) {
        let segWidth = bounds.width / CGFloat(max(HomeTab.allCases.count, 1))
        let targetX = (CGFloat(selectedTab.rawValue) * segWidth) + indicatorInset

        let update = {
            self.indicatorLeading?.constant = targetX
            if animated { self.layoutIfNeeded() }
            for btn in self.buttons {
                let isSelected = btn.tag == self.selectedTab.rawValue
                let fontName = isSelected ? "SofiaProSemiBold" : "SofiaProMedium"
                btn.titleLabel?.font = UIFont(name: fontName, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: isSelected ? .semibold : .medium)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
                update()
            }
        } else {
            update()
        }
    }

    // MARK: - Actions

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let tab = HomeTab(rawValue: sender.tag) else { return }
        selectedTab = tab
        delegate?.segmentedControl(self, didSelect: tab)
    }

    func setTab(_ tab: HomeTab, animated: Bool = true) {
        selectedTab = tab
    }
}
