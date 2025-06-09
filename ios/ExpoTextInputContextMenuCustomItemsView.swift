import ExpoModulesCore
import UIKit

// Protocol for context menu support
protocol ContextMenuSupport {
    var customMenuItems: [[String: Any]] { get set }
    var replaceSystemItems: Bool { get set }
    var onCustomAction: ((String, String, Int, Int) -> Void)? { get set }
}

// Extension to add context menu support to UITextView
private var customMenuItemsKey: UInt8 = 0
private var replaceSystemItemsKey: UInt8 = 0
private var onCustomActionKey: UInt8 = 0

extension UITextView: ContextMenuSupport {
    var customMenuItems: [[String: Any]] {
        get {
            return objc_getAssociatedObject(self, &customMenuItemsKey) as? [[String: Any]] ?? []
        }
        set {
            objc_setAssociatedObject(self, &customMenuItemsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var replaceSystemItems: Bool {
        get {
            return objc_getAssociatedObject(self, &replaceSystemItemsKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &replaceSystemItemsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var onCustomAction: ((String, String, Int, Int) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &onCustomActionKey) as? ((String, String, Int, Int) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &onCustomActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UITextField: ContextMenuSupport {
    var customMenuItems: [[String: Any]] {
        get {
            return objc_getAssociatedObject(self, &customMenuItemsKey) as? [[String: Any]] ?? []
        }
        set {
            objc_setAssociatedObject(self, &customMenuItemsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var replaceSystemItems: Bool {
        get {
            return objc_getAssociatedObject(self, &replaceSystemItemsKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &replaceSystemItemsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var onCustomAction: ((String, String, Int, Int) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &onCustomActionKey) as? ((String, String, Int, Int) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &onCustomActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// Method swizzling helper
class MethodSwizzler {
    static func swizzleMethod(for targetClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(targetClass, originalSelector),
              let swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector) else {
            return
        }
        
        let didAddMethod = class_addMethod(targetClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(targetClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    static var hasSwizzled = false
    
    static func performSwizzling() {
        guard !hasSwizzled else { return }
        hasSwizzled = true
        
        // Swizzle UITextView methods
        swizzleMethod(
            for: UITextView.self,
            originalSelector: #selector(UITextView.canPerformAction(_:withSender:)),
            swizzledSelector: #selector(UITextView.swizzled_canPerformAction(_:withSender:))
        )
        
        swizzleMethod(
            for: UITextView.self,
            originalSelector: #selector(UITextView.becomeFirstResponder),
            swizzledSelector: #selector(UITextView.swizzled_becomeFirstResponder)
        )
        
        // Swizzle UITextField methods
        swizzleMethod(
            for: UITextField.self,
            originalSelector: #selector(UITextField.canPerformAction(_:withSender:)),
            swizzledSelector: #selector(UITextField.swizzled_canPerformAction(_:withSender:))
        )
        
        swizzleMethod(
            for: UITextField.self,
            originalSelector: #selector(UITextField.becomeFirstResponder),
            swizzledSelector: #selector(UITextField.swizzled_becomeFirstResponder)
        )
    }
}

// UITextView extensions for context menu support
extension UITextView {
    @objc func swizzled_canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let actionString = NSStringFromSelector(action)
        if actionString.hasPrefix("customAction_") {
            return true
        }
        
        if replaceSystemItems && !customMenuItems.isEmpty {
            return false
        }
        
        return swizzled_canPerformAction(action, withSender: sender)
    }
    
    @objc func swizzled_becomeFirstResponder() -> Bool {
        let result = swizzled_becomeFirstResponder()
        if result && !customMenuItems.isEmpty {
            setupCustomMenuItems()
        }
        return result
    }
    
    private func setupCustomMenuItems() {
        var menuItems: [UIMenuItem] = []
        
        for (index, item) in customMenuItems.enumerated() {
            if let title = item["title"] as? String {
                let selector = NSSelectorFromString("customAction_\(index):")
                let menuItem = UIMenuItem(title: title, action: selector)
                menuItems.append(menuItem)
                
                // Add the method dynamically
                let method = class_getInstanceMethod(type(of: self), #selector(handleCustomAction(_:)))!
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

// UITextField extensions for context menu support
extension UITextField {
    @objc func swizzled_canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let actionString = NSStringFromSelector(action)
        if actionString.hasPrefix("customAction_") {
            return true
        }
        
        if replaceSystemItems && !customMenuItems.isEmpty {
            return false
        }
        
        return swizzled_canPerformAction(action, withSender: sender)
    }
    
    @objc func swizzled_becomeFirstResponder() -> Bool {
        let result = swizzled_becomeFirstResponder()
        if result && !customMenuItems.isEmpty {
            setupCustomMenuItems()
        }
        return result
    }
    
    private func setupCustomMenuItems() {
        var menuItems: [UIMenuItem] = []
        
        for (index, item) in customMenuItems.enumerated() {
            if let title = item["title"] as? String {
                let selector = NSSelectorFromString("customAction_\(index):")
                let menuItem = UIMenuItem(title: title, action: selector)
                menuItems.append(menuItem)
                
                // Add the method dynamically
                let method = class_getInstanceMethod(type(of: self), #selector(handleCustomAction(_:)))!
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
    
    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        MethodSwizzler.performSwizzling()
        setupGlobalMenuItems()
    }
    
    func setContextMenuItems(_ items: [[String: Any]]) {
        self.contextMenuItems = items
        updateTextInputs()
    }
    
    func setContextMenuConfig(_ config: [String: Any]) {
        self.currentConfig = config
        if let items = config["items"] as? [[String: Any]] {
            self.contextMenuItems = items
        }
        updateTextInputs()
    }
    
    private func getCurrentConfig() -> [String: Any]? {
        return currentConfig.isEmpty ? nil : currentConfig
    }
    
    private func setupGlobalMenuItems() {
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
                updateTextInputs()
            }
        } else {
            if contextMenuItems.isEmpty {
                contextMenuItems = []
                updateTextInputs()
            }
        }
    }
    
    private func updateTextInputs() {
        configureTextInputs(in: self)
    }
    
    private func configureTextInputs(in view: UIView) {
        for subview in view.subviews {
            if let textView = subview as? UITextView {
                configureTextView(textView)
            } else if let textField = subview as? UITextField {
                configureTextField(textField)
            } else {
                configureTextInputs(in: subview)
            }
        }
    }
    
    private func configureTextView(_ textView: UITextView) {
        textView.customMenuItems = contextMenuItems
        if let config = getCurrentConfig() {
            textView.replaceSystemItems = config["replaceSystemItems"] as? Bool ?? false
        }
        
        textView.onCustomAction = { [weak self] itemId, selectedText, start, end in
            self?.onContextMenuAction([
                "itemId": itemId,
                "selectedText": selectedText,
                "selectionStart": start,
                "selectionEnd": end
            ])
        }
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.customMenuItems = contextMenuItems
        if let config = getCurrentConfig() {
            textField.replaceSystemItems = config["replaceSystemItems"] as? Bool ?? false
        }
        
        textField.onCustomAction = { [weak self] itemId, selectedText, start, end in
            self?.onContextMenuAction([
                "itemId": itemId,
                "selectedText": selectedText,
                "selectionStart": start,
                "selectionEnd": end
            ])
        }
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        DispatchQueue.main.async { [weak self] in
            self?.updateTextInputs()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
