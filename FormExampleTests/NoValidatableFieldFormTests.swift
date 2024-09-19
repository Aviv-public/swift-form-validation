@testable import FormExample
import ComposableArchitecture
import XCTest

final class NoValidatableFieldFormTests: XCTestCase {

    @MainActor
    func test_userSubmitsForm_withInitialState() async {
        let store = TestStore(
            initialState: NoValidatableFieldForm.State(),
            reducer: NoValidatableFieldForm.init
        )

        await store.send(.registerButtonTap) {
            $0.usernameError = "Username should not be empty"
            $0.agreeToSellSoulError = "We need this, for your... safety!"
        }
    }

    @MainActor
    func test_userSubmitsForm_withCorrectInputs() async {
        let store = TestStore(
            initialState: NoValidatableFieldForm.State(),
            reducer: NoValidatableFieldForm.init
        )

        await store.send(.set(\.username, "TestUser")) {
            $0.username = "TestUser"
        }

        await store.send(.set(\.agreeToSellSoul, true)) {
            $0.agreeToSellSoul = true
        }

        await store.send(.registerButtonTap)

        await store.receive(\.formValidationSucceed) {
            $0.alert = .formValidationSuccess
        }
    }
}
