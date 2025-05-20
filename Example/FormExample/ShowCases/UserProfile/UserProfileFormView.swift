//
//  UserProfileFormView.swift
//  FormExample
//
//  Created by Anthony MERLE on 11/09/2024.
//

import ComposableArchitecture
import SwiftUI

struct UserProfileFormView: View {
    @Perception.Bindable var store: StoreOf<UserProfileForm>

    init() {
        store = Store(
            initialState: UserProfileForm.State(),
            reducer: UserProfileForm.init
        )
    }

    var body: some View {
        WithPerceptionTracking {
            Form {
                Section("Your informations") {
                    ValidatableFieldView(field: $store.username) { $name in
                        TextField("User name", text: $name)
                    }
                    
                    ValidatableFieldView(field: $store.age) { $age in
                        VStack(alignment: .leading) {
                            Stepper("Age: \(age)", value: $age)
                            Text("Should be at least 18")
                                .font(.caption)
                        }
                    }
                    
                    ValidatableFieldView(field: $store.userDescription) { $userDescription in
                        VStack(alignment: .leading) {
                            Text("Tell us more about yourself")
                            TextEditor(text: $userDescription)
                                .frame(minHeight: 80, maxHeight: 200)
                                .background { Color(white: 0.95) }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                Section {
                    ValidatableFieldView(field: $store.agreeToSellSoul) { $toggle in
                        Toggle("Do you agree to sell your soul to us ?", isOn: $toggle)
                    }
                    
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
    UserProfileFormView()
}
