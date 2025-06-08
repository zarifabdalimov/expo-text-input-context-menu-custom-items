import ExpoModulesCore
import UIKit

// Custom UITextView that supports custom context menu items
class CustomTextView: UITextView {
    var customMenuItems: [[String: Any]] = []
    var replaceSystemItems: Bool = false
    var onCustomAction: ((String, String, Int, Int) -> Void)?
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let actionString = NSStringFromSelector(action)
        if actionString.hasPrefix("customAction_") {
            return true
        }
        
        // If replaceSystemItems is true, hide all system actions
        if replaceSystemItems {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            setupCustomMenuItems()
        }
        return result
    }
    
    private func setupCustomMenuItems() {
        guard !customMenuItems.isEmpty else { return }
        
        var menuItems: [UIMenuItem] = []
        
        for (index, item) in customMenuItems.enumerated() {
            if let title = item["title"] as? String {
                let selector = NSSelectorFromString("customAction_\(index):")
                let menuItem = UIMenuItem(title: title, action: selector)
                menuItems.append(menuItem)
                
                // Add the method dynamically to this instance
                let method = class_getInstanceMethod(CustomTextView.self, #selector(handleCustomAction(_:)))!
                let imp = method_getImplementation(method)
                let types = method_getTypeEncoding(method)
                class_addMethod(type(of: self), selector, imp, types)
            }
        }
        
        UIMenuController.shared.menuItems = menuItems
        UIMenuController.shared.update()
    }
    
    @objc private func handleCustomAction(_ sender: UIMenuItem) {
        let selectorString = NSStringFromSelector(sender.action)
        if let indexString = selectorString.components(separatedBy: "_").last?.components(separatedBy: ":").first,
           let index = Int(indexString),
           index < customMenuItems.count {
            
            let item = customMenuItems[index]
            if let id = item["id"] as? String {
                let selectedText = self.text(in: self.selectedTextRange ?? self.textRange(from: self.beginningOfDocument, to: self.endOfDocument)!) ?? ""
                let selectionStart = self.offset(from: self.beginningOfDocument, to: self.selectedTextRange?.start ?? self.beginningOfDocument)
                let selectionEnd = self.offset(from: self.beginningOfDocument, to: self.selectedTextRange?.end ?? self.endOfDocument)
                
                onCustomAction?(id, selectedText, selectionStart, selectionEnd)
            }
        }
    }
}

// Custom UITextField that supports custom context menu items
class CustomTextField: UITextField {
    var customMenuItems: [[String: Any]] = []
    var replaceSystemItems: Bool = false
    var onCustomAction: ((String, String, Int, Int) -> Void)?
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let actionString = NSStringFromSelector(action)
        if actionString.hasPrefix("customAction_") {
            return true
        }
        
        // If replaceSystemItems is true, hide all system actions
        if replaceSystemItems {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            setupCustomMenuItems()
        }
        return result
    }
    
    private func setupCustomMenuItems() {
        guard !customMenuItems.isEmpty else { return }
        
        var menuItems: [UIMenuItem] = []
        
        for (index, item) in customMenuItems.enumerated() {
            if let title = item["title"] as? String {
                let selector = NSSelectorFromString("customAction_\(index):")
                let menuItem = UIMenuItem(title: title, action: selector)
                menuItems.append(menuItem)
                
                // Add the method dynamically to this instance
                let method = class_getInstanceMethod(CustomTextField.self, #selector(handleCustomAction(_:)))!
                let imp = method_getImplementation(method)
                let types = method_getTypeEncoding(method)
                class_addMethod(type(of: self), selector, imp, types)
            }
        }
        
        UIMenuController.shared.menuItems = menuItems
        UIMenuController.shared.update()
    }
    
    @objc private func handleCustomAction(_ sender: UIMenuItem) {
        let selectorString = NSStringFromSelector(sender.action)
        if let indexString = selectorString.components(separatedBy: "_").last?.components(separatedBy: ":").first,
           let index = Int(indexString),
           index < customMenuItems.count {
            
            let item = customMenuItems[index]
            if let id = item["id"] as? String {
                let selectedText = self.text(in: self.selectedTextRange ?? self.textRange(from: self.beginningOfDocument, to: self.endOfDocument)!) ?? ""
                let selectionStart = self.offset(from: self.beginningOfDocument, to: self.selectedTextRange?.start ?? self.beginningOfDocument)
                let selectionEnd = self.offset(from: self.beginningOfDocument, to: self.selectedTextRange?.end ?? self.endOfDocument)
                
                onCustomAction?(id, selectedText, selectionStart, selectionEnd)
            }
        }
    }
}

