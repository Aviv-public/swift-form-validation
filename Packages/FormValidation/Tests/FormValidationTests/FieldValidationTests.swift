import FormValidation
import XCTest

final class FieldValidationTests: XCTestCase {

    func test_fieldValidation_withSuccessfulValidation_shouldSetNilToError() {
        var state = TestState(valueError: "Initial error")
        let fieldValidation = FieldValidation(
            field: \TestState.value,
            errorState: \TestState.valueError,
            rules: [
                .allwaysTrue(),
                .allwaysTrue()
            ]
        )

        XCTAssertTrue(
            fieldValidation.validate(state: &state),
            "Expect field validation to succeed"
        )
        XCTAssertNil(
            state.valueError,
            "Expect error to be set back to nil"
        )
    }

    func test_fieldValidation_withFailingValidation_shouldSetFirstFailingRuleError() {
        var state = TestState(valueError: "Initial error")
        let fieldValidation = FieldValidation(
            field: \TestState.value,
            errorState: \TestState.valueError,
            rules: [
                .allwaysTrue(),
                .allwaysFalse(withID: "1"),
                .allwaysFalse(withID: "2")
            ]
        )

        XCTAssertFalse(
            fieldValidation.validate(state: &state),
            "Expect field validation to fail"
        )
        XCTAssertEqual(
            state.valueError,
            "Test validation 1",
            "Expect error to be set to first failing rule's error"
        )
    }

    struct TestState {
        var value: String = ""
        var valueError: String?
    }
}
