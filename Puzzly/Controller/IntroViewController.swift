//
//  IntroViewController.swift
//  Gridy
//
//  Created by Spencer Forrest on 17/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SnapKit
class IntroViewController: UIViewController {

    private var titleLabel = UILabel(text: "Puzzly", font: UIFont(name: "Didot", size: 80) ?? .systemFont(ofSize: 80, weight: .regular), color: .black, alignment: .center)

    private var randomButton = Button(imageName: Constant.ImageName.random)
    private var photosButton = Button(imageName: Constant.ImageName.photos)
    private var cameraButton = Button(imageName: Constant.ImageName.camera)

    private lazy var stackView = UIStackView(arrangedSubviews: [randomButton, photosButton, cameraButton])



    override func viewDidLoad() {

        makeUI()
        detectUserActions()
    }

    private func makeUI() {
        view.backgroundColor = UIColor(hexString: "D49888")

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 18

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY)
        }

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }

        randomButton.alpha = 0
        photosButton.alpha = 0
        cameraButton.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.randomButton.alpha = 1
        } completion: { _ in

        }

        UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseOut) { [weak self] in
            self?.photosButton.alpha = 1
        } completion: { _ in

        }

        UIView.animate(withDuration: 1, delay: 0.4, options: .curveEaseOut) { [weak self] in
            self?.cameraButton.alpha = 1
        } completion: { _ in

        }
    }

    private func detectUserActions() {
        randomButton.addTarget(self, action: #selector(randomButtonTouched), for: UIControl.Event.touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonTouched), for: UIControl.Event.touchUpInside)
        photosButton.addTarget(self, action: #selector(photosButtonTouched), for: UIControl.Event.touchUpInside)
    }

    @objc private func randomButtonTouched() {
        let random = Int.random(min: 0, max: 4)
        if let image = UIImage(named: Constant.ImageName.image + "\(random)") {
            EditViewController.show(from: self, image: image)
        }
    }

    @objc private func cameraButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.camera
        displayMediaPicker(sourceType: sourceType)
    }

    @objc private func photosButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        displayMediaPicker(sourceType: sourceType)
    }
}

extension IntroViewController {

    func displayMediaPicker(sourceType: UIImagePickerController.SourceType) {

        let usingCamera = sourceType == .camera
        let media = usingCamera ? "Camera" : "Photos"

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let noPermissionTitle = "Access to your \'\(media)\' denied"
            let noPermissionMessage = "\nGo to \'Settings\' to allow the access."

            if usingCamera {
                actionAccordingTo(status: AVCaptureDevice.authorizationStatus(for: AVMediaType.video),
                                  noPermissionTitle: noPermissionTitle,
                                  noPermissionMessage: noPermissionMessage)
            } else {
                actionAccordingTo(status: PHPhotoLibrary.authorizationStatus(),
                                  noPermissionTitle: noPermissionTitle,
                                  noPermissionMessage: noPermissionMessage)
            }
        } else {
            let title = "\'\(media)\' unavailable"
            let message = "\(Constant.String.title) cannot have acces to your \'\(media)\' at this time."
            troubleAlert(title: title, message: message)
        }
    }

    func actionAccordingTo(status: AVAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.camera
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) {
                self.checkAuthorizationAccess(granted: $0,
                                              sourceType: sourceType,
                                              noPermissionTitle: noPermissionTitle,
                                              noPermissionMessage: noPermissionMessage)
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        @unknown default:
            fatalError()
        }
    }

    /// Ask the user the authorization to use the photo library.
    /// User can redirect to Settings if authorization not granted.
    /// Call Image Picker if authorization has already been granted
    ///
    /// - Parameters:
    ///   - status: Authorization status to use PhotoLibrary
    ///   - noPermissionMessage: Message to display if authorization not granted
    func actionAccordingTo(status: PHAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization {
                self.checkAuthorizationAccess(granted: $0 == .authorized,
                                              sourceType: sourceType,
                                              noPermissionTitle: noPermissionTitle,
                                              noPermissionMessage: noPermissionMessage)
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        @unknown default:
            fatalError()
        }
    }

    /// Check if user has just granted or denied access to the ressource.
    /// If granted, call image picker
    /// If not granted, User can redirect to Settings
    ///
    /// - Parameters:
    ///   - granted: True if authorization has been granted
    ///   - sourceType: Camera or Photo library
    ///   - noPermissionMessage: Message to display if authorization not granted
    func checkAuthorizationAccess(granted: Bool,
                                  sourceType: UIImagePickerController.SourceType,
                                  noPermissionTitle: String?,
                                  noPermissionMessage: String?) {
        if granted {
            self.presentImagePicker(sourceType: sourceType)
        } else {
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        }
    }

    /// Present image picker
    ///
    /// - Parameter sourceType: Camera or photo library
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }

    ///   User can go the Settings from here if wanted
    ///
    /// - Parameter message: Description about why user needs to go to Settings
    func openSettingsWithUIAlert(title: String?, message: String?) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) {
            _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }


    /// Popup an alert message
    ///
    /// - Parameter message: Description of the issue
    func troubleAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

extension IntroViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)

        var image: UIImage?

        if picker.allowsEditing {
            image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        } else {
            image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        }

        if let image = image {
            EditViewController.show(from: self, image: image)
        }
    }

    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImagePickerController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
