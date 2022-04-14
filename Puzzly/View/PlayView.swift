//
//  PlayView.swift
//  Gridy
//
//  Created by Spencer Forrest on 04/07/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol PlayViewDelegate: AnyObject {
    func handlePuzzleViewDrag(_ gestureRecognizer: UIPanGestureRecognizer)
    func handleShareButtonTapped()
}

class PlayView: UIView {

    weak var delegate: PlayViewDelegate?

    lazy var puzzleGridView = PuzzleGridView(images: puzzlePieceViews)

    var headerView = HeaderView()
    var centeringView = UIView()

    var shareButton: UIButton?

    let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constant.Font.Name.helveticaNeue, size: 15)
        label.text = Constant.String.instruction
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    var puzzlePieceViews = [UIImageView]()
    var puzzlePieceViewConstraints = [Int: [NSLayoutConstraint]]()

    var hintView: HintView!

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    init(hintImage: UIImage, puzzlePieceViews: [UIImageView]) {
        self.puzzlePieceViews = puzzlePieceViews
        super.init(frame: .zero)
        hintView = HintView(image: hintImage)
        addSubviews()
        setupGestureRecognizers()

        for (index, item) in puzzlePieceViews.enumerated() {
            if let tile = puzzleGridView.getTile(from: index) {
                item.isUserInteractionEnabled = true
                addSubview(item)
                place(item, inside: tile)
            }
        }

    }


    func place(_ puzzlePieceView: UIImageView, inside tile: TilesView) {
        let id = puzzlePieceView.tag

        if let oldConstraints = self.puzzlePieceViewConstraints[id] {
            NSLayoutConstraint.deactivate(oldConstraints)
            puzzlePieceView.translatesAutoresizingMaskIntoConstraints = true
        }

        let newConstraints = [
            puzzlePieceView.topAnchor.constraint(equalTo: tile.topAnchor, constant: -1/2),
            puzzlePieceView.leftAnchor.constraint(equalTo: tile.leftAnchor, constant: -1/2),
            puzzlePieceView.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: 1/2),
            puzzlePieceView.rightAnchor.constraint(equalTo: tile.rightAnchor, constant: 1/2)
        ]

        NSLayoutConstraint.setAndActivate(newConstraints)
        tile.imageView = puzzlePieceView
        self.puzzlePieceViewConstraints[id] = newConstraints
    }

    func convertCenterPointCoordinateSystem(of view: UIView, to containerView: UIView) -> CGPoint {
        let newX = view.frame.origin.x - containerView.frame.origin.x
        let newY = view.frame.origin.y - containerView.frame.origin.y

        let centerX = view.frame.width/2 + newX
        let centerY = view.frame.height/2 + newY

        return CGPoint(x: centerX, y: centerY)
    }

    func layoutEndGameMode() {
        removeUserInteraction(from: puzzlePieceViews)
        instructionLabel.isHidden = true
        addSharePuzzleButton()
    }

    private func removeUserInteraction(from views: [UIView]) {
        for view in views {
            view.isUserInteractionEnabled = false
        }
    }

    private func addSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.white

        headerView.backgroundColor = UIColor.brown

        addSubview(centeringView)
        addSubview(puzzleGridView)
        addSubview(headerView)
        addSubview(instructionLabel)
        addSubview(hintView)

        puzzleGridView.snp.makeConstraints { make in
            make.width.equalTo(snp.height).multipliedBy(0.5)
            make.center.equalToSuperview()
            make.height.equalTo(puzzleGridView.snp.width)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(puzzleGridView)
            make.trailing.equalTo(puzzleGridView)
            make.height.equalTo(60)
        }

        instructionLabel.snp.makeConstraints { make in
            make.leading.equalTo(puzzleGridView.snp.leading)
            make.trailing.equalTo(puzzleGridView.snp.trailing)
            make.bottom.equalTo(puzzleGridView.snp.top)
        }

        setAndActivateCenteringView()
        setAndActivateHintViewConstraints()
    }

    private func setupGestureRecognizers() {
        setupPuzzlePiecesGestureRecognizers()
    }

    private func initialLayout(for puzzlePieceViews: [UIImageView]) {

    }
}

// MARK: - Layout constraints (Universal)
extension PlayView {
    private func setAndActivateHintViewConstraints() {
        NSLayoutConstraint.setAndActivate([
            hintView.topAnchor.constraint(equalTo: self.topAnchor, constant: -1),
            hintView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),
            hintView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -1),
            hintView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 1)
        ])
    }

    private func setAndActivateCenteringView() {
        NSLayoutConstraint.setAndActivate([
            centeringView.leftAnchor.constraint(equalTo: self.leftAnchor),
            centeringView.rightAnchor.constraint(equalTo: self.rightAnchor),
            centeringView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            centeringView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
    }
}


// MARK: - ContainerGridView delegate
extension PlayView: ContainerGridViewDelegate {
    func eyeViewTapped() {
        bringSubviewToFront(hintView)
        hintView.appearsTemporarily(for: 2)
    }
}

// MARK: - PuzzlePieces gesture recognizer logic
extension PlayView {
    private func setupPuzzlePiecesGestureRecognizers() {
        for puzzlePieceView in puzzlePieceViews {
            let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(movePuzzlePieceView))
            puzzlePieceView.addGestureRecognizer(panGestureRecognizer)
        }
    }

    @objc private func movePuzzlePieceView(_ gestureRecognizer: UIPanGestureRecognizer) {
        delegate?.handlePuzzleViewDrag(gestureRecognizer)
    }
}

// MARK: - ShareButton creation
extension PlayView {
    private func addSharePuzzleButton() {
        shareButton = UIButton(type: .custom)
        shareButton?.layer.cornerRadius = 5
        shareButton?.clipsToBounds = true
        shareButton?.backgroundColor = UIColor.main
        shareButton?.setTitleColor(.white, for: .normal)
        shareButton?.setTitle(Constant.String.shareButtonTitle, for: .normal)
        shareButton?.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        let centeringView = UIView()

        addSubview(centeringView)
        addSubview(shareButton!)

        bringPuzzleToFront()

    }

    @objc private func shareButtonTapped() {
        delegate?.handleShareButtonTapped()
    }

    private func bringPuzzleToFront() {
        bringSubviewToFront(puzzleGridView)
        for piece in puzzlePieceViews {
            bringSubviewToFront(piece)
        }
    }
}
