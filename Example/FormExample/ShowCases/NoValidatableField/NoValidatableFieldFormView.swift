//
//  NoValidatableFieldFormView.swift
//  FormExample
//
//  Created by Anthony MERLE on 12/09/2024.
//

import ComposableArchitecture
import SwiftUI

struct NoValidatableFieldFormView: View {
    @Perception.Bindable var store: StoreOf<NoValidatableFieldForm>

    init() {
        store = Store(
            initialState: NoValidatableFieldForm.State(),
            reducer: NoValidatableFieldForm.init
        )
    }

    var body: some View {
        WithPerceptionTracking {
            Form {
                Section("Your informations") {
                    TextField(
                        "User name",
                        text: $store.username
                    )
                    .embedInErrorMessage(store.usernameError)
                    
                    VStack(alignment: .leading) {
                        Stepper("Age: \(store.age)", value: $store.age)
                        Text("Should be at least 18")
                            .font(.caption)
                    }
                    .embedInErrorMessage(store.ageError)
                    
                    VStack(alignment: .leading) {
                        Text("Tell us more about yourself")
                        TextEditor(text: $store.userDescription)
                            .frame(minHeight: 80, maxHeight: 200)
                            .background { Color(white: 0.95) }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .embedInErrorMessage(store.userDescriptionError)
                }
                
                Section {
                    Toggle(
                        "Do you agree to sell your soul to us ?",
                        isOn: $store.agreeToSellSoul
                    )
                    .embedInErrorMessage(store.agreeToSellSoulError)
                    
                    Button("Register") {
                        store.send(.registerButtonTap)
                    }
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    NoValidatableFieldFormView()
}
