import AvivFormValidation
import ComposableArchitecture
import Foundation

@Reducer
struct NoValidatableFieldForm {
    @ObservableState
    struct State {
        var username: String = ""
        var age: Int = 18
        var agreeToSellSoul: Bool = false
        var userDescription: String = ""

        var usernameError: String?
        var ageError: String?
        var agreeToSellSoulError: String?
        var userDescriptionError: String?
    }

    enum Action: BindableAction {
        case registerButtonTap
        case formValidationSucceed
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        FormValidationReducer(
            submitAction: \.registerButtonTap,
            onFormValidatedAction: .formValidationSucceed,
            validations: [
                FieldValidation(
                    field: \.username,
                    errorState: \.usernameError,
                    rules: [
                        .nonEmpty(fieldName: "Username")
                    ]
                ),
                FieldValidation(
                    field: \.age,
                    errorState: \.ageError,
                    rules: [
                        .greaterOrEqual(to: 18, fieldName: "Age")
                    ]
                ),
                FieldValidation(
                    field: \.agreeToSellSoul,
                    errorState: \.agreeToSellSoulError,
                    rules: [
                        .isEqual(to: true, errorMessage: "We need this, for your... safety!")
                    ]
                )
            ]
        )

        Reduce { state, action in
            switch action {
            case .registerButtonTap:
                return .none

            case .formValidationSucceed:
                // show alert
                return .none

            case .binding:
                return .none
            }
        }
    }
}
