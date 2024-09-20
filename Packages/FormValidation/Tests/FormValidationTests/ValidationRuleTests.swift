import FormValidation
import XCTest

final class ValidationRuleTests: XCTestCase {

    // MARK: - Rule validation
    func test_validationSucceed_shouldReturnTrue() {
        let rule = ValidationRule<String>.allwaysTrue()

        XCTAssertTrue(rule.validate("something"))
    }

    func test_validationFailing_shouldReturnFalse() {
        let rule = ValidationRule<String>.allwaysFalse(withID: "1")

        XCTAssertFalse(rule.validate("something"))
    }

    // MARK: - List of Rules validation
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

    // MARK: - Rule extensions validation
    // MARK: NonEmpty
    func test_nonEmpty_withNonEmptyCollection_shouldSucceed() {
        assertSuccess(for: .nonEmpty(fieldName: "Test"), with: "something")
        assertSuccess(for: .nonEmpty(fieldName: "Test"), with: [1])
        assertSuccess(for: .nonEmpty(fieldName: "Test"), with: Set([1]))
        assertSuccess(for: .nonEmpty(fieldName: "Test"), with: ["something" : 1])
    }

    func test_nonEmpty_withEmptyCollection_shouldFail() {
        assertFailure(for: .nonEmpty(fieldName: "Test"), with: "")
        assertFailure(for: .nonEmpty(fieldName: "Test"), with: [])
        assertFailure(for: .nonEmpty(fieldName: "Test"), with: Set<Int>())
        assertFailure(for: .nonEmpty(fieldName: "Test"), with: [:])
    }

    // MARK: Length
    func test_length_whenColectionHasRequiredNumberOfElements_shouldSucceed() {
        let rule: ValidationRule<String> = .length(min: 5, error: "Test validation")

        assertSuccess(for: rule, with: "somet")
        assertSuccess(for: rule, with: "something")
    }

    func test_length_whenColectionHasLessElementsThanNeeded_shouldFail() {
        let rule: ValidationRule<String> = .length(min: 5, error: "Test validation")

        assertFailure(for: rule, with: "")
        assertFailure(for: rule, with: "some")
    }

    // MARK: GreaterOrEqual
    func test_greaterOrEqual_withEqualOrGreaterValue_shouldSucceed() {
        let rule: ValidationRule<Int> = .greaterOrEqual(to: 10, fieldName: "Test")

        assertSuccess(for: rule, with: 10)
        assertSuccess(for: rule, with: 11)
    }

    func test_greaterOrEqual_withSmallerValue_shouldFail() {
        let rule: ValidationRule<Int> = .greaterOrEqual(to: 10, fieldName: "Test")

        assertFailure(for: rule, with: 0)
    }

    // MARK: IsEqual
    func test_isEqual_withEqualValue_shouldSucceed() {
        let rule: ValidationRule<Int> = .isEqual(to: 10, fieldName: "Test")

        assertSuccess(for: rule, with: 10)
    }

    func test_isEqual_withDifferentValue_shouldFail() {
        let rule: ValidationRule<Int> = .isEqual(to: 10, fieldName: "Test")

        assertFailure(for: rule, with: 9)
        assertFailure(for: rule, with: 11)
    }

    // MARK: NonOptional
    func test_nonOptional_withValue_shouldSucceed() {
        let rule: ValidationRule<Int?> = .nonOptional("Test")

        assertSuccess(for: rule, with: 10)
    }

    func test_nonOptional_withNoValue_shouldFail() {
        let rule: ValidationRule<Int?> = .nonOptional("Test")

        assertFailure(for: rule, with: nil)
    }

    // MARK: - Private helpers
    private func assertFailure<Value>(for rule: ValidationRule<Value>, with value: Value) {
        XCTAssertFalse(
            rule.validate(value),
            "Rule succeeded while it was expected to fail with value: \(value)"
        )
    }

    private func assertSuccess<Value>(for rule: ValidationRule<Value>, with value: Value) {
        XCTAssertTrue(
            rule.validate(value),
            "Rule failed while it was expected to succeed with value: \(value)"
        )
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
