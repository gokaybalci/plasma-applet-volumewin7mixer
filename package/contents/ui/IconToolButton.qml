import QtQuick 6.5
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.ToolButton {
	property alias source: icon.source
	property alias iconOpacity: icon.opacity
	PlasmaCore.IconItem {
		id: icon
		anchors.fill: parent
		visible: valid
		active: parent.hovered
		colorGroup: parent.hovered || !parent.flat ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
	}
}
