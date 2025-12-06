import QtQuick 6.5
import QtQuick.Controls 6.5 as Controls
import QtQuick.Layouts
import org.kde.plasma.private.volume as PlasmaVolume

Item {
	id: page

	PlasmaVolume.SinkModel { id: sinkModel }
	PlasmaVolume.StreamRestoreModel { id: streamRestoreModel }

	Controls.Frame {
		anchors.fill: parent
		Controls.ScrollView {
			anchors.fill: parent
			ListView {
				id: restoreList
				anchors.fill: parent
				model: streamRestoreModel
				delegate: RowLayout {
					width: ListView.view.width
					spacing: 8
					Controls.Label {
						text: model.Name || ""
						Layout.preferredWidth: restoreList.width * 0.4
						elide: Text.ElideRight
					}
					Controls.Label {
						text: model.Device || ""
						Layout.fillWidth: true
						elide: Text.ElideRight
					}
				}
			}
		}
	}
}
