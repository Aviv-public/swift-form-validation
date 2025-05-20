//
//  AlertState+FormValidated.swift
//  FormExample
//
//  Created by Anthony MERLE on 13/09/2024.
//

import ComposableArchitecture
import Foundation

extension AlertState {
    static var formValidationSuccess: Self {
        .init(
            title: { TextState("Success!") },
            message: { TextState("Your form has been validated") }
        )
    }
}
