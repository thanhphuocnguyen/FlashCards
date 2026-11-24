//
//  LanguageTextField.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 24/11/26.
//

import SwiftUI
import UIKit

final class LanguageTextField: UITextField {
    var preferedLangCode: String?
    
    override var textInputMode: UITextInputMode? {
        guard let code = preferedLangCode?.lowercased() else {
            return super.textInputMode
        }
        
        let preferredMode = UITextInputMode.activeInputModes.first { mode in
            guard let lang = mode.primaryLanguage?.lowercased() else {
                return false
            }
            
            return lang == code || lang.hasPrefix(code + "-")
        }
        
        return preferredMode ?? super.textInputMode
    }
}

struct PreferredKeyboardField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let langCode: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> LanguageTextField {
        let field = LanguageTextField()
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.accessibilityLabel = "Front"
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return field
    }
    
    func updateUIView(_ uiView: LanguageTextField, context: Context) {
        context.coordinator.text = $text
        uiView.placeholder = placeholder
        uiView.preferedLangCode = langCode
        
        if uiView.markedTextRange == nil && uiView.text != text {
            uiView.text = text
        }
    }
    
    final class Coordinator : NSObject {
        var text: Binding<String>
        
        init(text: Binding<String>) {
            self.text = text
        }
        
        @objc func textChanged(_ field: UITextField) {
            text.wrappedValue = field.text ?? ""
        }
    }
}

#Preview("Chinese front field") {
    @Previewable @State var front = ""

    PreferredKeyboardField(
        text: $front,
        placeholder: "Word or prompt",
        langCode: "zh-Hans"
    )
    .frame(minHeight: 44)
    .padding()
}
