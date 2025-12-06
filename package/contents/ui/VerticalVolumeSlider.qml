import QtQuick 6.5
import QtQuick.Controls 6.5 as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

// Simplified vertical slider using QQC2/PlasmaComponents for Plasma 6
PlasmaComponents.Slider {
    id: slider
    anchors.fill: parent
    orientation: Qt.Vertical

    // Compatibility properties with the previous implementation
    property real hundredPercentValue: 65536
    property real minimumValue: 0
    property real maximumValue: hundredPercentValue * 1.05
    property bool isVolumeBoosted: value > hundredPercentValue
    property bool isBoostable: maximumValue > hundredPercentValue
    readonly property int percentage: Math.round(value / hundredPercentValue * 100)
    readonly property int maxPercentage: Math.ceil(maximumValue / hundredPercentValue * 100)
    property bool showPercentageLabel: true
    property bool showVisualFeedback: plasmoid.configuration.showVisualFeedback
    property bool ignoreValueChanges: false

    from: minimumValue
    to: maximumValue

    // Keep the peak loader so the parent can still read peak data even though
    // the custom groove visuals from Plasma 5 were removed.
    readonly property bool isPeaking: volumePeakLoader.active && volumePeakLoader.item
    readonly property real peakValue: isPeaking ? volumePeakLoader.item.defaultSinkPeak : hundredPercentValue
    readonly property real peakRatio: peakValue / hundredPercentValue

    Loader {
        id: volumePeakLoader
        property bool validType: mixerItem.mixerItemType === "Sink"
            || mixerItem.mixerItemType === "Source"
            || mixerItem.mixerItemType === "SinkInput"
        active: showVisualFeedback && validType
        source: "VolumePeaksManager.qml"

        onStatusChanged: {
            if (status === Loader.Error && plasmoid.configuration.showVisualFeedback) {
                plasmoid.configuration.showVisualFeedback = false
            }
        }
    }
}
