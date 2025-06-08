import { ContextMenu } from 'expo-text-input-context-menu-custom-items'
import React from 'react'
import { Alert, SafeAreaView, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native'

export default function App() {

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <Text style={styles.title}>Text Input Context Menu Demo</Text>

        <Text style={styles.instructions}>
          Select text in the inputs below to see custom context menu items:
        </Text>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Global Context Menu (all text inputs)</Text>
          <TextInput
            style={styles.textInput}
            multiline
            placeholder="Select some text here to see global context menu items..."
            defaultValue="Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
          />
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>With Custom Context Menu Wrapper</Text>
          <ContextMenu
            style={styles.contextMenuWrapper}
            contextMenuConfig={{
              items: [
                {
                  id: 'custom-action',
                  title: 'Custom Action',
                  subtitle: 'This is a custom action',
                  systemImage: 'star.fill', // iOS only
                },
                {
                  id: 'another-action',
                  title: 'Another Action',
                  subtitle: 'Another custom action',
                  systemImage: 'heart.fill', // iOS only
                }
              ]
            }}
            onContextMenuAction={(event) => {
              const { itemId, selectedText } = event.nativeEvent;
              Alert.alert('Custom Action', `${itemId}: "${selectedText}"`);
            }}
          >
            <TextInput
              style={styles.textInput}
              multiline
              placeholder="This text input has additional custom context menu items..."
              defaultValue="Select text here to see both global and custom context menu items. This demonstrates how you can add different menu items for specific text inputs."
            />
          </ContextMenu>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Only Custom Items (Hide System Items)</Text>
          <ContextMenu
            style={styles.contextMenuWrapper}
            contextMenuConfig={{
              items: [
                {
                  id: 'encrypt',
                  title: 'Encrypt Text',
                  subtitle: 'Encrypt selected text',
                  systemImage: 'lock.fill', // iOS only
                },
                {
                  id: 'count-words',
                  title: 'Count Words',
                  subtitle: 'Count words in selection',
                  systemImage: 'textformat.123', // iOS only
                },
                {
                  id: 'reverse',
                  title: 'Reverse Text',
                  subtitle: 'Reverse selected text',
                  systemImage: 'arrow.uturn.backward', // iOS only
                }
              ],
              replaceSystemItems: true // This hides Copy, Paste, Cut, etc.
            }}
            onContextMenuAction={(event) => {
              const { itemId, selectedText } = event.nativeEvent;
              let message = '';
              switch (itemId) {
                case 'encrypt':
                  message = `Encrypted: ${btoa(selectedText)}`;
                  break;
                case 'count-words':
                  const wordCount = selectedText.trim().split(/\s+/).length;
                  message = `Word count: ${wordCount}`;
                  break;
                case 'reverse':
                  message = `Reversed: ${selectedText.split('').reverse().join('')}`;
                  break;
                default:
                  message = `${itemId}: "${selectedText}"`;
              }
              Alert.alert('Custom Only Action', message);
            }}
          >
            <TextInput
              style={styles.textInput}
              multiline
              placeholder="This text input only shows custom items (no Copy, Paste, etc.)..."
              defaultValue="Select text here to see ONLY custom context menu items. System items like Copy, Paste, Cut are hidden when replaceSystemItems is true."
            />
          </ContextMenu>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Single Line Input</Text>
          <TextInput
            style={styles.singleLineInput}
            placeholder="Single line input with context menu..."
            defaultValue="Select this text to see context menu"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  instructions: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 30,
    color: '#666',
    lineHeight: 22,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
    color: '#333',
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 15,
    backgroundColor: 'white',
    fontSize: 16,
    lineHeight: 22,
    minHeight: 100,
    textAlignVertical: 'top',
  },
  singleLineInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 15,
    backgroundColor: 'white',
    fontSize: 16,
    height: 50,
  },
  contextMenuWrapper: {
    // This wrapper enables custom context menus for its children
  },
  statusSection: {
    marginTop: 20,
    padding: 15,
    backgroundColor: '#e8f4f8',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#007AFF',
  },
  statusTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  statusText: {
    fontSize: 14,
    color: '#666',
    fontFamily: 'monospace',
  },
});

