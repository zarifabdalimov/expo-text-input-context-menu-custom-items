package expo.modules.textinputcontextmenucustomitems

import android.content.Context
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import android.widget.EditText
import java.util.concurrent.CopyOnWriteArrayList

object ContextMenuHelper {
    private val listeners = CopyOnWriteArrayList<ContextMenuListener>()
    
    interface ContextMenuListener {
        fun onContextMenuConfigChanged(items: List<Map<String, Any>>?)
        fun onContextMenuAction(itemId: String, selectedText: String, selectionStart: Int, selectionEnd: Int)
    }
    
    fun addListener(listener: ContextMenuListener) {
        listeners.add(listener)
    }
    
    fun removeListener(listener: ContextMenuListener) {
        listeners.remove(listener)
    }
    
    fun notifyConfigChanged(items: List<Map<String, Any>>?) {
        listeners.forEach { it.onContextMenuConfigChanged(items) }
    }
    
    fun notifyMenuAction(itemId: String, selectedText: String, selectionStart: Int, selectionEnd: Int) {
        listeners.forEach { it.onContextMenuAction(itemId, selectedText, selectionStart, selectionEnd) }
    }
    
    class CustomActionModeCallback(
        private val editText: EditText,
        private val contextMenuItems: List<Map<String, Any>>,
        private val replaceSystemItems: Boolean = false,
        private val onAction: (String, String, Int, Int) -> Unit
    ) : ActionMode.Callback {
        
        override fun onCreateActionMode(mode: ActionMode, menu: Menu): Boolean {
            // If replaceSystemItems is true, clear the menu to remove default items
            if (replaceSystemItems) {
                menu.clear()
            }
            
            // Add custom menu items
            contextMenuItems.forEachIndexed { index, item ->
                val title = item["title"] as? String ?: return@forEachIndexed
                val id = item["id"] as? String ?: return@forEachIndexed
                
                val menuItem = menu.add(Menu.NONE, index + 1000, Menu.NONE, title)
                menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER)
            }
            
            return true
        }
        
        override fun onPrepareActionMode(mode: ActionMode, menu: Menu): Boolean {
            return false
        }
        
        override fun onActionItemClicked(mode: ActionMode, item: MenuItem): Boolean {
            val itemIndex = item.itemId - 1000
            if (itemIndex >= 0 && itemIndex < contextMenuItems.size) {
                val contextMenuItem = contextMenuItems[itemIndex]
                val itemId = contextMenuItem["id"] as? String ?: return false
                
                val selectionStart = editText.selectionStart
                val selectionEnd = editText.selectionEnd
                val selectedText = editText.text.substring(selectionStart, selectionEnd)
                
                onAction(itemId, selectedText, selectionStart, selectionEnd)
                mode.finish()
                return true
            }
            return false
        }
        
        override fun onDestroyActionMode(mode: ActionMode) {
            // No cleanup needed
        }
    }
} 