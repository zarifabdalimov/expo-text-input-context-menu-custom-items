package expo.modules.textinputcontextmenucustomitems

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.LinearLayout
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView

class ExpoTextInputContextMenuCustomItemsView(context: Context, appContext: AppContext) : 
    ExpoView(context, appContext), ContextMenuHelper.ContextMenuListener {
    
    private val onContextMenuAction by EventDispatcher()
    private var contextMenuItems: List<Map<String, Any>> = emptyList()
    private var replaceSystemItems: Boolean = false
    
    init {
        ContextMenuHelper.addListener(this)
        
        // Set up the view as a container
        layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        
        // Load global config if available
        ExpoTextInputContextMenuCustomItemsModule.globalContextMenuItems?.let {
            contextMenuItems = it
        }
    }
    
    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        setupContextMenusForDescendantTextInputs()
    }
    
    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        ContextMenuHelper.removeListener(this)
    }
    
    fun setContextMenuItems(items: List<Map<String, Any>>) {
        contextMenuItems = items
        setupContextMenusForDescendantTextInputs()
    }
    
    fun setContextMenuConfig(config: Map<String, Any>) {
        val items = config["items"] as? List<Map<String, Any>> ?: emptyList()
        val replace = config["replaceSystemItems"] as? Boolean ?: false
        
        contextMenuItems = items
        replaceSystemItems = replace
        setupContextMenusForDescendantTextInputs()
    }
    
    override fun onContextMenuConfigChanged(items: List<Map<String, Any>>?) {
        if (contextMenuItems.isEmpty() && items != null) {
            contextMenuItems = items
            setupContextMenusForDescendantTextInputs()
        }
    }
    
    override fun onContextMenuAction(itemId: String, selectedText: String, selectionStart: Int, selectionEnd: Int) {
        onContextMenuAction(mapOf(
            "itemId" to itemId,
            "selectedText" to selectedText,
            "selectionStart" to selectionStart,
            "selectionEnd" to selectionEnd
        ))
    }
    
    private fun setupContextMenusForDescendantTextInputs() {
        if (contextMenuItems.isEmpty()) return
        
        post {
            findEditTexts(this).forEach { editText ->
                setupContextMenuForEditText(editText)
            }
        }
    }
    
    private fun findEditTexts(view: View): List<EditText> {
        val editTexts = mutableListOf<EditText>()
        
        if (view is EditText) {
            editTexts.add(view)
        } else if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                editTexts.addAll(findEditTexts(view.getChildAt(i)))
            }
        }
        
        return editTexts
    }
    
    private fun setupContextMenuForEditText(editText: EditText) {
        editText.customSelectionActionModeCallback = ContextMenuHelper.CustomActionModeCallback(
            editText,
            contextMenuItems,
            replaceSystemItems
        ) { itemId, selectedText, selectionStart, selectionEnd ->
            ContextMenuHelper.notifyMenuAction(itemId, selectedText, selectionStart, selectionEnd)
        }
    }
    
    override fun addView(child: View?) {
        super.addView(child)
        child?.let {
            setupContextMenusForDescendantTextInputs()
        }
    }
    
    override fun addView(child: View?, index: Int) {
        super.addView(child, index)
        child?.let {
            setupContextMenusForDescendantTextInputs()
        }
    }
    
    override fun addView(child: View?, params: ViewGroup.LayoutParams?) {
        super.addView(child, params)
        child?.let {
            setupContextMenusForDescendantTextInputs()
        }
    }
}
