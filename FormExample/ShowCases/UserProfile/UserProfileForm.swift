import FormValidation
import ComposableArchitecture
import Foundation

@Reducer
struct UserProfileForm {
    @ObservableState
    struct State: Equatable {
        var username: ValidatableField<String> = ""
        var age: ValidatableField<Int> = 18
        var agreeToSellSoul: ValidatableField<Bool> = false
        var userDescription: ValidatableField<String> = ""

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
                    rules: [
                        .nonEmpty(fieldName: "Username"),
                        .length(min: 5, error: "Username is too short")
                    ]
                ),
                FieldValidation(
                    field: \.age,
                    rules: [
                        .greaterOrEqual(to: 18, fieldName: "Age")
                    ]
                ),
                FieldValidation(
                    field: \.agreeToSellSoul,
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
