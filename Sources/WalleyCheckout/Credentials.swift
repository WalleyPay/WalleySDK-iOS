import Foundation
import CommonCrypto

public struct Credentials {
    
    /// The username for the merchant
    let username: String
    
    /// The shared access key
    let accessKey: String
    
    public init(username: String, accessKey: String) {
        self.username = username
        self.accessKey = accessKey
    }
    
    func generateKey(jsonBody: String, path: String) -> String {
        "\(username):\((jsonBody + path + accessKey).sha256())".base64()
    }
}

extension Data {
    
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
    
    var hexString: String {
        reduce("", { $0 + String(format:"%02x", UInt8($1)) })
    }
    
}

extension String {
    
    func sha256() -> String {
        guard let data = data(using: .utf8) else { return "" }
        return data.sha256().hexString
    }
    
    func base64() -> String {
        data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
}
