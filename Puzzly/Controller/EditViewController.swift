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
        DispatchQueue.global().async {
            let data = image.pngData()
            UserDefaults.standard.set(data, forKey: "ImageData")
        }
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
        navigationItem.leftBarButtonItem = rightItem
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
        getSnapshots { [weak self] result in
            guard let self = self, let result = result else { return }
            let playViewController = PlayViewController(square: self.editView.squares, originImage: self.image, hintImage: result.1, clipImages: result.0)
            let navi = UINavigationController(rootViewController: playViewController)
            navi.modalPresentationStyle = .fullScreen
            self.present(navi, animated: true)
        }
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


    private func getSnapshots(finish: @escaping (([UIImage], UIImage)?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let snapshotRect: CGRect = self.editView.imagesBound.reduce(CGRect.zero) { partialResult, rect in
                let x: CGFloat = partialResult.minX == 0 ?  rect.minX : min(partialResult.minX, rect.minX)
                let y: CGFloat = partialResult.minY == 0 ? rect.minY : min(partialResult.minY, rect.minY)
                let width = max(partialResult.maxX, rect.maxX)
                let height = max(partialResult.maxY, rect.maxY)
               return CGRect(x: x, y: y, width: width - x, height: height-y)
            }

            var images: [UIImage] = []
            let wholeImage = self.snapshotWholeScreen()

            for (index, item) in self.editView.imagesBound.enumerated() {
                let image = self.cropImage(image: wholeImage, rectangle: item, id: index)
                images.append(image)
            }
            let hintImage = self.cropImage(image: wholeImage, rectangle: snapshotRect)
            DispatchQueue.main.async {
                finish((images, hintImage))
            }
        }
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
    private func cropImage(image: UIImage, rectangle: CGRect, id: Int) -> UIImage {
        return cropImage(image: image, rectangle: rectangle)
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
