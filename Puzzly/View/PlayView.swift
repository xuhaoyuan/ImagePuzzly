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

    var shareButton: UIButton?

    var puzzlePieceViews = [UIImageView]()
    var puzzlePieceViewConstraints = [Int: [NSLayoutConstraint]]()


    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    init(puzzlePieceViews: [UIImageView]) {
        self.puzzlePieceViews = puzzlePieceViews
        super.init(frame: .zero)
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

    private func addSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear

        headerView.backgroundColor = UIColor.clear

        addSubview(puzzleGridView)
        addSubview(headerView)

        puzzleGridView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(puzzleGridView.snp.width)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalTo(puzzleGridView)
            make.trailing.equalTo(puzzleGridView)
            make.height.equalTo(60)
        }

    }

    private func setupGestureRecognizers() {
        setupPuzzlePiecesGestureRecognizers()
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
