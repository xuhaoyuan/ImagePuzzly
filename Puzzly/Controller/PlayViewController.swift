//
//  PlayViewController.swift
//  Gridy
//
//  Created by Spencer Forrest on 05/04/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    var playView: PlayView!
    var imagesWithInitialPosition: [Image]!
    var hintImage: UIImage!

    private static var numberOftile: Int = { return 16 }()
    private var score = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        playView = PlayView(hintImage: hintImage, puzzlePieceViews: makeRandomOrderImageViews())
        playView.delegate = self
        playView.headerView.delegate = self
        playView.backgroundColor = UIColor.white
        view.addSubview(playView)
        playView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


    private func makeRandomOrderImageViews() -> [UIImageView] {
        var array = [UIImageView]()
        for (index, item) in imagesWithInitialPosition.enumerated() {
            let imageView = UIImageView(image: item.image)
            imageView.tag = index
            array.append(imageView)
        }
        array = array.sorted { _,_  in
            arc4random() < arc4random()
        }
        return array
    }
}

extension PlayViewController: PlayViewDelegate {

    func handleShareButtonTapped() {
        let text = "My score is \(score)"
        let items = [
            hintImage as Any,
            text
        ]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }

    func handlePuzzleViewDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let puzzlePieceView = gestureRecognizer.view as? UIImageView else { return }

        playView.bringSubviewToFront(puzzlePieceView)
        switch gestureRecognizer.state {
        case .changed:
            let translation = gestureRecognizer.translation(in: playView)
            puzzlePieceView.center = CGPoint(x: puzzlePieceView.center.x + translation.x,
                                             y: puzzlePieceView.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: playView)
        case .ended, .cancelled:
            if playView.puzzleGridView.frame.contains(puzzlePieceView.center) {
                placeInsidePuzzleGridViewIfPossible(puzzlePieceView)
            } else {
                guard let (_, originTile) = playView.puzzleGridView.getTile(from: puzzlePieceView) else { return }
                playView.place(puzzlePieceView, inside: originTile)
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                } completion: { _ in

                }
            }
        default:
            break
        }
    }

    private func placeInsidePuzzleGridViewIfPossible(_ puzzlePieceView: UIImageView) {
        let center = playView.convertCenterPointCoordinateSystem(of: puzzlePieceView, to: playView.puzzleGridView)
        guard let (_, originTile) = playView.puzzleGridView.getTile(from: puzzlePieceView) else { return }
        if let newPosition = playView.puzzleGridView.findTilePositionContaining(center),
           let newTile = playView.puzzleGridView.getTile(from: newPosition) {
            playView.place(newTile.imageView, inside: originTile)
            playView.place(puzzlePieceView, inside: newTile)
        } else {
            playView.place(puzzlePieceView, inside: originTile)
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.updateScore()
            guard self.playView.puzzleGridView.checkSuccess() else { return }
            self.presentWinningAlert()
        }
    }

    private func updateScore() {
        score += 1
        playView.headerView.scoreLabel.text = "\(score)"
    }

    private func presentWinningAlert() {
        let title = score == PlayViewController.numberOftile ? "Perfect Score" : "Congratulation"
        let message = "Puzzle completed.\nYou cannot move the pieces or see the hint anymore."
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Delegation to handle New Game Button tap
extension PlayViewController: HeaderViewDelegate {

    func newGameButtonTapped() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
