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
        // Replace with our custom text view
        let customTextView = CustomTextView(frame: textView.frame)
        customTextView.text = textView.text
        customTextView.font = textView.font
        customTextView.textColor = textView.textColor
        customTextView.backgroundColor = textView.backgroundColor
        customTextView.isEditable = textView.isEditable
        customTextView.isSelectable = textView.isSelectable
        customTextView.customMenuItems = contextMenuItems
        
        // Check if we should replace system items
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
        
        textView.superview?.insertSubview(customTextView, aboveSubview: textView)
        textView.removeFromSuperview()
    }
    
    private func setupCustomTextField(_ textField: UITextField) {
        // Replace with our custom text field
        let customTextField = CustomTextField(frame: textField.frame)
        customTextField.text = textField.text
        customTextField.font = textField.font
        customTextField.textColor = textField.textColor
        customTextField.backgroundColor = textField.backgroundColor
        customTextField.placeholder = textField.placeholder
        customTextField.isEnabled = textField.isEnabled
        customTextField.customMenuItems = contextMenuItems
        
        // Check if we should replace system items
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
        
        textField.superview?.insertSubview(customTextField, aboveSubview: textField)
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
