import { NativeModule, requireNativeModule } from 'expo';

import { ExpoTextInputContextMenuCustomItemsModuleEvents } from './ExpoTextInputContextMenuCustomItems.types';

declare class ExpoTextInputContextMenuCustomItemsModule extends NativeModule<ExpoTextInputContextMenuCustomItemsModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoTextInputContextMenuCustomItemsModule>('ExpoTextInputContextMenuCustomItems');
