import Foundation

public struct ValidationRule<Value> {
    let errorMessage: String
    let validation: (Value) -> Bool

    /// Creates a ``ValidationRule``
    /// - Parameter definition: optional definition of that rule
    /// - Parameter validate: closure used to validate the value by returning a ``Bool``
    public init(
        error: String,
        validation: @escaping (Value) -> Bool
    ) {
        self.errorMessage = error
        self.validation = validation
    }

    func validate(_ value: Value) -> Bool {
        validation(value)
    }
}

public extension Collection {
    /// Triggers the validation of all ``ValidationRule``.
    func validate<Value>(_ value: Value) -> String? where Element == ValidationRule<Value> {

        for rule in self {
            if rule.validate(value) == false {
                return rule.errorMessage
            }
        }

        return nil
    }
}
