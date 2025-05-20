import ComposableArchitecture
import XCTest
@testable import FormValidation

final class FormValidationTests: XCTestCase {

    @MainActor
    func test_validationFormReducer() async {
        let store = TestStore(
            initialState: TestReducer.State(),
            reducer: TestReducer.init
        )

        // Submit without modifying form should fail
        // because fields don't match requirements
        await store.send(.submitForm) {
            $0.stringFieldError = "Min length error"
            $0.intFieldError = "Intfield should be greater or equal to 18"
        }

        // Update fields to match requirements
        await store.send(.set(\.stringField, "something")) {
            $0.stringField = "something"
            $0.stringFieldError = "Stringfield should be Test1"
        }

        await store.send(.set(\.stringField, "Test1")) {
            $0.stringField = "Test1"
            $0.stringFieldError = nil
        }

        await store.send(.set(\.intField, 21)) {
            $0.intField = 21
            $0.intFieldError = nil
        }

        // Submit form again, it should succeed
        await store.send(.submitForm)

        await store.receive(\.formValidationSucceed)
    }

    @Reducer
    struct TestReducer {
        @ObservableState
        struct State: Equatable {
            var stringField = ""
            var intField = 0

            var stringFieldError: String?
            var intFieldError: String?
        }

        enum Action: BindableAction {
            case binding(BindingAction<State>)
            case submitForm
            case formValidationSucceed
        }

        var body: some ReducerOf<Self> {
            BindingReducer()

            FormValidationReducer(
                submitAction: \.submitForm,
                onFormValidatedAction: .formValidationSucceed,
                validations: [
                    FieldValidation(
                        field: \.stringField,
                        errorState: \.stringFieldError,
                        rules: [
                            .length(min: 5, error: "Min length error"),
                            .isEqual(to: "Test1", fieldName: "stringField")
                        ]
                    ),
                    FieldValidation(
                        field: \.intField,
                        errorState: \.intFieldError,
                        rules: [
                            .greaterOrEqual(to: 18, fieldName: "intField")
                        ]
                    )
                ]
            )
        }
    }
}
