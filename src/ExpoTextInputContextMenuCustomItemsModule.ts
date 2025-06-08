import { NativeModule, requireNativeModule } from 'expo';

import { ExpoTextInputContextMenuCustomItemsModuleEvents, ContextMenuConfig } from './ExpoTextInputContextMenuCustomItems.types';

declare class ExpoTextInputContextMenuCustomItemsModule extends NativeModule<ExpoTextInputContextMenuCustomItemsModuleEvents> {
  /**
   * Set global context menu configuration that will be used by all text inputs
   */
  setGlobalContextMenuConfig(config: ContextMenuConfig): Promise<void>;
  
  /**
   * Clear global context menu configuration
   */
  clearGlobalContextMenuConfig(): Promise<void>;
  
  /**
   * Check if custom context menus are supported on this platform
   */
  isSupported(): boolean;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoTextInputContextMenuCustomItemsModule>('ExpoTextInputContextMenuCustomItems');
