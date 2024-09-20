import ComposableArchitecture
import Foundation

/// A value that makes the link between a `BindingState` and a set of ``ValidationRule`` to validate against.
/// To be used in conjunction to ``FormValidationReducer``
public struct FieldValidation<State> {
    // Used by FormValidationReducer
    let binding: PartialKeyPath<State>

    private let _validate: (inout State) -> Bool

    /// Creates a ``FieldValidation``
    ///
    /// - Parameters:
    ///   - binding: Keypath to the binding to match against for "on the fly" validation
    ///   - field: Keypath to the actual value to match against for validation
    ///   - errorState: Keypath to the piece of State that should hold the error in case of failed validation
    ///   - rules: The set of ``ValidationRule`` to validate the field
    ///
    private init<FieldType>(
        binding: PartialKeyPath<State>,
        field: KeyPath<State, FieldType>,
        errorState: WritableKeyPath<State, String?>,
        rules: [ValidationRule<FieldType>]
    ) {
        self.binding = binding

        self._validate = { state in
            let value = state[keyPath: field]
            let validationError = rules.validate(value)

            state[keyPath: errorState] = validationError

            return validationError == nil
        }
    }

    @discardableResult
    public func validate(state: inout State) -> Bool {
        _validate(&state)
    }
}

public extension FieldValidation {
    /// Creates a ``FieldValidation``
    ///
    /// - Parameters:
    ///   - field: Keypath to the binding to match against for "on the fly" validation
    ///   - errorState: Keypath to the piece of State that should hold the error in case of failed validation
    ///   - rules: The set of ``ValidationRule`` to validate the field
    ///
    ///   ```swift
    ///   FieldValidate(
    ///       field: \.$name,
    ///       errorState: \.nameError,
    ///       rules: [ValidationRule(...), ValidationRule(...), ...]
    ///   )
    ///   ```
    ///
    init<Value>(
        field: WritableKeyPath<State, Value>,
        errorState: WritableKeyPath<State, String?>,
        rules: [ValidationRule<Value>]
    ) {
        self.init(
            binding: field,
            field: field,
            errorState: errorState,
            rules: rules
        )
    }

    /// Creates a ``FieldValidation`` from a `BindingState` of ``ValidatableField``
    ///
    /// - Parameters:
    ///   - field: Keypath to the binding of ``ValidatableField`` to match against for "on the fly" validation
    ///   - rules: The set of ``ValidationRule`` to validate the field
    ///ValidatableField
    ///   ```swift
    ///   FieldValidate(
    ///       field: \.$name,
    ///       rules: [ValidationRule(...), ValidationRule(...), ...]
    ///   )
    ///   ```
    ///
    init<Value>(
        field: WritableKeyPath<State, ValidatableField<Value>>,
        rules: [ValidationRule<Value>]
    ) {
        self.init(
            binding: field,
            field: field.appending(path: \.value),
            errorState: field.appending(path: \.errorText),
            rules: rules
        )
    }
}
