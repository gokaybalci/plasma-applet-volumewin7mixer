// Version: 3

import QtQuick 6.5
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg

Item {
	id: appletIcon
	property string source: ''
	property bool active: false
	readonly property bool usingPackageSvg: filename // plasmoid.file() returns "" if file doesn't exist.
	readonly property string filename: source ? plasmoid.file("", "icons/" + source + '.svg') : ""
	readonly property int minSize: Math.min(width, height)
	property bool smooth: true
	property var overlays: []
	property var colorGroup: PlasmaCore.ColorScope.colorGroup


	PlasmaCore.IconItem {
		id: iconItem
		anchors.fill: parent
		visible: !appletIcon.usingPackageSvg
		source: appletIcon.usingPackageSvg ? '' : appletIcon.source
		active: appletIcon.active
		smooth: appletIcon.smooth
		overlays: appletIcon.overlays
		colorGroup: appletIcon.colorGroup
	}

	KSvg.SvgItem {
		id: svgItem
		anchors.centerIn: parent
		readonly property real maxSize: Math.min(naturalSize.width, naturalSize.height)
		readonly property real widthRatio: naturalSize.width / maxSize
		readonly property real heightRatio: naturalSize.height / maxSize
		width: appletIcon.minSize * widthRatio
		height: appletIcon.minSize * heightRatio

		smooth: appletIcon.smooth

		visible: appletIcon.usingPackageSvg
		svg: KSvg.Svg {
			id: svg
			imagePath: appletIcon.filename
		}

		PlasmaCore.IconItem {
			id: emblemItem
			anchors.fill: parent
			visible: parent.visible
			overlays: appletIcon.overlays
			colorGroup: appletIcon.colorGroup
		}
	}
}
