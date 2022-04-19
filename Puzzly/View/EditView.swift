//
//  EditView.swift
//  Gridy
//
//  Created by Spencer Forrest on 28/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol EditViewDelegate: AnyObject {
    func startButtonTouched()
}

class EditView: UIView {

    private lazy var selectedView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private var clearView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    private var startButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "clips"), for: .normal)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    private(set) var squares: Squares = .s2

    private var initialUIImageViewCenter: CGPoint?

    private var isLandscapeOrientation: Bool {
        guard let superview = self.superview else { return false }
        return superview.bounds.width > superview.bounds.height
    }

    weak var delegate: EditViewDelegate?
    var imagesBound: [CGRect]!
    var snapshotBounds: CGRect {
        return self.clearView.bounds
    }

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)
        self.clipsToBounds = true
        self.backgroundColor = UIColor.lightGray
        self.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
        detectUserActions()


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(parentView view: UIView) {
        view.backgroundColor = UIColor.white
        view.addSubview(self)
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateLayout() {
        initialUIImageViewCenter = nil
        setupLayer(view: clearView)
    }

    private func setupLayer(view: UIView) {
        view.alpha = 0.0
        startButton.alpha = 0.0
        view.layer.mask = createMaskLayer()
        let fadingInAnimation = {
            view.alpha = 1.0
            self.startButton.alpha = 1.0
        }
        UIView.animate(withDuration: 0.75, animations: fadingInAnimation)
    }

    private func createMaskLayer() -> CAShapeLayer {
        guard let superView = self.superview else { return CAShapeLayer()}
        let path = CGMutablePath()
        path.addRect(CGRect(origin: .zero, size: superView.bounds.size))

        imagesBound = squares.getSquares()
        for square in imagesBound {
            path.addRect(square)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        return maskLayer
    }

    private func setupConstraints() {

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubview(clearView)
        clearView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubview(selectedView)

        addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.width.equalTo(Constant.Layout.Width.startButton)
            make.height.equalTo( Constant.Layout.Height.startButton)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        selectedView.snp.makeConstraints { make in

            make.centerX.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalTo(startButton.snp.top)
        }
    }

    private func detectUserActions() {
        startButton.addTarget(self, action: #selector(startButtonTouched), for: .touchUpInside)
        setupGestureRecognizer()
    }

    private func setupGestureRecognizer() {
        imageView.isUserInteractionEnabled = true

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetImageFrame))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(moveImageView))
        panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(panGestureRecognizer)

        let rotationGestureRecognizer = UIRotationGestureRecognizer.init(target: self, action: #selector(rotateImageView))
        rotationGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(rotationGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(scaleImageView))
        pinchGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc private func startButtonTouched() {
        delegate?.startButtonTouched()
    }


    @objc private func resetImageFrame() {
        let animation = {
            if let center = self.initialUIImageViewCenter {
                self.imageView.center = center
            }
            self.imageView.transform = .identity
        }

        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: animation)
    }

    @objc private func moveImageView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)

        if initialUIImageViewCenter == nil {
            initialUIImageViewCenter = imageView.center
        }

        let newPoint = CGPoint(x: imageView.center.x + translation.x,
                               y: imageView.center.y + translation.y)
        imageView.center = newPoint
        sender.setTranslation(CGPoint.zero, in: self)
    }

    @objc private func rotateImageView(_ sender: UIRotationGestureRecognizer) {
        imageView.transform = imageView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }

    @objc private func scaleImageView(_ sender: UIPinchGestureRecognizer) {
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
}

extension EditView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Squares.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Squares.allCases[row].title
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 56
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.squares = Squares.allCases[row]

        guard let shaplayer = clearView.layer.mask as? CAShapeLayer else { return }
        imagesBound = squares.getSquares()
        let path = CGMutablePath()
        path.addRect(CGRect(origin: .zero, size: self.bounds.size))
        for square in imagesBound {
            path.addRect(square)
        }
        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.duration = 0.3
        basicAnimation.fromValue = shaplayer.path
        basicAnimation.toValue = path
        shaplayer.path = path
        shaplayer.add(basicAnimation, forKey: "path")
        basicAnimation.isRemovedOnCompletion = true
    }
}

extension EditView: UIGestureRecognizerDelegate {
    // Delegate method: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view != imageView {
            return false
        }

        if otherGestureRecognizer.view != imageView {
            return false
        }

        if gestureRecognizer is UITapGestureRecognizer
            || otherGestureRecognizer is UITapGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
            || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
}
