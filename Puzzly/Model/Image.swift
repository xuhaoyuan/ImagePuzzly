import UIKit

/// Represent a UIImage and its original position
class Image {
  private(set) var image: UIImage
  private(set) var id: Int
  
  init(image: UIImage, id: Int) {
    self.image = image
    self.id = id
  }
}
