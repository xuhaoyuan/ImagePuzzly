//
//  HintView.swift
//  Gridy
//
//  Created by Spencer Forrest on 08/06/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class HintView: UIVisualEffectView {

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(image: UIImage) {
        super.init(effect: UIBlurEffect(style: .regular))

        let imageView: UIImageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        isUserInteractionEnabled = false
        alpha = 0
    }

    func appearsTemporarily(for delay: TimeInterval) {
        guard let superView = self.superview else { return }
        superView.bringSubviewToFront(self)
        self.isUserInteractionEnabled = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 1
        })
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut) { [weak self] in
            self?.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            superView.sendSubviewToBack(self)
        }
    }
}
