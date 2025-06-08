package expo.modules.textinputcontextmenucustomitems

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoTextInputContextMenuCustomItemsModule : Module() {
  companion object {
    @JvmStatic
    var globalContextMenuItems: List<Map<String, Any>>? = null
  }

  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  override fun definition() = ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('ExpoTextInputContextMenuCustomItems')` in JavaScript.
    Name("ExpoTextInputContextMenuCustomItems")

    // Defines event names that the module can send to JavaScript.
    Events("onContextMenuAction")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("isSupported") {
      true // Android supports custom context menus
    }

    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setGlobalContextMenuConfig") { config: Map<String, Any> ->
      val items = config["items"] as? List<Map<String, Any>>
      globalContextMenuItems = items
      
      // Notify all existing views about the config change
      ContextMenuHelper.notifyConfigChanged(items)
    }

    AsyncFunction("clearGlobalContextMenuConfig") {
      globalContextMenuItems = null
      ContextMenuHelper.notifyConfigChanged(null)
    }

    // Enables the module to be used as a native view. Definition components that are accepted as part of
    // the view definition: Prop, Events.
    View(ExpoTextInputContextMenuCustomItemsView::class) {
      // Defines a setter for the `contextMenuConfig` prop.
      Prop("contextMenuConfig") { view: ExpoTextInputContextMenuCustomItemsView, config: Map<String, Any> ->
        view.setContextMenuConfig(config)
      }

      // Defines an event that the view can send to JavaScript.
      Events("onContextMenuAction")
    }
  }
}
