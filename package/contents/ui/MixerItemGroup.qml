import QtQuick 6.5
import QtQuick.Layouts
import QtQuick.Controls 6.5 as Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.private.volume as PlasmaVolume

import "lib"

Item {
    id: mixerItemGroup

    property alias view: view
    property alias spacing: view.spacing
    property alias model: view.model
    property alias delegate: view.delegate
    property int mixerItemWidth: config.mixerItemWidth
    property int volumeSliderWidth: config.volumeSliderWidth
    property string mixerGroupType: ""
    property string title: ""

    width: Math.max(view.contentWidth, mixerItemWidth)
    height: parent ? parent.height : view.implicitHeight
    visible: view.count > 0

    ColumnLayout {
        anchors.fill: parent
        spacing: PlasmaCore.Units.smallSpacing

        PlasmaComponents.Label {
            id: headerLabel
            text: mixerItemGroup.title
            Layout.fillWidth: true
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }

        ListView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true
            width: Math.max(contentWidth, mixerItemGroup.mixerItemWidth)
            spacing: 0
            boundsBehavior: Flickable.StopAtBounds
            orientation: ListView.Horizontal

            delegate: MixerItem {
                height: ListView.view.height
                mixerItemWidth: mixerItemGroup.mixerItemWidth
                volumeSliderWidth: mixerItemGroup.volumeSliderWidth
                mixerItemType: mixerItemGroup.mixerGroupType
                showDefaultDeviceIndicator: {
                    if (isDevice) {
                        return mixerItemGroup.model.count > 1
                    } else {
                        return false
                    }
                }
            }

            currentIndex: -1

            highlight: Rectangle {
                color: "transparent"
                anchors.fill: view.currentItem
                border.width: 1
                border.color: config.selectedStreamOutline

                SequentialAnimation on border.color {
                    loops: Animation.Infinite
                    ColorAnimation {
                        from: config.selectedStreamOutline
                        to: config.selectedStreamOutlinePulse
                        duration: 1000
                    }
                    ColorAnimation {
                        from: config.selectedStreamOutlinePulse
                        to: config.selectedStreamOutline
                        duration: 1000
                    }
                }
            }
        }
    }
}
