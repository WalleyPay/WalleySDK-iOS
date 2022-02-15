import Foundation

public struct AnyEncodable: Encodable {
    
    let value: Encodable
    
    public init(_ value: Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
}

extension AnyEncodable: ExpressibleByStringInterpolation {
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
}

extension AnyEncodable: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
    
}

extension AnyEncodable: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(
            elements
                .reduce(into: [:]) {
                    $0[$1.0] = $1.1 as? Encodable
                }
                .mapValues {
                    AnyEncodable($0)
                }
        )
    }
    
}

extension AnyEncodable: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
    
}

extension AnyEncodable: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: AnyEncodable...) {
        self.init(elements)
    }
    
}

extension AnyEncodable: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
    
}
