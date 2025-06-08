# expo-text-input-context-menu-custom-items

A React Native/Expo module that allows you to add custom items to text input context menus when users highlight text. Works on both iOS and Android.

## Features

- ✅ Add custom context menu items to text inputs globally
- ✅ Add custom context menu items to specific text inputs using a wrapper component
- ✅ Get selected text, selection positions, and item ID when menu items are tapped
- ✅ Support for iOS system images and Android icons
- ✅ TypeScript support with full type definitions
- ✅ Works with both single-line and multiline text inputs
- ✅ Option to hide system items (Copy, Paste, Cut, etc.) and show only custom items

## Installation

```bash
npm install expo-text-input-context-menu-custom-items
```

## Usage

### Basic Global Setup

Set up global context menu items that will appear in all text inputs:

```tsx
import ExpoTextInputContextMenuCustomItems from 'expo-text-input-context-menu-custom-items'

// Set up global context menu items
ExpoTextInputContextMenuCustomItems.setGlobalContextMenuConfig({
  items: [
    {
      id: 'translate',
      title: 'Translate',
      subtitle: 'Translate selected text',
      systemImage: 'globe', // iOS only
    },
    {
      id: 'search',
      title: 'Search Web',
      subtitle: 'Search on Google',  
      systemImage: 'magnifyingglass', // iOS only
    }
  ]
});

// Listen for context menu actions
const subscription = ExpoTextInputContextMenuCustomItems.addListener(
  'onContextMenuAction',
  (event) => {
    const { itemId, selectedText, selectionStart, selectionEnd } = event;
    
    switch (itemId) {
      case 'translate':
        // Handle translation
        console.log(`Translate: "${selectedText}"`);
        break;
      case 'search':
        // Handle web search
        console.log(`Search: "${selectedText}"`);
        break;
    }
  }
);

// Don't forget to remove the listener
return () => subscription?.remove();
```

### Hide System Items (Show Only Custom Items)

You can hide all system context menu items (Copy, Paste, Cut, etc.) and show only your custom items:

```tsx
ExpoTextInputContextMenuCustomItems.setGlobalContextMenuConfig({
  items: [
    {
      id: 'encrypt',
      title: 'Encrypt Text',
      systemImage: 'lock.fill',
    },
    {
      id: 'count-words', 
      title: 'Count Words',
      systemImage: 'textformat.123',
    }
  ],
  replaceSystemItems: true // This hides Copy, Paste, Cut, etc.
});
```

### Custom Context Menu for Specific Text Inputs

Use the wrapper component to add custom context menu items to specific text inputs:

```tsx
import { ContextMenu } from 'expo-text-input-context-menu-custom-items';

<ContextMenu
  contextMenuConfig={{
    items: [
      {
        id: 'custom-action',
        title: 'Custom Action',
        subtitle: 'This is a custom action',
        systemImage: 'star.fill', // iOS only
      }
    ]
  }}
  onContextMenuAction={(event) => {
    const { itemId, selectedText } = event.nativeEvent;
    console.log(`Custom action: ${itemId} on "${selectedText}"`);
  }}
>
  <TextInput
    style={styles.textInput}
    multiline
    placeholder="Select text here for custom context menu..."
  />
</ContextMenu>
```

## API Reference

### Module Methods

#### `setGlobalContextMenuConfig(config: ContextMenuConfig): Promise<void>`

Sets the global context menu configuration that applies to all text inputs.

#### `clearGlobalContextMenuConfig(): Promise<void>`

Clears the global context menu configuration.

#### `isSupported(): boolean`

Returns whether custom context menus are supported on the current platform.

### Types

#### `ContextMenuItem`

```typescript
interface ContextMenuItem {
  id: string;              // Unique identifier for the menu item
  title: string;           // Display title
  subtitle?: string;       // Optional subtitle (iOS only)
  systemImage?: string;    // iOS system image name (iOS only)
  icon?: string;          // Android drawable resource name or URI (Android only)
}
```

#### `ContextMenuConfig`

```typescript
interface ContextMenuConfig {
  items: ContextMenuItem[];
  replaceSystemItems?: boolean; // If true, hide system items (Copy, Paste, etc.) and show only custom items
}
```

#### `ContextMenuActionPayload`

```typescript
interface ContextMenuActionPayload {
  itemId: string;         // ID of the selected menu item
  selectedText: string;   // The text that was selected
  selectionStart: number; // Start position of selection
  selectionEnd: number;   // End position of selection
}
```

### Component Props

#### `ExpoTextInputContextMenuCustomItemsView`

```typescript
interface ExpoTextInputContextMenuCustomItemsViewProps {
  contextMenuConfig?: ContextMenuConfig;
  onContextMenuAction?: (event: { nativeEvent: ContextMenuActionPayload }) => void;
  children?: React.ReactNode;
  style?: any;
}
```

## Platform-Specific Notes

### iOS

- Uses `UIMenuController` and `UIMenuItem` for iOS 13 and earlier
- For iOS 14+, could be enhanced to use the newer `UIMenu` API
- Supports `systemImage` for menu items using SF Symbols
- Menu items appear in the standard text selection popup

### Android

- Uses `ActionMode.Callback` to add custom menu items
- Integrates with the standard text selection action mode
- Supports custom icons through drawable resources or URIs
- Works with both `EditText` and other text input components

## Example

Check out the example app in the `/example` directory for a complete working implementation showing:

- Global context menu setup
- Custom context menu for specific inputs
- Event handling and text processing
- Different types of menu actions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

---

Made with ❤️ for the React Native community 
