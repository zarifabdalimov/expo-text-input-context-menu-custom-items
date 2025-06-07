import { registerWebModule, NativeModule } from 'expo';

import { ExpoTextInputContextMenuCustomItemsModuleEvents } from './ExpoTextInputContextMenuCustomItems.types';

class ExpoTextInputContextMenuCustomItemsModule extends NativeModule<ExpoTextInputContextMenuCustomItemsModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoTextInputContextMenuCustomItemsModule, 'ExpoTextInputContextMenuCustomItemsModule');
