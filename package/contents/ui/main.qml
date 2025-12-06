/*
	Copyright 2014-2015 Harald Sitter <sitter@kde.org>

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License or (at your option) version 3 or any later version
	accepted by the membership of KDE e.V. (or its successor approved
	by the membership of KDE e.V.), which shall act as a proxy
	defined in Section 14 of version 3 of the license.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*

/*  
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 6.5
import QtQuick.Layouts
import QtQuick.Controls 6.5

// Plasma Frameworks (Plasma 6)
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

// Kirigami (Plasma 6)
import org.kde.kirigami as Kirigami

// Plasma Volume (backend APIs)
import org.kde.plasma.private.volume as PlasmaVolume

// JS helper files
import "./code/Utils.js" as Utils
import "./code/PulseObjectCommands.js" as PulseObjectCommands

PlasmoidItem {
    id: root

    // compatibility properties for components expecting dialog state helpers
    property alias dialogVisible: root.expanded
    function openDialog(usedKeyboard) { root.expanded = true }
    function closeDialog(usedKeyboard) { root.expanded = false }
    function toggleDialog(usedKeyboard) { root.expanded = !root.expanded }

    // Keep an AppletConfig object if needed by other code
    AppletConfig { id: config }

    // --- properties moved from DialogApplet ---
    property string draggedStreamType: ''
    property QtObject draggedStream: null
    function startDrag(pulseObject, type) {
        draggedStreamType = type
        draggedStream = pulseObject
    }
    function clearDrag() {
        draggedStream = null
        draggedStreamType = ''
    }

    property string displayName: i18nd("plasma_applet_org.kde.plasma.volume", "Audio Volume")
    property string speakerIcon: Utils.iconNameForStream(sinkModel.defaultSink)

    // Compact interaction emulation (was compactItemIcon, onCompactItemClicked...)
    compactRepresentation: Item {
        id: compactRep
        width: PlasmaCore.Units.iconSizes.large
        height: PlasmaCore.Units.iconSizes.large

        Image {
            id: compactIcon
            anchors.fill: parent
            source: speakerIcon
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    // Plasma 6 may expose a popup API; this is a best-effort call to toggle the fullRepresentation.
                    // If your environment exposes a specific API, replace this with the proper call.
                    root.toggleDialog(false)
                } else if (mouse.button === Qt.MiddleButton) {
                    toggleDefaultSinksMute()
                }
            }
            // Wheel event handling
            onWheel: {
                var delta = wheel.angleDelta.y || wheel.angleDelta.x
                if (delta > 0) {
                    increaseDefaultSinkVolume()
                } else if (delta < 0) {
                    decreaseDefaultSinkVolume()
                }
            }
        }
    }

    // Full UI (was dialogContents)
    fullRepresentation: Item {
        id: dialogContents

        width: mixerItemRow.width
        height: config.mixerGroupHeight + (mediaControllerVisible ? config.mediaControllerHeight : 0)

        // Keyboard Navigation/Controls
        InputManager { id: inputManager }
        focus: true
        Keys.forwardTo: inputManager.hasSelection ? [inputManager.selectedMixerItem] : []
        Keys.onLeftPressed: inputManager.selectLeft()
        Keys.onRightPressed: inputManager.selectRight()
        function fireKeyOnDefault(keyName, event) {
            if (!inputManager.hasSelection) {
                inputManager.selectDefault()
                var fnName = 'on' + keyName + 'Pressed'
                inputManager.selectedMixerItem.Keys[fnName](event)
            }
        }
        Keys.onUpPressed: fireKeyOnDefault('Up', event)
        Keys.onDownPressed: fireKeyOnDefault('Down', event)
        Keys.onPressed: fireKeyOnDefault('', event)

        Row {
            id: mixerItemRow
            anchors.right: parent.right
            width: childrenRect.width
            height: parent.height - (mediaControllerVisible ? config.mediaControllerHeight : 0)
            spacing: 10

            MixerItemGroup {
                id: sourceOutputMixerItemGroup
                height: parent.height
                title: i18n("Recording Apps")

                model: appOutputsModel
                mixerGroupType: 'SourceOutput'
            }

            MixerItemGroup {
                id: sinkInputMixerItemGroup
                height: parent.height
                title: i18n("Apps")

                model: appsModel
                mixerGroupType: 'SinkInput'
            }

            MixerItemGroup {
                id: sourceMixerItemGroup
                height: parent.height
                title: i18n("Mics")

                model: filteredSourceModel
                mixerGroupType: 'Source'
            }

            MixerItemGroup {
                id: sinkMixerItemGroup
                height: parent.height
                title: i18n("Speakers")

                model: filteredSinkModel
                mixerGroupType: 'Sink'
            }

        }

        MediaController {
            id: mediaController
            width: mixerItemRow.width
            height: config.mediaControllerHeight
        }

        PlasmaComponents.ToolButton {
            id: pinButton
            anchors.top: parent.top
            anchors.right: parent.right
            width: Math.round(PlasmaCore.Units.gridUnit * 1.25)
            height: width
            checkable: true
            icon.name: "window-pin"
            onCheckedChanged: plasmoid.hideOnWindowDeactivate = !checked
        }

        states: [
            State {
                name: "mediaControllerHidden"
                when: !mediaControllerVisible
                PropertyChanges {
                    target: mixerItemRow
                    anchors.top: mixerItemRow.parent.top
                    anchors.bottom: mixerItemRow.parent.bottom
                }
                PropertyChanges {
                    target: mediaController
                    visible: false
                }
            },
            State {
                name: "mediaControllerTop"
                when: mediaControllerVisible && mediaControllerLocation == 'top'
                PropertyChanges {
                    target: mixerItemRow
                    anchors.topMargin: config.mediaControllerHeight
                    anchors.bottom: mixerItemRow.parent.bottom
                }
                PropertyChanges {
                    target: mediaController
                    visible: true
                    anchors.left: mediaController.parent.left
                    anchors.top: mediaController.parent.top
                    anchors.bottom: mixerItemRow.top
                }
                PropertyChanges {
                    target: pinButton
                    anchors.topMargin: config.mediaControllerHeight
                }
            },
            State {
                name: "mediaControllerBottom"
                when: mediaControllerVisible && mediaControllerLocation == 'bottom'
                PropertyChanges {
                    target: mixerItemRow
                    anchors.top: mixerItemRow.parent.top
                    anchors.bottomMargin: config.mediaControllerHeight
                }
                PropertyChanges {
                    target: mediaController
                    visible: true
                    anchors.left: mediaController.parent.left
                    anchors.top: mixerItemRow.bottom
                    anchors.right: mediaController.parent.right
                    anchors.bottom: mediaController.parent.bottom
                }
            }
        ]
    }

    // --- functions and helpers preserved ---
    function increaseDefaultSinkVolume() {
        if (!sinkModel.defaultSink) {
            return
        }
        sinkModel.defaultSink.muted = false
        var volume = PulseObjectCommands.increaseVolume(sinkModel.defaultSink)
        osd.showVolume(volume)
        playFeedback()
    }

    function decreaseDefaultSinkVolume() {
        if (!sinkModel.defaultSink) {
            return
        }
        sinkModel.defaultSink.muted = false
        var volume = PulseObjectCommands.decreaseVolume(sinkModel.defaultSink)
        osd.showVolume(volume)
        playFeedback()
    }

    function toggleDefaultSinksMute() {
        if (!sinkModel.defaultSink) {
            return
        }
        var toMute = PulseObjectCommands.toggleMute(sinkModel.defaultSink)
        osd.showVolume(toMute ? 0 : sinkModel.defaultSink.volume)
        playFeedback()
    }

    function increaseDefaultSourceVolume() {
        if (!sourceModel.defaultSource) {
            return
        }
        sourceModel.defaultSource.muted = false
        var volume = PulseObjectCommands.increaseVolume(sourceModel.defaultSource)
        osd.showMicVolume(volume)
    }

    function decreaseDefaultSourceVolume() {
        if (!sourceModel.defaultSource) {
            return
        }
        sourceModel.defaultSource.muted = false
        var volume = PulseObjectCommands.decreaseVolume(sourceModel.defaultSource)
        osd.showMicVolume(volume)
    }

    function toggleDefaultSourceMute() {
        if (!sourceModel.defaultSource) {
            return
        }
        var toMute = PulseObjectCommands.toggleMute(sourceModel.defaultSource)
        osd.showMicVolume(toMute ? 0 : sourceModel.defaultSource.volume)
    }

    // preserved models
    Mpris2DataSource { id: mpris2Source }
    DynamicFilterModel { id: appsModel; sourceModel: PlasmaVolume.SinkInputModel {} }
    DynamicFilterModel { id: appOutputsModel; sourceModel: PlasmaVolume.SourceOutputModel {} }
    DynamicFilterModel { id: filteredSourceModel; sourceModel: PlasmaVolume.SourceModel { id: sourceModel } }
    DynamicFilterModel { id: filteredSinkModel; sourceModel: PlasmaVolume.SinkModel { id: sinkModel } }
    DynamicFilterModel { id: filteredCardModel; sourceModel: PlasmaVolume.CardModel { id: cardModel } }

    function findStream(model, predicate) {
        for (var i = 0; i < model.count; i++) {
            var stream = model.get(i)
            stream = stream.PulseObject
            if (predicate(stream, i)) {
                return i
            }
        }
        return -1
    }
    function getStream(model, predicate) {
        for (var i = 0; i < model.count; i++) {
            var stream = model.get(i)
            stream = stream.PulseObject
            if (predicate(stream, i)) {
                return stream
            }
        }
        return null
    }

    function action_alsamixer() {
        executable.exec("konsole -e alsamixer")
    }

    function action_pavucontrol() {
        executable.exec("pavucontrol")
    }

    PlasmaVolume.GlobalActionCollection {
        name: "kmix"
        displayName: root.displayName
        PlasmaVolume.GlobalAction {
            objectName: "increase_volume"
            text: i18nd("plasma_applet_org.kde.plasma.volume", "Increase Volume")
            shortcut: Qt.Key_VolumeUp
            onTriggered: increaseDefaultSinkVolume()
        }
        PlasmaVolume.GlobalAction {
            objectName: "decrease_volume"
            text: i18nd("plasma_applet_org.kde.plasma.volume", "Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseDefaultSinkVolume()
        }
        PlasmaVolume.GlobalAction {
            objectName: "mute"
            text: i18nd("plasma_applet_org.kde.plasma.volume", "Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: toggleDefaultSinksMute()
        }
        PlasmaVolume.GlobalAction {
            objectName: "increase_microphone_volume"
            text: i18nd("plasma_applet_org.kde.plasma.volume", "Increase Microphone Volume")
            shortcut: Qt.Key_MicVolumeUp
            onTriggered: increaseDefaultSourceVolume()
        }
        PlasmaVolume.GlobalAction {
            objectName: "decrease_microphone_volume"
            text: i18nd("plasma_applet_org.kde.plasma.volume", "Decrease Microphone Volume")
            shortcut: Qt.Key_MicVolumeDown
            onTriggered: decreaseDefaultSourceVolume()
        }
        PlasmaVolume.GlobalAction {
            objectName: "mic_mute"
            text: i18nd("plasma_applet_org.kde.plasma.volume", "Mute Microphone")
            shortcut: Qt.Key_MicMute
            onTriggered: toggleDefaultSourceMute()
        }
    }

    ExecUtil { id: executable }

    PlasmaVolume.VolumeOSD {
        id: osd
        function showVolume(volume) {
            if (plasmoid.configuration.showOsd) {
                var volPercent = PulseObjectCommands.volumePercent(volume)
                try {
                    osd.show(volPercent)
                } catch (e) {
                    var maxPercent = volPercent > 100 ? 150 : 100
                    osd.show(volPercent, maxPercent)
                }
            }
        }

        function showMicVolume(volume) {
            if (plasmoid.configuration.showOsd) {
                var volPercent = PulseObjectCommands.volumePercent(volume)
                osd.showMicrophone(volPercent)
            }
        }
    }

    PlasmaVolume.VolumeFeedback { id: feedback }

    function playFeedback(sinkIndex) {
        if (!plasmoid.configuration.volumeChangeFeedback) {
            return
        }
        if (sinkIndex == undefined) {
            sinkIndex = sinkModel.defaultSink.index
        }
        feedback.play(sinkIndex)
    }

    // properties that refer to plasmoid/configuration
    property bool showMediaController: plasmoid.configuration.showMediaController
    property string mediaControllerLocation: plasmoid.configuration.mediaControllerLocation || 'bottom'
    property bool mediaControllerVisible: showMediaController && mpris2Source.hasPlayer

    // contextual actions (Plasma 6)
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            id: pavucontrolAction
            text: i18n("PulseAudio Control")
            icon.name: "configure"
            onTriggered: action_pavucontrol()
        },
        PlasmaCore.Action {
            id: alsamixerAction
            text: i18n("AlsaMixer")
            icon.name: "configure"
            onTriggered: action_alsamixer()
        },
        PlasmaCore.Action {
            id: configureAction
            text: i18n("Settings…")
            icon.name: "configure"
            onTriggered: Plasmoid.internalAction("configure").trigger()
        }
    ]

}
