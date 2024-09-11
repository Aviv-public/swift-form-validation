//
//  ContentView.swift
//  FormExample
//
//  Created by Anthony MERLE on 11/09/2024.
//

import SwiftUI

struct ContentView: View {
    enum FormShowCase: CaseIterable {
        case simpleForm
    }

    let forms = FormShowCase.allCases

    var body: some View {
        NavigationStack {
            List {
                ForEach(forms, id: \.self) { form in
                    NavigationLink(value: form) {
                        Text(title(for: form))
                    }
                }
            }
            .navigationTitle("AvivFormValidation")
            .navigationDestination(for: FormShowCase.self) { showCase in
                    destinationView(for: showCase)
                    .navigationTitle(title(for: showCase))
                }
        }
    }

    func title(for showCase: FormShowCase) -> String {
        switch showCase {
        case .simpleForm:
            "User Profile"
        }
    }

    func destinationView(for showCase: FormShowCase) -> some View {
        switch showCase {
        case .simpleForm:
            Text(title(for: showCase))
        }
    }
}

#Preview {
    ContentView()
}
