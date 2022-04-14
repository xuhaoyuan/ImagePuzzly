import UIKit

extension UIColor {

    public convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }

    public convenience init?(hexString: String, alpha: Float) {
        var hex = hexString.uppercased()
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        guard let hexVal = Int(hex, radix: 16) else {
            return nil
        }
        self.init(hex6: hexVal, alpha: alpha)
    }

    private convenience init?(hex6: Int, alpha: Float) {
        self.init(red: CGFloat( (hex6 & 0xFF0000) >> 16 ) / 255.0,
                  green: CGFloat( (hex6 & 0x00FF00) >> 8 ) / 255.0,
                  blue: CGFloat( (hex6 & 0x0000FF) >> 0 ) / 255.0,
                  alpha: CGFloat(alpha)
        )
    }

    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        let red = r / 255.0
        let green = g / 255.0
        let blue = b / 255.0
        self.init(red: red, green: green, blue: blue, alpha: a)
    }
}
