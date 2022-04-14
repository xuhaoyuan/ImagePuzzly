  //
//  IntroView.swift
//  Gridy
//
//  Created by Spencer Forrest on 18/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit


/// Use of delegate pattern
protocol IntroViewDelegate: AnyObject {
  /// Called when the randomButton has been touched up inside
  func randomButtonTouched()
  /// Called when the cameraButton has been touched up inside
  func cameraButtonTouched()
  /// Called when the photosButton has been touched up inside
  func photosButtonTouched()
}

/// This is the main View that will be setup in the IntroViewComtroller
class IntroView: UIView {
  
  required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
  

}
