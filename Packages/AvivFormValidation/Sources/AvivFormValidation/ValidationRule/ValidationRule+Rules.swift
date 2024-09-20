import Foundation

public extension ValidationRule {
    static func nonEmpty(fieldName: String) -> Self where Value: Collection {
        .init(
            error: "\(fieldName.capitalized) should not be empty",
            validation: { !$0.isEmpty }
        )
    }

    static func length(min: UInt, error: String) -> Self where Value: Collection {
        .init(error: error, validation: { $0.count >= min })
    }

    static func greaterOrEqual(to value: Value, fieldName: String) -> Self where Value: Comparable {
        .init(
            error: "\(fieldName.capitalized) should be greater or equal to \(value)",
            validation: { $0 >= value }
        )
    }

    static func isEqual(to value: Value, fieldName: String) -> Self where Value: Equatable {
        .isEqual(to: value, errorMessage: "\(fieldName.capitalized) should be \(value)")
    }

    static func isEqual(to value: Value, errorMessage: String) -> Self where Value: Equatable {
        .init(error: errorMessage, validation: { $0 == value })
    }

    static func nonOptional<T>(_ errorMessage: String) -> Self where Value == Optional<T> {
        .init(error: errorMessage, validation: { $0 != nil })
    }
}
