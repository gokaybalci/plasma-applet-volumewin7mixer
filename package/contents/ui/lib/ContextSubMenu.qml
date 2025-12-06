import QtQuick 6.5
import org.kde.plasma.components as PlasmaComponents

ContextMenuItem {
    id: subMenuItem

    menu: ContextMenu {
        id: subContextMenu
        visualParent: subMenuItem
    }

    function newSeperator() {
        return subContextMenu.newSeperator()
    }
    function newMenuItem() {
        return subContextMenu.newMenuItem()
    }
    function newSubMenu() {
        return subContextMenu.newSubMenu()
    }

    function addMenuItem(menuItem) {
        subContextMenu.addMenuItem(menuItem)
    }
}
