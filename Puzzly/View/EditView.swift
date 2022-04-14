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

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private var clearView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    private var startButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Start", for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.backgroundColor = UIColor.main
        view.titleLabel?.font = UIFont(name: Constant.Font.Name.timeBurner, size: Constant.Font.Size.startButtonLabel)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

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
        let fadingOutAnimation = {
            view.alpha = 0.0
            self.startButton.alpha = 0.0
        }

        UIView.animate(withDuration: 0.1, animations: fadingOutAnimation) {
            (done) in
            if done {
                view.layer.mask = self.createMaskLayer()

                let fadingInAnimation = {
                    view.alpha = 1.0
                    self.startButton.alpha = 1.0
                }
                UIView.animate(withDuration: 0.75, animations: fadingInAnimation)
            }
        }
    }

    private func createMaskLayer() -> CAShapeLayer {
        guard let superView = self.superview else { return CAShapeLayer()}
        let path = CGMutablePath()
        path.addRect(CGRect(origin: .zero, size: superView.bounds.size))

        imagesBound = Position(parentView: self).getSquares()
        for square in imagesBound {
            path.addRect(square)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        return maskLayer
    }

    private func calculateOffset(forStartButton: Bool) -> CGFloat {
        guard let superview = self.superview else { return 0 }
        let safeArea = (self.superview?.safeAreaInsets)!
        let height = superview.bounds.height - safeArea.top - safeArea.bottom
        let width = superview.bounds.width - safeArea.right - safeArea.left

        let short = isLandscapeOrientation ? height : width
        let long = isLandscapeOrientation ? width : height

        let viewWidth = Constant.Layout.Width.button
        let viewHeight = Constant.Layout.Height.button

        let viewOffset = isLandscapeOrientation ? viewWidth : viewHeight

        let sizeTile = short * Constant.Layout.SizeRatio.puzzleGrid / CGFloat(Constant.Tiles.Puzzle.countByRow)
        let allSquareSize = sizeTile * CGFloat(Constant.Tiles.Puzzle.countByRow) + Constant.Tiles.Puzzle.gapLength * 3
        let maxSquare = forStartButton ? ((long - allSquareSize) / 2) + allSquareSize : ((long - allSquareSize) / 2)
        let margin = forStartButton ? (long - maxSquare) / 2 - viewOffset / 2 : (maxSquare) / 2 + viewOffset / 2

        let offset = forStartButton ? maxSquare + margin : maxSquare - margin

        return offset
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
        addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.width.equalTo(Constant.Layout.Width.startButton)
            make.height.equalTo( Constant.Layout.Height.startButton)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-32)
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
