//
//  ValidatableFieldView.swift
//  FormExample
//
//  Created by Anthony MERLE on 11/09/2024.
//

import FormValidation
import SwiftUI

struct ValidatableFieldView<Value, Content>: View where Content: View {
    @Binding var field: ValidatableField<Value>

    let content: (Binding<Value>) -> Content

    var body: some View {
        VStack(alignment: .leading) {
            content($field.value)

            if let errorText = field.errorText {
                Text(errorText)
                    .lineLimit(2)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview("No error") {
    ValidatableFieldView(
        field: .constant(.init(value: "Preview")),
        content: {
            TextField("input", text: $0)
        }
    )
}

#Preview("On error") {
    ValidatableFieldView(
        field: .constant(.init(
            value: "Preview",
            errorText: "Wrong input"
        )),
        content: {
            TextField("input", text: $0)
        }
    )
}

#Preview("On long error") {
    ValidatableFieldView(
        field: .constant(.init(
            value: "Preview",
            errorText: "Sorry, it looks like you entered the wrong input for this field. Please, do try to fix anything bad with it. Thank you."
        )),
        content: {
            TextField("input", text: $0)
        }
    )
}
