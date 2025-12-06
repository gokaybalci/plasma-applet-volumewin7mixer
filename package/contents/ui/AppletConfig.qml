import QtQuick 6.5
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

QtObject {
	PlasmaCore.Theme { id: theme }

	property int mediaControllerSliderHeight: 16 * Kirigami.Units.devicePixelRatio
	// property int mediaControllerButtonHeight: 48 * Kirigami.Units.devicePixelRatio
	property int mediaControllerHeight: 64 * Kirigami.Units.devicePixelRatio
	property int mixerGroupHeight: Kirigami.Units.gridUnit * 24
	property int mixerItemWidth: 100 * Kirigami.Units.devicePixelRatio
	property int volumeSliderWidth: 48 * Kirigami.Units.devicePixelRatio

	property string volumeSliderDesktopThemeId: "widgets/volumeslider"
	property string volumeSliderUrl: {
		if (plasmoid.configuration.volumeSliderTheme == "desktoptheme") {
			if (false) { // svg exists
				return volumeSliderDesktopThemeId
			} else {
				return plasmoid.file("images", "volumeslider.svg") // colortheme
			}
		} else if (plasmoid.configuration.volumeSliderTheme == "colortheme") {
			return plasmoid.file("images", "volumeslider.svg")
		} else { // default
			return plasmoid.file("images", "volumeslider-default.svg")
		}
	}

	property color selectedStreamOutline: config.withAlpha(theme.textColor, 0.25)
	property color selectedStreamOutlinePulse: theme.textColor

	function withAlpha(c1, alpha) {
		var c2 = Qt.darker(c1, 1)
		c2.a = alpha
		return c2
	}
}
