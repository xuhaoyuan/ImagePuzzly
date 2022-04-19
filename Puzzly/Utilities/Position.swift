//
//  Position.swift
//  Gridy
//
//  Created by Spencer Forrest on 09/04/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

enum Squares: CaseIterable {
    case s2
    case s3
    case s4
    case s5
    case s6
    static let gapLength = 1
    static let leading = 28
    static let trailing = 28

    var title: String {
        switch self {
        case .s2: return "2X2"
        case .s3: return "3X3"
        case .s4: return "4X4"
        case .s5: return "5X5"
        case .s6: return "6X6"
        }
    }

    private var rowCount: Int {
        switch self {
        case .s2: return 2
        case .s3: return 3
        case .s4: return 4
        case .s5: return 5
        case .s6: return 6
        }
    }

    func getSquares(size: CGSize = UIScreen.main.bounds.size) -> [CGRect] {
        let height: CGFloat = size.height
        let width: CGFloat = size.width
        let countInRow: CGFloat = CGFloat(rowCount)
        var numberSquares: Int = 0
        let gapLength: CGFloat = 1
        let allGaps: CGFloat = gapLength * (countInRow - 1)
        var length: CGFloat = (width * 0.9 - allGaps) / countInRow
        let allSquares: CGFloat = length * countInRow + allGaps
        length = ceil(length)
        let marginX: CGFloat = (width - allSquares) / 2
        let marginY: CGFloat = (height - allSquares) / 2

        var rectangles = [CGRect]()
        numberSquares = rowCount*rowCount
        var row: CGFloat = 0
        var column: CGFloat = 0

        for _ in 0..<numberSquares {
          let x: CGFloat = marginX + length * column + column * gapLength
          let y: CGFloat = marginY + length * row + row * gapLength
          let borderWidth: CGFloat = 0
          let square = CGRect(origin: .init(x: x - borderWidth , y: y - borderWidth),
                              size: CGSize(width: length + borderWidth, height: length + borderWidth))
          rectangles.append(square)

          if column == countInRow - 1 {
            column = 0
            row += 1
          } else {
            column += 1
          }
        }

        return rectangles
    }

    func getPreviewSquares(size: CGSize, line: CGFloat) -> [CGRect] {
        let height: CGFloat = size.height
        let width: CGFloat = size.width
        let countInRow: CGFloat = CGFloat(rowCount)
        var numberSquares: Int = 0
        let gapLength: CGFloat = line
        let allGaps: CGFloat = gapLength * (countInRow - 1)
        var length: CGFloat = (width - allGaps) / countInRow
        let allSquares: CGFloat = length * countInRow + allGaps
        length = ceil(length)
        let marginX: CGFloat = (width - allSquares) / 2
        let marginY: CGFloat = (height - allSquares) / 2

        var rectangles = [CGRect]()
        numberSquares = rowCount*rowCount
        var row: CGFloat = 0
        var column: CGFloat = 0

        for _ in 0..<numberSquares {
          let x: CGFloat = marginX + length * column + column * gapLength
          let y: CGFloat = marginY + length * row + row * gapLength
          let borderWidth: CGFloat = 0
          let square = CGRect(origin: .init(x: x - borderWidth , y: y - borderWidth),
                              size: CGSize(width: length + borderWidth, height: length + borderWidth))
          rectangles.append(square)

          if column == countInRow - 1 {
            column = 0
            row += 1
          } else {
            column += 1
          }
        }

        return rectangles
    }
}

