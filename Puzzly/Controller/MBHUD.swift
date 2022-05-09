//
//  MBHUD.swift
//  Puzzly
//
//  Created by 许浩渊 on 2022/5/9.
//  Copyright © 2022 Spencer Forrest. All rights reserved.
//

import UIKit
import MBProgressHUD

extension MBProgressHUD {

    static func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        MBProgressHUD.showAdded(to: keyWindow, animated: true)
    }

    static func hide() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        MBProgressHUD.hide(for: keyWindow, animated: true)
    }
}
