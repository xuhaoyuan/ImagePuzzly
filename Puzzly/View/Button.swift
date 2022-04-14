//
//  Button.swift
//  Gridy
//
//  Created by Spencer Forrest on 28/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class Button: UIButton {

    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    init(imageName: String, forIpad: Bool = false) {
        super.init(frame: .zero)

        let image = UIImage.init(named: imageName)
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = Constant.Layout.cornerRadius.introButton
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
        self.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        self.backgroundColor = UIColor.secondary
    }
}
