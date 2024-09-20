import ComposableArchitecture
import Foundation

/// Reducer to use whenever you want to add validation rules to some `BindableState`
///
/// ```swift
/// @Reducer
/// struct MyReducer {
///    struct State {
///        var name = ValidatableField(value: "")
///        var phone = ValidatableField(value: "")
///    }
///
///    enum Action {
///        enum ViewAction: BindableAction {
///            case binding(BindingAction<State>)
///            case didTapSubmitFormButton
///        }
///
///        case view(ViewAction)
///        case formValidationSucceed
///        ...
///    }
///
///    var body: some ReducerOf<Self> {
///        BindingReducer(action: \.view)
///
///        FormValidationReducer(
///            viewAction: \.view,
///            submitAction: .didTapSubmitFormButton,
///            onFormValidatedAction: .formValidationSucceed,
///            validations: [
///                 FieldValidation(
///                     field: \.name,
///                     rules: [
///                         // Some ValidationRule
///                     ]
///                 ),
///                 FieldValidation(
///                     field: \.age,
///                     rules: [
///                         // Some ValidationRule
///                     ]
///                 )
///            ]
///        )
///    }
/// }
/// ```
public struct FormValidationReducer<State, Action, ViewAction>: Reducer
where State == ViewAction.State, ViewAction: BindableAction {
    let toViewAction: (Action) -> ViewAction?
    let submitAction: CaseKeyPath<ViewAction, Void>
    let onFormValidatedAction: Action
    let validations: [FieldValidation<State>]

    /// Creates a ``FormValidationReducer``
    ///
    /// Use it to add validation rules to some `BindingState` members of your feature's State
    ///
    /// - Parameters:
    ///    - submitAction: The action to match against to trigger the whole form validation
    ///    - onFormValidatedAction: The action to be sent by the reducer when the validation
    ///    triggered by the `submitAction` succeed
    ///    - validations: The set of fields to validate by the reducer
    public init(
        submitAction: CaseKeyPath<ViewAction, Void>,
        onFormValidatedAction: Action,
        validations: [FieldValidation<State>]
    ) where Action == ViewAction {
        self.init(
            viewAction: { $0 },
            submitAction: submitAction,
            onFormValidatedAction: onFormValidatedAction,
            validations: validations
        )
    }

    /// Creates a ``FormValidationReducer``,
    /// given the `viewAction` when your feature's reducer has defined a `ViewAction`
    ///
    /// Use it to add validation rules to some `BindingState` members of your feature's State
    ///
    /// - Parameters:
    ///    - toViewAction: The `ViewAction` to extract the received action
    ///    - submitAction: The action to match against to trigger the whole form validation
    ///    - onFormValidatedAction: The action to be sent by the reducer
    ///    when the validation triggered by the `submitAction` succeed
    ///    - validations: The set of fields to validate by the reducer
    public init(
        viewAction toViewAction: @escaping (_ action: Action) -> ViewAction?,
        submitAction: CaseKeyPath<ViewAction, Void>,
        onFormValidatedAction: Action,
        validations: [FieldValidation<State>]
    ) {
        self.toViewAction = toViewAction
        self.submitAction = submitAction
        self.onFormValidatedAction = onFormValidatedAction
        self.validations = validations
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        if
            let viewAction = toViewAction(action),
            AnyCasePath(submitAction).extract(from: viewAction) != nil
        {
            let didSucceed = validateAllFields(state: &state)
            // On success validation
            return didSucceed ? .send(onFormValidatedAction) : .none
        }

        if let validation = getFirstValidation(for: action) {
            validation.validate(state: &state)
        }

        return .none
    }

    private func validateAllFields(state: inout State) -> Bool {
        // SwiftLint rule suggests tu use "allSatisfy",
        // but it actually changes the behavior as it will stop at first failing validation
        // swiftlint:disable:next reduce_boolean
        validations.reduce(true) { $1.validate(state: &state) && $0 }
    }

    private func getFirstValidation(for action: Action) -> FieldValidation<State>? {
        let binding = toViewAction(action).flatMap(\.binding)

        return validations.first(where: { $0.binding == binding?.keyPath })
    }
}

// MARK: - Initializer with CaseKeyPath argument

extension FormValidationReducer {
    /// - Parameters:
    ///    - toViewAction: The CaseKeyPath to `ViewAction` to extract the received action
    ///    - submitAction: The action to match against to trigger the whole form validation
    ///    - onFormValidatedAction: The action to be sent by the reducer
    ///    when the validation triggered by the `submitAction` succeed
    ///    - validations: The set of fields to validate by the reducer
    public init(
        viewAction toViewAction: CaseKeyPath<Action, ViewAction>,
        submitAction: CaseKeyPath<ViewAction, Void>,
        onFormValidatedAction: Action,
        validations: [FieldValidation<State>]
    ) where Action: CasePathable {
        self.init(
            viewAction: { $0[case: toViewAction] },
            submitAction: submitAction,
            onFormValidatedAction: onFormValidatedAction,
            validations: validations
        )
    }
}
