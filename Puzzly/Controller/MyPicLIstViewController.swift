import UIKit
import RxSwift
import RxCocoa
import XHYCategories
import Photos
import SnapKit

class MyPicLIstViewController: UIViewController {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private lazy var backgroundImage: UIImageView = {
        if let image = UIImage(named: Constant.ImageName.getImageStr()) {
            return UIImageView(image: image)
        } else {
            return UIImageView(image:  UIImage(named: "image12"))
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.registerCell(HomeCollectionCell.self)
        collectionView.registerCell(NewCanvasCollectionCell.self)
        return collectionView
    }()

    private lazy var closeItem: UIBarButtonItem = {
        var icon = UIBarButtonItem.SystemItem.cancel
        if #available(iOS 13.0, *) {
            icon = UIBarButtonItem.SystemItem.close
        }
        return UIBarButtonItem(barButtonSystemItem: icon, target: self, action: #selector(quitButtonTouched))
    }()

    private lazy var rightItem: UIBarButtonItem = {
        return UIBarButtonItem.init(image: UIImage(named: "homeAdd"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newButtonTouched))
    }()

    private var deleteBottomOffset: Constraint?
    private lazy var deleteView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        let imageView = UIImageView(image: UIImage(named: "delete"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(38)
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            deleteBottomOffset = make.bottom.equalTo(view.snp.bottom).offset(-16).constraint
        }
        return view
    }()

    private let disposeBag = DisposeBag()

    private enum Items: Equatable {
        case item(Canvas)
        case new
    }

    private var canvasList: [Items] = [.new]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的拼图"
        navigationItem.leftBarButtonItem = closeItem
        navigationItem.rightBarButtonItem = rightItem
        makeUI()

        HomeViewModel.shared.obserable.bind { [weak self] list in
            self?.canvasList = list.map({ Items.item($0) })
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        deleteBottomOffset?.update(offset: -(16 + view.safeAreaInsets.bottom))
    }

    private func makeUI() {
        view.backgroundColor = UIColor.white

        view.addSubview(backgroundImage)
        view.addSubview(blurView)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

//        blurView.contentView.addSubview(deleteView)
//        deleteView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.top.equalTo(view.snp.bottom)
//        }

        blurView.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.addSubview(deleteView)
        deleteView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(blurView.contentView)
            make.top.equalTo(blurView.contentView.snp.bottom)
        }

        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(ges:)))
        collectionView.addGestureRecognizer(longPressGes)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().tintColor = .black
    }

    private var moveIndexPath: IndexPath?
    @objc func handleLongGesture(ges: UILongPressGestureRecognizer) {
        var location = ges.location(in: collectionView)
        switch (ges.state) {
        case .began:
            moveIndexPath = nil
            guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
            moveIndexPath = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) {
                collectionView.bringSubviewToFront(cell)
            }
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            showDeleteView(true)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
            location = view.convert(location, from: collectionView)
            interactive(fromPoint: location)
        case .ended:
            location = view.convert(location, from: collectionView)
            guard deleteView.frame.contains(location), let indexPath = self.moveIndexPath else {
                showDeleteView(false)
                collectionView.endInteractiveMovement()
                return
            }
            collectionView.cancelInteractiveMovement()
            canvasList.remove(at: indexPath.row)
            collectionView.performBatchUpdates { [weak self] in
                self?.collectionView.deleteItems(at: [indexPath])
            } completion: { [weak self] _ in
                HomeViewModel.shared.remove(index: indexPath.row)
                self?.showDeleteView(false)
            }
        default:
            collectionView.cancelInteractiveMovement()
            interactive(fromPoint: .zero)
        }
    }

    @objc private func quitButtonTouched() {
        dismiss(animated: true, completion: nil)
    }


    @objc private func newButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        displayMediaPicker(sourceType: sourceType)
    }

    private func showDeleteView(_ isShow: Bool) {
        if isShow {
            deleteView.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(blurView.contentView)
                make.bottom.equalTo(blurView.contentView.snp.bottom)
            }
        } else {
            deleteView.transform = CGAffineTransform.identity
            deleteView.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(blurView.contentView)
                make.top.equalTo(blurView.contentView.snp.bottom)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .beginFromCurrentState]) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { _ in

        }
    }

    private func interactive(fromPoint: CGPoint) {
        if deleteView.frame.contains(fromPoint) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) { [weak self] in
                self?.deleteView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { _ in

            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) { [weak self] in
                self?.deleteView.transform = CGAffineTransform.identity
            } completion: { _ in

            }
        }
    }
}


extension MyPicLIstViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch canvasList[indexPath.row] {
        case .item(let canvas):
            if let image = canvas.image {
                EditViewController.show(from: self, image: image)
            }
        case .new: break
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvasList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch canvasList[indexPath.row] {
        case .item(let canvas):
            let cell: HomeCollectionCell = collectionView.dequeueReusableCell(indexPath)
            cell.config(model: canvas)
            return cell
        case .new:
            let cell: NewCanvasCollectionCell = collectionView.dequeueReusableCell(indexPath)
            return cell
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - 16)/2
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        switch canvasList[indexPath.row] {
        case .item: return true
        case .new: return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let color = canvasList[sourceIndexPath.row]
        canvasList.removeAll { $0 == color }
        canvasList.insert(color, at: destinationIndexPath.row)
        HomeViewModel.shared.update(list: canvasList.compactMap({
            switch $0 {
            case .item(let value):
                return value
            case .new:
                return nil
            }
        }))
    }
}

extension MyPicLIstViewController {

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

    func actionAccordingTo(status: PHAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.checkAuthorizationAccess(granted: status == .authorized,
                                                  sourceType: sourceType,
                                                  noPermissionTitle: noPermissionTitle,
                                                  noPermissionMessage: noPermissionMessage)
                }
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        case .limited:
            self.presentImagePicker(sourceType: sourceType)
        @unknown default:
            fatalError()
        }
    }

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

    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.modalPresentationStyle = .fullScreen
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }


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


    func troubleAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

extension MyPicLIstViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true, completion: nil)

        var image: UIImage?

        if picker.allowsEditing {
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        } else {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        if let image = image {
            HomeViewModel.shared.append(model: Canvas(image: image))
        }
    }

    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
