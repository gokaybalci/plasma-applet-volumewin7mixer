import QtQuick 6.5
import QtQuick.Controls 6.5 as Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

    readonly property real dpr: Kirigami.Units.devicePixelRatio
    PlasmaCore.Theme { id: theme }

	property alias cfg_volumeUpDownSteps: volumeUpDownSteps.value
	property alias cfg_showVolumeTickmarks: showVolumeTickmarks.checked
	// property alias cfg_showOpenKcmAudioVolume: showOpenKcmAudioVolume.checked
	// property alias cfg_showOpenPavucontrol: showOpenPavucontrol.checked
	property alias cfg_moveAllAppsOnSetDefault: moveAllAppsOnSetDefault.checked
	property alias cfg_closeOnSetDefault: closeOnSetDefault.checked
	property alias cfg_setDefaultOnClickIcon: setDefaultOnClickIcon.checked
	property alias cfg_showMediaController: showMediaController.checked
	property alias cfg_showMediaTimeElapsed: showMediaTimeElapsed.checked
	property alias cfg_showMediaTimeLeft: showMediaTimeLeft.checked
	property alias cfg_showMediaTotalDuration: showMediaTotalDuration.checked
	property alias cfg_showOsd: showOsd.checked
	property alias cfg_volumeChangeFeedback: volumeChangeFeedback.checked
	property alias cfg_showVisualFeedback: showVisualFeedback.checked
	property alias cfg_showVirtualStreams: showVirtualStreams.checked

	Controls.GroupBox {
		Layout.fillWidth: true
		title: i18n("Media Keys")

		ColumnLayout {

			RowLayout {
				Controls.Label {
					text: i18n("Volume Up/Down Steps:")
				}
				Controls.SpinBox {
					id: volumeUpDownSteps
					from: 1
					to: 1000
				}
				Controls.Label {
					text: i18n("One step = %1%", Math.round(1/volumeUpDownSteps.value * 100))
				}
			}

		}
	}

	Controls.GroupBox {
		Layout.fillWidth: true
		title: i18n("Mixer")

		ColumnLayout {

			Controls.CheckBox {
				enabled: false
				id: showVolumeTickmarks
				checked: true
				text: i18n("Show Ticks every 10%")
			}

			RowLayout {
				Controls.Label {
					text: i18n("Volume Boost")
				}
				Controls.SpinBox {
					enabled: false
					id: volumeBoostMaxVolume
					from: 100
					value: 150
					to: 1000
					stepSize: 10
					suffix: i18nd("plasma_applet_org.kde.plasma.volume", "%")
				}
			}
			


		}
	}

	Controls.ButtonGroup { id: volumeSliderThemeButtonGroup }

	Controls.GroupBox {
		Layout.fillWidth: true
		title: i18n("Volume Slider Theme")

		ColumnLayout {
			Controls.RadioButton {
				text: i18n("Desktop Theme (%1)", theme.themeName)
				Controls.ButtonGroup.group: volumeSliderThemeButtonGroup
				enabled: false
				// checked: plasmoid.configuration.volumeSliderTheme == "desktoptheme"
				// onClicked: plasmoid.configuration.volumeSliderTheme = "desktoptheme"
			}
			Controls.RadioButton {
				text: i18n("Color Theme (Default Look)")
				Controls.ButtonGroup.group: volumeSliderThemeButtonGroup
				// checked: plasmoid.configuration.volumeSliderTheme == "colortheme"
				// onClicked: plasmoid.configuration.volumeSliderTheme = "colortheme"
				checked: plasmoid.configuration.volumeSliderTheme == "desktoptheme"
				onClicked: plasmoid.configuration.volumeSliderTheme = "desktoptheme"
			}
			
			Controls.RadioButton {
				text: i18n("Light Blue on Grey (Default Look)")
				Controls.ButtonGroup.group: volumeSliderThemeButtonGroup
				checked: plasmoid.configuration.volumeSliderTheme == "default"
				onClicked: plasmoid.configuration.volumeSliderTheme = "default"
			}
		}
	}

	// GroupBox {
	// 	Layout.fillWidth: true
	// 	title: 'Context Menu'

	// 	ColumnLayout {

	// 		CheckBox {
	// 			id: showOpenKcmAudioVolume
	// 			text: 'KDE Audio Volume'
	// 		}

	// 		CheckBox {
	// 			id: showOpenPavucontrol
	// 			text: 'pavucontrol (PulseAudio Control) (Can do Audio Boost)'
	// 		}

	// 		RowLayout {
	// 			Text { width: 24 } // indent
	// 			Text {
	// 				font.family: 'monospace'
	// 				text: 'sudo apt-get install pavucontrol'
	// 			}
	// 		}

	// 	}
	// }

	Controls.GroupBox {
		Layout.fillWidth: true
		title: i18n("Options")

		ColumnLayout {

			Controls.CheckBox {
				id: moveAllAppsOnSetDefault
				text: i18n("Move all Apps to device when setting default device (when set in with the context menu)")
			}

			Controls.CheckBox {
				id: closeOnSetDefault
				text: i18n("Close the popup after setting a default device")
			}

			Controls.CheckBox {
				id: setDefaultOnClickIcon
				text: i18n("Set default device after clicking a speaker/mic icon")
			}

			Controls.CheckBox {
				id: showOsd
				text: i18n("Show OSD on when changing the volume.")
			}

			Controls.CheckBox {
				id: volumeChangeFeedback
				text: i18n("Volume Feedback: Play popping noise when changing the volume.")
			}

			Controls.CheckBox {
				id: showVisualFeedback
				enabled: false
				text: i18n("Visual Feedback: Visualize current sound.")

				Component.onCompleted: {
					var mixerPluginTest = Qt.createQmlObject('import org.kde.plasma.private.volumewin7mixer 1.0; import QtQuick 6.5; QtObject {}', volumeChangeFeedback)
					if (mixerPluginTest) {
						enabled = true
					}
				}
			}

			Controls.CheckBox {
				id: showVirtualStreams
				text: i18n("Show virtual streams.")
			}

		}
	}

	Controls.GroupBox {
		Layout.fillWidth: true
		title: i18n("Media Controller")

		ColumnLayout {

			Controls.CheckBox {
				id: showMediaController
				text: i18n("Show Media Controller")
			}

			ConfigComboBox {
				id: appDescriptionControl
				configKey: "mediaControllerLocation"
				label: i18n("Position")
				model: [
					{ value: "top", text: i18n("Top") },
					{ value: "bottom", text: i18n("Bottom") },
				]
			}

			Controls.CheckBox {
				id: showMediaTimeElapsed
				text: i18n("Show Time Elapsed")
			}

			Controls.CheckBox {
				id: showMediaTimeLeft
				text: i18n("Show Time Left")
			}

			Controls.CheckBox {
				id: showMediaTotalDuration
				text: i18n("Show Total Duration")
			}

		}
	}

	Controls.GroupBox {
		Layout.fillWidth: true
		title: i18n("Keyboard Shortcuts")

		ColumnLayout {
			id: shortcutsTable
			Layout.fillWidth: true

			Controls.Label {
				text: i18n("Set the Global Shortcut in the Keyboard Shortcuts tab.")
				wrapMode: Text.Wrap
			}

			Controls.Label {} // Whitespace

			Repeater {
				property var shortcuts: [
					{
						"label": i18n("Global Shortcut"),
						"keySequence": plasmoid.globalShortcut,
					},
					{
						"label": i18n("Selection: Select Previous Stream"),
						"keySequence": "Left",
					},
					{
						"label": i18n("Selection: Select Next Stream"),
						"keySequence": "Right",
					},
					{
						"label": i18n("Selection: Increase Volume"),
						"keySequence": "Up",
					},
					{
						"label": i18n("Selection: Decrease Volume"),
						"keySequence": "Down",
					},
					{
						"label": i18n("Selection: Make Default Device"),
						"keySequence": "Enter",
					},
					{
						"label": i18n("Selection: Toggle Mute"),
						"keySequence": "M",
					},
					{
						"label": i18n("Selection: Open Context Menu"),
						"keySequence": "Menu",
					},
				]

				Component.onCompleted: {
					for (var i = 0; i <= 10; i++) {
						shortcuts.push({
							"label": i18n("Selection: Set Volume to %1%", i*10),
							"keySequence": i < 10 ? "" + i : "",
						})
						model = shortcuts
					}
				}


				RowLayout {
					Layout.fillWidth: true
					Controls.Label {
						text: modelData.keySequence
						
						Layout.minimumWidth: 100 * page.dpr
					}
					Controls.Label {
						text: modelData.label
						font.bold: true
					}
				}

			}
		}
	}

	
}
