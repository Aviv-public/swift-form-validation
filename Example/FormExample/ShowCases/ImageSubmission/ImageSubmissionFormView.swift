//
//  ImageSubmissionFormView.swift
//  FormExample
//
//  Created by Anthony MERLE on 13/09/2024.
//

import ComposableArchitecture
import PhotosUI
import SwiftUI

struct ImageSubmissionFormView: View {
    @Perception.Bindable var store: StoreOf<ImageSubmissionForm>

    init() {
        self.store = Store(
            initialState: ImageSubmissionForm.State(),
            reducer: ImageSubmissionForm.init
        )
    }
    
    var body: some View {
        WithPerceptionTracking {
            Form {
                ValidatableFieldView(field: $store.pictureName) { $pictureName in
                    TextField("Picture's name", text: $pictureName)
                }
                
                PhotosPicker("Select a picture", selection: $store.selectedPicture)
                
                if let image = store.image {
                    switch image {
                    case .loading:
                        ProgressView()
                            .frame(width: 100, height: 100)
                            .background(Color(white: 0.95))
                            .id(UUID())
                        
                    case let .image(image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }
                }
                
                if let selectionError = store.selectedPictureError {
                    Text(selectionError)
                        .lineLimit(2)
                        .foregroundStyle(.red)
                }
                
                Section {
                    Button("Send picture") {
                        store.send(.submitButtonTap)
                    }
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    ImageSubmissionFormView()
}
