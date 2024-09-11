import AvivFormValidation
import ComposableArchitecture
import Foundation

@Reducer
struct UserProfileForm {
    @ObservableState
    struct State {
        var username: ValidatableField<String> = ""
        var age: ValidatableField<Int> = 18
        var agreeToSellSoul: ValidatableField<Bool> = false
        var userDescription: ValidatableField<String> = ""
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
                    rules: [
                        ValidationRule(
                            error: "Username should not be empy",
                            validation: {
                                !$0.isEmpty
                            }
                        )
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
