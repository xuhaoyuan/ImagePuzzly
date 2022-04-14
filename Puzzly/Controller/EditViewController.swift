import UIKit

class EditViewController: UIViewController {
    private let image: UIImage
    var wholeImage: UIImage?
    var editView: EditView!

    static func show(from: UIViewController, image: UIImage) {
        let editingViewController = EditViewController(image: image)
        let navi = UINavigationController(rootViewController: editingViewController)
        navi.modalPresentationStyle = .fullScreen
        from.present(navi, animated: true, completion: nil)
    }

    private lazy var rightItem: UIBarButtonItem = {
        var icon = UIBarButtonItem.SystemItem.cancel
        if #available(iOS 13.0, *) {
            icon = UIBarButtonItem.SystemItem.close
        }
        return UIBarButtonItem(barButtonSystemItem: icon, target: self, action: #selector(quitButtonTouched))
    }()

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        title = "Clip"
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = rightItem
        editView = EditView(image: image)
        editView.delegate = self
        editView.setup(parentView: view)
    }

    // Update Layout for iPad if needed
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        editView.updateLayout()
    }

    @objc private func quitButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EditViewController: EditViewDelegate {

    func startButtonTouched() {
        let playViewController = PlayViewController()
        playViewController.imagesWithInitialPosition = self.getSnapshots()
        playViewController.hintImage = self.getHintImage()
        playViewController.modalPresentationStyle = .fullScreen
        self.present(playViewController, animated: true)
    }

    private func getHintImage() -> UIImage {
        let rectangle = calculateBoundHintImage()
        let image = cropImage(image: wholeImage!, rectangle: rectangle)
        return image
    }

    /// Calculate the frame of the hint image
    ///
    /// - Returns: Hint image frame
    private func calculateBoundHintImage() -> CGRect {
        var height: CGFloat = 0
        var width: CGFloat = 0

        // There are 16 squares 4 per row and 4 per columns
        for index in 0...3 {
            let bound = editView.imagesBound[index]
            height += bound.height
            width += bound.width
        }

        let size = CGSize(width: width, height: height)
        let origin = editView.imagesBound[0].origin
        let bound = CGRect(origin: origin, size: size)

        return bound
    }

    /// Get images of all the squares
    ///
    /// - Returns: array of snapshots
    private func getSnapshots() -> [Image] {
        guard let imagesBound = editView.imagesBound  else { return [Image]() }
        var images = [Image]()
        wholeImage = snapshotWholeScreen()
        let max = imagesBound.count - 1
        for index in 0...max {
            let bound = imagesBound[index]
            let image = cropImage(image: wholeImage!, rectangle: bound, id: index)
            images.append(image)
        }
        return images
    }

    /// Take a snapshot of the whole screen
    ///
    /// - Returns: UIImage of the main view
    private func snapshotWholeScreen() -> UIImage {
        let bounds = self.editView.bounds

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        self.editView.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return snapshot
    }

    /// Create a "Image" with id by croping a UIImage
    ///
    /// - Parameters:
    ///   - image: Image to crop
    ///   - rectangle: Frame to crop
    ///   - id: Initial position
    /// - Returns: Image with id
    private func cropImage(image: UIImage, rectangle: CGRect, id: Int) -> Image {
        let uiimage = cropImage(image: image, rectangle: rectangle)
        return Image(image: uiimage, id: id)
    }

    /// Create a cropped UIImage
    ///
    /// - Parameters:
    ///   - image: Full size image
    ///   - rectangle: Frame to crop
    /// - Returns: Cropped UIImage
    private func cropImage(image: UIImage, rectangle: CGRect) -> UIImage {
        let scale: CGFloat = image.scale
        let scaledRect = CGRect(x: rectangle.origin.x * scale,
                                y: rectangle.origin.y * scale,
                                width: rectangle.size.width * scale,
                                height: rectangle.size.height * scale)
        let cgImage = image.cgImage?.cropping(to: scaledRect)
        let uiimage = UIImage(cgImage: cgImage!, scale: scale, orientation: .up)
        return uiimage
    }
}
