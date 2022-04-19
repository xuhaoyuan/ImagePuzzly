//
//  PreviewImageView.swift
//  Puzzly
//
//  Created by 许浩渊 on 2022/4/19.
//  Copyright © 2022 Spencer Forrest. All rights reserved.
//

import UIKit

class PreviewImageView: UIImageView {

    private let maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        return maskLayer
    }()

    override init(image: UIImage?) {
        super.init(image: image)
        self.backgroundColor = UIColor.clear
        self.layer.mask = maskLayer
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let lineScale: CGFloat = 6.0/512.0 * bounds.width
        let rects = Squares.s3.getPreviewSquares(size: self.bounds.size, line: lineScale)
        let path = CGMutablePath()
//        path.addRect(CGRect(origin: .zero, size: bounds.size))
        for square in rects {
            path.addRect(square)
        }
        maskLayer.path = path

        layer.cornerRadius = 90.0/512*bounds.width
    }
}
