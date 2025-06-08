import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoTextInputContextMenuCustomItemsViewProps } from './ExpoTextInputContextMenuCustomItems.types';

const NativeView: React.ComponentType<ExpoTextInputContextMenuCustomItemsViewProps> =
  requireNativeView('ExpoTextInputContextMenuCustomItems');

export default function ContextMenu(props: ExpoTextInputContextMenuCustomItemsViewProps) {
  return <NativeView {...props} />;
}
