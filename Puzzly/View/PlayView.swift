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
}

class PlayView: UIView {

    weak var delegate: PlayViewDelegate?

    lazy var puzzleGridView = PuzzleGridView(images: puzzlePieceViews)

    // var headerView = HeaderView()

    var puzzlePieceViews = [UIImageView]()
    var puzzlePieceViewConstraints = [Int: [NSLayoutConstraint]]()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    init(pieceImages: [UIImage]) {
        self.puzzlePieceViews = PlayView.makeRandomOrderImageViews(images: pieceImages)
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

    private static func makeRandomOrderImageViews(images: [UIImage]) -> [UIImageView] {
        var array = [UIImageView]()
        for (index, item) in images.enumerated() {
            let imageView = UIImageView(image: item)
            imageView.tag = index
            array.append(imageView)
        }
        array = array.sorted { _,_  in
            arc4random() < arc4random()
        }
        return array
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

        addSubview(puzzleGridView)

        puzzleGridView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(puzzleGridView.snp.width)
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
