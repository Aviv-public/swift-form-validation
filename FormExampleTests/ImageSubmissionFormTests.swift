@testable import FormExample
import ComposableArchitecture
import SwiftUI
import PhotosUI
import XCTest

final class ImageSubmissionFormTests: XCTestCase {

    @MainActor
    func test_userSubmitsForm_withInitialState() async {
        let store = TestStore(
            initialState: ImageSubmissionForm.State(),
            reducer: ImageSubmissionForm.init
        )

        await store.send(.submitButtonTap) {
            $0.pictureName.errorText = "Picture's Name should not be empty"
            $0.selectedPictureError = "You need to select a picture to send"
        }
    }

    @MainActor
    func test_userSubmissionForm_withCorrectState() async {
        let store = TestStore(
            initialState: ImageSubmissionForm.State(),
            reducer: ImageSubmissionForm.init
        )
        store.exhaustivity = .off

        let pictureName = "Test picture"
        await store.send(.set(\.pictureName.value, pictureName)) {
            $0.pictureName.value = pictureName
        }

        let pickerItem = PhotosPickerItem(itemIdentifier: "test picture")
        await store.send(.set(\.selectedPicture, pickerItem)) {
            $0.image = .loading
            $0.selectedPicture = pickerItem
        }

        await store.send(.submitButtonTap)

        await store.receive(\.formValidationSucceed) {
            $0.alert = .formValidationSuccess
        }
    }
}
