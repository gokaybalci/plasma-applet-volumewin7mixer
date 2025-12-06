import QtQuick 6.5
import QtQuick.Controls 6.5 as Controls
import org.kde.plasma.plasmoid

Item {
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string version: plasmoid?.metaData?.version || "?"

    Controls.Label {
        id: label
        text: i18n("<b>Version:</b> %1", version)
    }
}
