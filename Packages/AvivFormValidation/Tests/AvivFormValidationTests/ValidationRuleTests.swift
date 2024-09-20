import AvivFormValidation
import XCTest

final class ValidationRuleTests: XCTestCase {

    func test_validationSucceed_shouldReturnTrue() {
        let rule = ValidationRule<String>.allwaysTrue()

        XCTAssertTrue(rule.validate("something"))
    }

    func test_validationFailing_shouldReturnFalse() {
        let rule = ValidationRule<String>.allwaysFalse(withID: "1")

        XCTAssertFalse(rule.validate("something"))
    }

    func test_validateMultipleRules_when_allSucceed() {
        let rules: [ValidationRule<String>] = [
            .allwaysTrue(),
            .allwaysTrue(),
            .allwaysTrue()
        ]

        XCTAssertEqual(rules.validate("something"), nil)
    }

    func test_validateMultipleRules_should_stopAtFirstFailingAndReturnItsErrorMessage() {
        let rules: [ValidationRule<String>] = [
            .allwaysTrue(),
            .allwaysFalse(withID: "1"),
            .allwaysFalse(withID: "2")
        ]

        XCTAssertEqual(rules.validate("something"), "Test validation 1")
    }
}

extension ValidationRule where Value == String {
    static func allwaysTrue() -> Self {
        Self.init(error: "", validation: { _ in true })
    }

    static func allwaysFalse(withID id: String) -> Self {
        Self.init(error: "Test validation \(id)", validation: { _ in false })
    }
}
