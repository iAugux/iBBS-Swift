import UIKit

extension UIColor {
    public convenience init(hex: String) {
        let noHasString = hex.stringByReplacingOccurrencesOfString(
            "#",
            withString: "")
        let scanner = NSScanner(string: noHasString)
        scanner.charactersToBeSkipped = NSCharacterSet.symbolCharacterSet()

        var hexInt: UInt32 = 0
        if (scanner.scanHexInt(&hexInt)) {
            let red = (hexInt >> 16) & 0xFF
            let green = (hexInt >> 8) & 0xFF
            let blue = (hexInt) & 0xFF

            self.init(
                red: CGFloat(red) / 255.0,
                green: CGFloat(green) / 255.0,
                blue: CGFloat(blue) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 0.0)
        }
    }
}