// Main view component
class ExpoTextInputContextMenuCustomItemsView: ExpoView {
    private let onContextMenuAction = EventDispatcher()
    private var contextMenuItems: [[String: Any]] = []
    private var currentConfig: [String: Any] = [:]
    private var customTextViews: [UITextInput] = []
    
    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupGlobalMenuItems()
    }
    
    func setContextMenuItems(_ items: [[String: Any]]) {
        self.contextMenuItems = items
        updateCustomTextViews()
    }
    
    func setContextMenuConfig(_ config: [String: Any]) {
        self.currentConfig = config
        if let items = config["items"] as? [[String: Any]] {
            self.contextMenuItems = items
        }
        updateCustomTextViews()
    }
    
    private func getCurrentConfig() -> [String: Any]? {
        return currentConfig.isEmpty ? nil : currentConfig
    }
    
    private func setupGlobalMenuItems() {
        // Get global menu items from module
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(globalMenuItemsChanged(_:)),
            name: NSNotification.Name("ContextMenuConfigChanged"),
            object: nil
        )
    }
    
    @objc private func globalMenuItemsChanged(_ notification: Notification) {
        if let items = notification.object as? [[String: Any]] {
            if contextMenuItems.isEmpty {
                contextMenuItems = items
                updateCustomTextViews()
            }
        } else {
            if contextMenuItems.isEmpty {
                contextMenuItems = []
                updateCustomTextViews()
            }
        }
    }
    
    private func updateCustomTextViews() {
        findAndSetupTextInputs(in: self)
    }
    
    private func findAndSetupTextInputs(in view: UIView) {
        for subview in view.subviews {
            if let textView = subview as? UITextView {
                setupCustomTextView(textView)
            } else if let textField = subview as? UITextField {
                setupCustomTextField(textField)
            } else {
                findAndSetupTextInputs(in: subview)
            }
        }
    }
    
    private func setupCustomTextView(_ textView: UITextView) {
        // Don't replace if it's already our custom view
        if textView is CustomTextView { return }
        
        // Create custom text view with same frame
        let customTextView = CustomTextView(frame: textView.frame)
        
        // Copy all text properties
        customTextView.text = textView.text
        customTextView.attributedText = textView.attributedText
        customTextView.font = textView.font
        customTextView.textColor = textView.textColor
        customTextView.textAlignment = textView.textAlignment
        customTextView.selectedRange = textView.selectedRange
        
        // Copy editing properties
        customTextView.isEditable = textView.isEditable
        customTextView.isSelectable = textView.isSelectable
        customTextView.isScrollEnabled = textView.isScrollEnabled
        customTextView.isUserInteractionEnabled = textView.isUserInteractionEnabled
        
        // Copy appearance properties
        customTextView.backgroundColor = textView.backgroundColor
        customTextView.layer.cornerRadius = textView.layer.cornerRadius
        customTextView.layer.borderWidth = textView.layer.borderWidth
        customTextView.layer.borderColor = textView.layer.borderColor
        customTextView.alpha = textView.alpha
        customTextView.isHidden = textView.isHidden
        
        // Copy scroll view properties
        customTextView.showsVerticalScrollIndicator = textView.showsVerticalScrollIndicator
        customTextView.showsHorizontalScrollIndicator = textView.showsHorizontalScrollIndicator
        customTextView.bounces = textView.bounces
        customTextView.alwaysBounceVertical = textView.alwaysBounceVertical
        customTextView.alwaysBounceHorizontal = textView.alwaysBounceHorizontal
        
        // Copy content insets and container properties
        customTextView.contentInset = textView.contentInset
        customTextView.scrollIndicatorInsets = textView.scrollIndicatorInsets
        customTextView.textContainerInset = textView.textContainerInset
        customTextView.textContainer.lineFragmentPadding = textView.textContainer.lineFragmentPadding
        customTextView.textContainer.maximumNumberOfLines = textView.textContainer.maximumNumberOfLines
        customTextView.textContainer.lineBreakMode = textView.textContainer.lineBreakMode
        
        // Copy keyboard properties
        customTextView.keyboardType = textView.keyboardType
        customTextView.keyboardAppearance = textView.keyboardAppearance
        customTextView.returnKeyType = textView.returnKeyType
        customTextView.autocorrectionType = textView.autocorrectionType
        customTextView.autocapitalizationType = textView.autocapitalizationType
        customTextView.spellCheckingType = textView.spellCheckingType
        
        // Set custom properties
        customTextView.customMenuItems = contextMenuItems
        if let config = getCurrentConfig() {
            customTextView.replaceSystemItems = config["replaceSystemItems"] as? Bool ?? false
        }
        
        customTextView.onCustomAction = { [weak self] itemId, selectedText, start, end in
            self?.onContextMenuAction([
                "itemId": itemId,
                "selectedText": selectedText,
                "selectionStart": start,
                "selectionEnd": end
            ])
        }
        
        guard let superview = textView.superview else { return }
        
        // Transfer Auto Layout constraints
        customTextView.translatesAutoresizingMaskIntoConstraints = textView.translatesAutoresizingMaskIntoConstraints
        
        if !textView.translatesAutoresizingMaskIntoConstraints {
            // Copy all constraints from the original view
            let constraints = superview.constraints.filter { constraint in
                constraint.firstItem as? UIView == textView || constraint.secondItem as? UIView == textView
            }
            
            // Add the custom view first
            superview.insertSubview(customTextView, aboveSubview: textView)
            
            // Update constraints to reference the new view
            for constraint in constraints {
                let newConstraint: NSLayoutConstraint
                
                if constraint.firstItem as? UIView == textView {
                    newConstraint = NSLayoutConstraint(
                        item: customTextView,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: constraint.secondItem,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    )
                } else {
                    newConstraint = NSLayoutConstraint(
                        item: constraint.firstItem as Any,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: customTextView,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    )
                }
                
                newConstraint.priority = constraint.priority
                newConstraint.isActive = constraint.isActive
                superview.removeConstraint(constraint)
                superview.addConstraint(newConstraint)
            }
        } else {
            // For frame-based layout, ensure autoresizing mask is copied
            customTextView.autoresizingMask = textView.autoresizingMask
            superview.insertSubview(customTextView, aboveSubview: textView)
        }
        
        // Remove the original view
        textView.removeFromSuperview()
    }
    
    private func setupCustomTextField(_ textField: UITextField) {
        // Don't replace if it's already our custom view
        if textField is CustomTextField { return }
        
        // Create custom text field with same frame
        let customTextField = CustomTextField(frame: textField.frame)
        
        // Copy all text properties
        customTextField.text = textField.text
        customTextField.attributedText = textField.attributedText
        customTextField.placeholder = textField.placeholder
        customTextField.attributedPlaceholder = textField.attributedPlaceholder
        customTextField.font = textField.font
        customTextField.textColor = textField.textColor
        customTextField.textAlignment = textField.textAlignment
        
        // Copy editing properties
        customTextField.isEnabled = textField.isEnabled
        customTextField.isUserInteractionEnabled = textField.isUserInteractionEnabled
        customTextField.borderStyle = textField.borderStyle
        customTextField.clearButtonMode = textField.clearButtonMode
        customTextField.minimumFontSize = textField.minimumFontSize
        customTextField.adjustsFontSizeToFitWidth = textField.adjustsFontSizeToFitWidth
        
        // Copy appearance properties
        customTextField.backgroundColor = textField.backgroundColor
        customTextField.layer.cornerRadius = textField.layer.cornerRadius
        customTextField.layer.borderWidth = textField.layer.borderWidth
        customTextField.layer.borderColor = textField.layer.borderColor
        customTextField.alpha = textField.alpha
        customTextField.isHidden = textField.isHidden
        
        // Copy keyboard properties
        customTextField.keyboardType = textField.keyboardType
        customTextField.keyboardAppearance = textField.keyboardAppearance
        customTextField.returnKeyType = textField.returnKeyType
        customTextField.autocorrectionType = textField.autocorrectionType
        customTextField.autocapitalizationType = textField.autocapitalizationType
        customTextField.spellCheckingType = textField.spellCheckingType
        customTextField.isSecureTextEntry = textField.isSecureTextEntry
        
        // Set custom properties
        customTextField.customMenuItems = contextMenuItems
        if let config = getCurrentConfig() {
            customTextField.replaceSystemItems = config["replaceSystemItems"] as? Bool ?? false
        }
        
        customTextField.onCustomAction = { [weak self] itemId, selectedText, start, end in
            self?.onContextMenuAction([
                "itemId": itemId,
                "selectedText": selectedText,
                "selectionStart": start,
                "selectionEnd": end
            ])
        }
        
        guard let superview = textField.superview else { return }
        
        // Transfer Auto Layout constraints
        customTextField.translatesAutoresizingMaskIntoConstraints = textField.translatesAutoresizingMaskIntoConstraints
        
        if !textField.translatesAutoresizingMaskIntoConstraints {
            // Copy all constraints from the original view
            let constraints = superview.constraints.filter { constraint in
                constraint.firstItem as? UIView == textField || constraint.secondItem as? UIView == textField
            }
            
            // Add the custom view first
            superview.insertSubview(customTextField, aboveSubview: textField)
            
            // Update constraints to reference the new view
            for constraint in constraints {
                let newConstraint: NSLayoutConstraint
                
                if constraint.firstItem as? UIView == textField {
                    newConstraint = NSLayoutConstraint(
                        item: customTextField,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: constraint.secondItem,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    )
                } else {
                    newConstraint = NSLayoutConstraint(
                        item: constraint.firstItem as Any,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: customTextField,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    )
                }
                
                newConstraint.priority = constraint.priority
                newConstraint.isActive = constraint.isActive
                superview.removeConstraint(constraint)
                superview.addConstraint(newConstraint)
            }
        } else {
            // For frame-based layout, ensure autoresizing mask is copied
            customTextField.autoresizingMask = textField.autoresizingMask
            superview.insertSubview(customTextField, aboveSubview: textField)
        }
        
        // Remove the original view
        textField.removeFromSuperview()
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        // Setup any new text inputs that are added
        DispatchQueue.main.async { [weak self] in
            self?.updateCustomTextViews()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
