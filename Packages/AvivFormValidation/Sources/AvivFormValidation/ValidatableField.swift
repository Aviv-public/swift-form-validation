import Foundation

/// A representation of a Form field value, associated with its potential error value
public struct ValidatableField<Value> {
    public var value: Value
    public var errorText: String?

    /// Creates a ``ValidatableField``
    public init(value: Value, errorText: String? = nil) {
        self.value = value
        self.errorText = errorText
    }
}

extension ValidatableField: Equatable where Value: Equatable {}
extension ValidatableField: Sendable where Value: Sendable {}

extension ValidatableField:
    ExpressibleByStringLiteral,
    ExpressibleByExtendedGraphemeClusterLiteral,
    ExpressibleByUnicodeScalarLiteral where Value == String {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value: value)
    }
}
