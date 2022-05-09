//
//  PlayViewController.swift
//  Gridy
//
//  Created by Spencer Forrest on 05/04/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    private lazy var playView: PlayView = {
        let view = PlayView(pieceImages: clipImages)
        view.delegate = self
        return view
    }()
    private lazy var leftItem: UIBarButtonItem = {
        var icon = UIBarButtonItem.SystemItem.cancel
        if #available(iOS 13.0, *) {
            icon = UIBarButtonItem.SystemItem.close
        }
        return UIBarButtonItem(barButtonSystemItem: icon, target: self, action: #selector(quitButtonTouched))
    }()

    private lazy var rightItem: UIBarButtonItem = {
        var icon = UIBarButtonItem.SystemItem.pause
        return UIBarButtonItem(barButtonSystemItem: icon, target: self, action: #selector(preview))
    }()

    private lazy var hintView: HintView = HintView(image: hintImage)
    private let clipImages: [UIImage]
    private let hintImage: UIImage
    private let originImage: UIImage
    private lazy var backgroundImage = UIImageView(image: originImage)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    private static var numberOftile: Int = 16
    private var score = 0
    private let square: Squares

    init(square: Squares, originImage: UIImage, hintImage: UIImage, clipImages: [UIImage]) {
        self.clipImages = clipImages
        self.hintImage = hintImage
        self.originImage = originImage
        self.square = square
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButton(leftItem, animated: false)
        navigationItem.setRightBarButton(rightItem, animated: false)
        navigationController?.navigationBar.tintColor = UIColor.black
        view.backgroundColor = UIColor.white
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(hintView)
        hintView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(backgroundImage)
        view.addSubview(blurView)
        blurView.contentView.addSubview(playView)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func quitButtonTouched() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func preview() {
        hintView.appearsTemporarily(for: 2)
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
        navigationItem.title = "\(score)"
    }

    private func presentWinningAlert() {
        let title = score == "🎉"
        let message = "拼图完成！"
        let action = UIAlertAction(title: "好", style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
