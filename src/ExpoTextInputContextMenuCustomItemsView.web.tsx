import * as React from 'react';

import { ExpoTextInputContextMenuCustomItemsViewProps } from './ExpoTextInputContextMenuCustomItems.types';

export default function ExpoTextInputContextMenuCustomItemsView(props: ExpoTextInputContextMenuCustomItemsViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
