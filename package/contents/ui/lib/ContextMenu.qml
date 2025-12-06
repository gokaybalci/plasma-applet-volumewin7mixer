import QtQuick 6.5
import QtQuick.Controls 6.5 as Controls
import org.kde.plasma.components as PlasmaComponents

// Thin wrapper to recreate the old PlasmaComponents.ContextMenu API with QQC2
PlasmaComponents.Menu {
    id: contextMenu

    property bool clearBeforeOpen: true
    signal beforeOpen(var menu)

    Component { id: separatorComponent; PlasmaComponents.MenuSeparator {} }
    Component { id: menuItemComponent; ContextMenuItem {} }
    Component { id: subMenuComponent; ContextSubMenu {} }

    function newSeperator() {
        return separatorComponent.createObject(contextMenu)
    }
    function newMenuItem() {
        return menuItemComponent.createObject(contextMenu)
    }
    function newSubMenu() {
        return subMenuComponent.createObject(contextMenu)
    }

    function removeAllItems() {
        // Destroy all dynamically created items so the menu can be rebuilt on next open
        for (var i = contentData.length - 1; i >= 0; i--) {
            var item = contentData[i]
            if (item.menu && typeof item.menu.removeAllItems === "function") {
                item.menu.removeAllItems()
            }
            item.destroy()
        }
    }

    function doBeforeOpen() {
        if (clearBeforeOpen) {
            removeAllItems()
        }
        beforeOpen(contextMenu)
    }

    function addMenuItem(item) {
        item.parent = contextMenu
    }

    function show(x, y) {
        popup(x, y)
    }

    function showRelative() {
        open()
    }

    function showBelow(item) {
        visualParent = item
        showRelative()
    }

    onAboutToShow: doBeforeOpen()
}
