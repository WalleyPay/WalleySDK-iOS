import Foundation

public struct WalleyError: Error, Decodable {
    let code: Int
    let message: String
    let errors: [ErrorMessage]
}

extension WalleyError: LocalizedError {
    
    public var errorDescription: String? {
        "WalleyError code \(code): \(message)\n\(errors.map { $0.message }.joined(separator: "\n"))"
    }
    
    public var failureReason: String? {
        errors.map { $0.reason }.joined(separator: ", ")
    }
    
}

public struct ErrorMessage: Decodable {
    let reason: String
    let message: String
}
