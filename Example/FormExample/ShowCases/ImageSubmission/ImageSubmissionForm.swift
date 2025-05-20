//
//  ImageSubmissionForm.swift
//  FormExample
//
//  Created by Anthony MERLE on 13/09/2024.
//

import FormValidation
import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI

@Reducer
struct ImageSubmissionForm {
    @ObservableState
    struct State: Equatable {
        enum ImageFetching: Equatable {
            case image(Image)
            case loading
        }

        var pictureName: ValidatableField<String> = ""
        var selectedPicture: PhotosPickerItem?
        var selectedPictureError: String?
        var image: ImageFetching?

        @Presents var alert: AlertState<Never>?
    }

    enum Action: BindableAction {
        case alert(PresentationAction<Never>)
        case binding(BindingAction<State>)
        case didLoadImage(Image)
        case didFailToLoadImage
        case submitButtonTap
        case formValidationSucceed
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        FormValidationReducer(
            submitAction: \.submitButtonTap,
            onFormValidatedAction: .formValidationSucceed,
            validations: [
                FieldValidation(
                    field: \.pictureName,
                    rules: [
                        .nonEmpty(fieldName: "Picture's name")
                    ]
                ),
                FieldValidation(
                    field: \.selectedPicture,
                    errorState: \.selectedPictureError,
                    rules: [
                        .nonOptional("You need to select a picture to send")
                    ]
                )
            ]
        )
        Reduce { state, action in
            switch action {
            case .binding(\.selectedPicture):
                guard let selectedPicture = state.selectedPicture else {
                    return .none
                }

                state.image = .loading
                return loadImage(for: selectedPicture)

            case let .didLoadImage(image):
                state.image = .image(image)
                return .none

            case .didFailToLoadImage:
                state.selectedPictureError = "Something went wrong loading the selected image"
                return .none

            case .formValidationSucceed:
                state.alert = .formValidationSuccess
                return .none

            case .binding, .submitButtonTap, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func loadImage(for selectedPicture: PhotosPickerItem) -> Effect<Action> {
        .run { [selectedPicture] send in
            guard let image = try await selectedPicture
                .loadTransferable(type: Image.self) else {
                await send(.didFailToLoadImage)
                return
            }

            await send(.didLoadImage(image))
        } catch: { error, send in
            await send(.didFailToLoadImage)
        }
    }
}
