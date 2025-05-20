import FormValidation
import ComposableArchitecture
import Foundation

@Reducer
struct NoValidatableFieldForm {
    @ObservableState
    struct State: Equatable {
        var username: String = ""
        var age: Int = 18
        var agreeToSellSoul: Bool = false
        var userDescription: String = ""

        var usernameError: String?
        var ageError: String?
        var agreeToSellSoulError: String?
        var userDescriptionError: String?

        @Presents var alert: AlertState<Never>?
    }

    enum Action: BindableAction {
        case registerButtonTap
        case formValidationSucceed
        case binding(BindingAction<State>)
        case alert(PresentationAction<Never>)
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
                state.alert = .formValidationSuccess
                return .none

            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
