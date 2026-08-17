//
//  CreateNFTViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import PhotosUI
import Observation

/// NFT Creation Screen — layout defined in Main.storyboard.
final class CreateNFTViewController: UIViewController {

    // MARK: - Dependencies

    var viewModel: CreateNFTViewModel!

    // MARK: - IBOutlets

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imagePickerContainer: UIView!
    @IBOutlet weak var uploadPlaceholderStack: UIStackView!
    @IBOutlet weak var uploadIconImageView: UIImageView!
    @IBOutlet weak var uploadTitleLabel: UILabel!
    @IBOutlet weak var uploadSubtitleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceContainerView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorBannerLabel: UILabel!

    // MARK: - Subviews

    private let descPlaceholderLabel = UILabel()
    private let submitButtonGradientLayer = CAGradientLayer()
    private var observationTask: Task<Void, Never>?
    private var hasHandledSuccess: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        startObserving()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let submitButton {
            submitButtonGradientLayer.frame = submitButton.bounds
            submitButton.layer.cornerRadius = submitButton.bounds.height / 2
        }
        if let backButton {
            backButton.layer.cornerRadius = backButton.bounds.height / 2
        }
    }

    deinit {
        observationTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1.0)

        // Custom Nav Bar
        if let backButton {
            backButton.backgroundColor = UIColor(red: 246/255.0, green: 251/255.0, blue: 231/255.0, alpha: 0.35)
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
            backButton.tintColor = .black
            backButton.clipsToBounds = true
        }

        headerTitleLabel?.font = UIFont(name: "Poppins-Medium", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        headerTitleLabel?.textColor = UIColor(red: 17/255.0, green: 20/255.0, blue: 28/255.0, alpha: 1.0)

        // Image Picker Container
        if let imagePickerContainer {
            imagePickerContainer.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
            imagePickerContainer.layer.cornerRadius = 16
            imagePickerContainer.clipsToBounds = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
            imagePickerContainer.addGestureRecognizer(tapGesture)
            imagePickerContainer.isUserInteractionEnabled = true
        }

        if let uploadIconImageView {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            uploadIconImageView.image = UIImage(systemName: "square.and.arrow.up", withConfiguration: symbolConfig)
            uploadIconImageView.tintColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0)
        }

        uploadTitleLabel?.font = UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        uploadTitleLabel?.textColor = UIColor(red: 23/255.0, green: 24/255.0, blue: 22/255.0, alpha: 1.0)

        uploadSubtitleLabel?.font = UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        uploadSubtitleLabel?.textColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 150/255.0, alpha: 1.0)

        selectedImageView?.layer.cornerRadius = 16
        selectedImageView?.clipsToBounds = true

        // Form Labels
        titleLabel?.font = UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        titleLabel?.textColor = .black

        descLabel?.font = UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        descLabel?.textColor = .black

        priceLabel?.font = UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        priceLabel?.textColor = .black

        currencyLabel?.font = UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        currencyLabel?.textColor = .black

        // Title Field
        if let titleTextField {
            titleTextField.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            titleTextField.textColor = .black
            titleTextField.backgroundColor = .white
            titleTextField.layer.cornerRadius = 8
            titleTextField.layer.borderWidth = 1
            titleTextField.layer.borderColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 234/255.0, alpha: 1.0).cgColor
            titleTextField.clipsToBounds = true

            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 48))
            titleTextField.leftView = leftPaddingView
            titleTextField.leftViewMode = .always
            titleTextField.attributedPlaceholder = NSAttributedString(
                string: "Enter the Nft name",
                attributes: [.foregroundColor: UIColor(red: 199/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)]
            )
        }

        // Description TextView
        if let descTextView {
            descTextView.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            descTextView.textColor = .black
            descTextView.backgroundColor = .white
            descTextView.layer.cornerRadius = 8
            descTextView.layer.borderWidth = 1
            descTextView.layer.borderColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 234/255.0, alpha: 1.0).cgColor
            descTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
            descTextView.delegate = self
            descTextView.clipsToBounds = true

            descPlaceholderLabel.text = "Enter"
            descPlaceholderLabel.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            descPlaceholderLabel.textColor = UIColor(red: 199/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            descPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
            descTextView.addSubview(descPlaceholderLabel)

            NSLayoutConstraint.activate([
                descPlaceholderLabel.topAnchor.constraint(equalTo: descTextView.topAnchor, constant: 12),
                descPlaceholderLabel.leadingAnchor.constraint(equalTo: descTextView.leadingAnchor, constant: 13)
            ])
        }

        // Price Container
        if let priceContainerView {
            priceContainerView.backgroundColor = .white
            priceContainerView.layer.cornerRadius = 8
            priceContainerView.layer.borderWidth = 1
            priceContainerView.layer.borderColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 234/255.0, alpha: 1.0).cgColor
            priceContainerView.clipsToBounds = true
        }

        if let priceTextField {
            priceTextField.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
            priceTextField.textColor = .black
            priceTextField.attributedPlaceholder = NSAttributedString(
                string: "Enter the amount",
                attributes: [.foregroundColor: UIColor(red: 199/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)]
            )
        }

        // Submit Button
        if let submitButton {
            submitButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
            submitButtonGradientLayer.colors = [
                UIColor(red: 58/255.0, green: 108/255.0, blue: 244/255.0, alpha: 1.0).cgColor,
                UIColor(red: 14/255.0, green: 195/255.0, blue: 244/255.0, alpha: 1.0).cgColor
            ]
            submitButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
            submitButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
            submitButton.layer.insertSublayer(submitButtonGradientLayer, at: 0)
            submitButton.clipsToBounds = true
        }

        errorBannerLabel?.font = UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        errorBannerLabel?.layer.cornerRadius = 12
        errorBannerLabel?.clipsToBounds = true

        updateSubmitButtonState()
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            scrollView.contentInset.bottom = keyboardFrame.height + 16
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
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
                        let isLoading   = viewModel.isLoading
                        let isValid     = viewModel.isFormValid
                        let error       = viewModel.errorMessage
                        let didSucceed  = viewModel.showSuccessModal
                        let image       = viewModel.selectedImage

                        if isLoading {
                            self.loadingIndicator?.startAnimating()
                            self.submitButton?.setTitle("", for: .normal)
                        } else {
                            self.loadingIndicator?.stopAnimating()
                            self.submitButton?.setTitle("Create NFT  →", for: .normal)
                        }
                        self.submitButton?.isEnabled = isValid && !isLoading
                        self.submitButton?.alpha = (isValid && !isLoading) ? 1.0 : 0.5

                        if let image {
                            self.selectedImageView?.image = image
                            self.selectedImageView?.isHidden = false
                            self.uploadPlaceholderStack?.isHidden = true
                        } else {
                            self.selectedImageView?.isHidden = true
                            self.uploadPlaceholderStack?.isHidden = false
                        }

                        if let error {
                            self.errorBannerLabel?.text = error
                            self.errorBannerLabel?.isHidden = false
                        } else {
                            self.errorBannerLabel?.isHidden = true
                        }

                        if didSucceed && !self.hasHandledSuccess {
                            self.hasHandledSuccess = true
                            self.showSuccessModal()
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

    // MARK: - IBActions

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func titleFieldChanged(_ sender: UITextField) {
        viewModel?.title = sender.text ?? ""
        updateSubmitButtonState()
    }

    @IBAction func priceFieldChanged(_ sender: UITextField) {
        viewModel?.sellingPrice = sender.text ?? ""
        updateSubmitButtonState()
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        Task { await viewModel?.uploadNFT() }
    }

    @objc private func openImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func updateSubmitButtonState() {
        guard let viewModel else { return }
        let isValid = viewModel.isFormValid
        submitButton?.isEnabled = isValid
        submitButton?.alpha = isValid ? 1.0 : 0.5
    }

    private func showSuccessModal() {
        let successVC = storyboard?.instantiateViewController(withIdentifier: "SuccessModalViewController") as? SuccessModalViewController ?? SuccessModalViewController()
        successVC.titleText = "NFT Created Successfully!"
        successVC.messageText = "Your NFT is now visible in the My NFTs tab"
        successVC.buttonTitle = "Close"
        successVC.showArrow = false
        successVC.onAction = { [weak self] in
            guard let self else { return }
            self.viewModel?.dismissModal()
            self.viewModel?.resetForm()
            successVC.dismiss(animated: true) {
                // Navigate back to the HomeScreen
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve
        present(successVC, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension CreateNFTViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholderLabel.isHidden = !textView.text.isEmpty
        viewModel?.nftDescription = textView.text ?? ""
        updateSubmitButtonState()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CreateNFTViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.viewModel?.setImage(image)
                self?.updateSubmitButtonState()
            }
        }
    }
}
