//
//  CreateNFTViewController.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 14/08/26.
//

import UIKit
import PhotosUI
import Observation

/// Create NFT form VC — layout defined in Main.storyboard.
final class CreateNFTViewController: UIViewController {

    // MARK: - Dependencies

    var viewModel: CreateNFTViewModel!

    // MARK: - IBOutlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imagePickerContainer: UIView!
    @IBOutlet weak var uploadPlaceholderStack: UIStackView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorBannerLabel: UILabel!

    // MARK: - Layers

    private let submitButtonGradientLayer = CAGradientLayer()
    private var observationTask: Task<Void, Never>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        startObserving()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        submitButtonGradientLayer.frame = submitButton.bounds
        submitButton.layer.cornerRadius = submitButton.bounds.height / 2
    }

    deinit {
        observationTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        imagePickerContainer.backgroundColor = UIColor.gray.withAlphaComponent(0.15)
        imagePickerContainer.layer.cornerRadius = 16
        imagePickerContainer.clipsToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        imagePickerContainer.addGestureRecognizer(tapGesture)
        imagePickerContainer.isUserInteractionEnabled = true

        // Form Fields Styling
        titleTextField.layer.cornerRadius = 8
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        titleTextField.clipsToBounds = true

        descTextView.layer.cornerRadius = 8
        descTextView.layer.borderWidth = 1
        descTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        descTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        descTextView.delegate = self
        descTextView.clipsToBounds = true

        submitButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        submitButtonGradientLayer.colors = [
            UIColor.buyButtonGradientStart.cgColor,
            UIColor.buyButtonGradientEnd.cgColor
        ]
        submitButtonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        submitButtonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        submitButton.layer.insertSublayer(submitButtonGradientLayer, at: 0)
        submitButton.clipsToBounds = true

        errorBannerLabel.font = UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        errorBannerLabel.layer.cornerRadius = 12
        errorBannerLabel.clipsToBounds = true

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
        observationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                withObservationTracking {
                    let isLoading   = self.viewModel.isLoading
                    let isValid     = self.viewModel.isFormValid
                    let error       = self.viewModel.errorMessage
                    let didSucceed  = self.viewModel.showSuccessModal
                    let image       = self.viewModel.selectedImage

                    if isLoading {
                        self.loadingIndicator.startAnimating()
                        self.submitButton.setTitle("", for: .normal)
                    } else {
                        self.loadingIndicator.stopAnimating()
                        self.submitButton.setTitle("Create NFT  →", for: .normal)
                    }
                    self.submitButton.isEnabled = isValid && !isLoading
                    self.submitButton.alpha = (isValid && !isLoading) ? 1.0 : 0.5

                    if let image {
                        self.selectedImageView.image = image
                        self.selectedImageView.isHidden = false
                        self.uploadPlaceholderStack.isHidden = true
                    } else {
                        self.selectedImageView.isHidden = true
                        self.uploadPlaceholderStack.isHidden = false
                    }

                    if let error {
                        self.errorBannerLabel.text = error
                        self.errorBannerLabel.isHidden = false
                    } else {
                        self.errorBannerLabel.isHidden = true
                    }

                    if didSucceed {
                        self.showSuccessModal()
                    }
                } onChange: {}
                await Task.yield()
            }
        }
    }

    // MARK: - IBActions

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func titleFieldChanged(_ sender: UITextField) {
        viewModel.title = sender.text ?? ""
        updateSubmitButtonState()
    }

    @IBAction func priceFieldChanged(_ sender: UITextField) {
        viewModel.sellingPrice = sender.text ?? ""
        updateSubmitButtonState()
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        Task { await viewModel.uploadNFT() }
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
        let isValid = viewModel.isFormValid
        submitButton.isEnabled = isValid
        submitButton.alpha = isValid ? 1.0 : 0.5
    }

    private func showSuccessModal() {
        let successVC = storyboard!.instantiateViewController(withIdentifier: "SuccessModalViewController") as! SuccessModalViewController
        successVC.titleText = "NFT Created Successfully!"
        successVC.messageText = "Your NFT is now visible in the My NFTs tab"
        successVC.buttonTitle = "View NFT"
        successVC.showArrow = true
        successVC.onAction = { [weak self] in
            self?.viewModel.dismissModal()
            self?.navigationController?.popViewController(animated: true)
        }
        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve
        present(successVC, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension CreateNFTViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.nftDescription = textView.text ?? ""
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
                self?.viewModel.setImage(image)
                self?.updateSubmitButtonState()
            }
        }
    }
}
