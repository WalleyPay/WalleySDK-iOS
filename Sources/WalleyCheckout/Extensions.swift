import Foundation
import UIKit

extension UIDevice {
    
    var model: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        let model = modelCode.map { String(validatingUTF8: $0) }
        return model ?? nil
    }
    
}

extension UIView {
    
    var parentViewController: UIViewController? {
        var responder = next
        while responder != nil && !(responder is UIViewController) {
            responder = responder?.next
        }
        return responder as? UIViewController
    }
    
}
