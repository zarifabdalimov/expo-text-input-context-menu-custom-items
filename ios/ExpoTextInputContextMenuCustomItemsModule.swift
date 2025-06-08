import ExpoModulesCore
import UIKit

public class ExpoTextInputContextMenuCustomItemsModule: Module {
  private var globalContextMenuConfig: [[String: Any]]?
  
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('ExpoTextInputContextMenuCustomItems')` in JavaScript.
    Name("ExpoTextInputContextMenuCustomItems")

    // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
    Constants([
      "PI": Double.pi
    ])

    // Defines event names that the module can send to JavaScript.
    Events("onContextMenuAction")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("isSupported") { () -> Bool in
      return true // iOS supports custom context menus
    }

    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setGlobalContextMenuConfig") { (config: [String: Any]) in
      if let items = config["items"] as? [[String: Any]] {
        self.globalContextMenuConfig = items
        // Post notification to update all existing text views
        NotificationCenter.default.post(
          name: NSNotification.Name("ContextMenuConfigChanged"), 
          object: items
        )
      }
    }

    AsyncFunction("clearGlobalContextMenuConfig") { () in
      self.globalContextMenuConfig = nil
      NotificationCenter.default.post(
        name: NSNotification.Name("ContextMenuConfigChanged"), 
        object: nil
      )
    }

    // Enables the module to be used as a native view. Definition components that are accepted as part of the
    // view definition: Prop, Events.
    View(ExpoTextInputContextMenuCustomItemsView.self) {
      // Defines a setter for the `contextMenuConfig` prop.
      Prop("contextMenuConfig") { (view: ExpoTextInputContextMenuCustomItemsView, config: [String: Any]) in
        view.setContextMenuConfig(config)
      }

      Events("onContextMenuAction")
    }
  }
  
  // Helper function to get current global config
  public func getGlobalContextMenuConfig() -> [[String: Any]]? {
    return globalContextMenuConfig
  }
}
