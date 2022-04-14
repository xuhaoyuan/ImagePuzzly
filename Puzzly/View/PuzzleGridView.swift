//
//  PuzzleGridView.swift
//  Gridy
//
//  Created by Spencer Forrest on 10/05/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import RxCocoa

class TilesView: UIView {

    var imageView: UIImageView

    init(imageView: UIImageView) {
        self.imageView = imageView
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PuzzleGridView: UIView {
    
    private var tiles = [TilesView]()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    init(images: [UIImageView]) {
        super.init(frame: .zero)
        backgroundColor = UIColor.secondary
        initializeAndSetTiles(images: images)
    }

    func checkSuccess() -> Bool {
        return !tiles.contains { $0.imageView.tag != $0.tag }
    }

    func findTilePositionContaining(_ point: CGPoint) -> Int? {
        for result in tiles.enumerated() where result.element.frame.contains(point) {
            return result.offset
        }
        return nil
    }

    func getTile(from image: UIImageView) -> (Int, TilesView)? {
        return tiles.enumerated().first { $0.element.imageView == image }
    }

    func getTile(from position: Int) -> TilesView? {
        guard position < tiles.count else { return nil }
        return tiles[position]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let boundSize = min(bounds.width, bounds.height)
        let tileMargin: CGFloat = 2
        let tilesPerRow = 4
        let tilesPerColumn = 4

        let totalMarginPerRow = tileMargin * CGFloat(tilesPerRow) + tileMargin

        let tileWidth = (boundSize - totalMarginPerRow) / CGFloat(tilesPerRow)
        let tileHeight = tileWidth

        var index = 0
        for row in 0...tilesPerRow - 1 {

            for column in 0...tilesPerColumn - 1 {

                let tile = tiles[index]

                let row = CGFloat(row)
                let column = CGFloat(column)

                let xPosition = column * tileWidth + CGFloat(tileMargin) * column + tileMargin
                let yPosition = row * tileHeight + CGFloat(tileMargin) * row + tileMargin

                tile.frame = CGRect(x: xPosition,
                                    y: yPosition,
                                    width: tileWidth,
                                    height: tileHeight)
                index += 1
            }
        }
    }

    private func initializeAndSetTiles(images: [UIImageView]) {
        for (index, item) in images.enumerated() {
            let tile = TilesView(imageView: item)
            tile.tag = index
            tile.backgroundColor = UIColor.white
            tiles.append(tile)
            addSubview(tile)
        }
    }
}
