export interface ContextMenuItem {
  id: string;
  title: string;
  subtitle?: string;
  systemImage?: string; // iOS system image name
  icon?: string; // Android drawable resource name or URI
}

export interface ContextMenuConfig {
  items: ContextMenuItem[];
  replaceSystemItems?: boolean; // If true, only show custom items and hide system items (Copy, Paste, etc.)
}

export interface ContextMenuActionPayload {
  itemId: string;
  selectedText: string;
  selectionStart: number;
  selectionEnd: number;
}

export type ExpoTextInputContextMenuCustomItemsModuleEvents = {
  onContextMenuAction: (params: ContextMenuActionPayload) => void;
};

export type ExpoTextInputContextMenuCustomItemsViewProps = {
  contextMenuConfig?: ContextMenuConfig;
  onContextMenuAction?: (event: { nativeEvent: ContextMenuActionPayload }) => void;
  children?: React.ReactNode;
  style?: any;
};
