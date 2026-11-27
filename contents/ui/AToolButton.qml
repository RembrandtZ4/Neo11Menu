/*
    Kleiner Knopf wie „Alle >“ im Windows-11-Startmenü:
    dezent getönte Fläche ohne harten Rahmen, beim Drüberfahren etwas heller.
    flat: true = ganz ohne Fläche, nur beim Drüberfahren sichtbar.
*/
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Rectangle {
    id: item

    property int buttonHeight: Math.floor(Kirigami.Units.gridUnit * 2)
    property alias text: lb.text
    property bool flat: false
    property alias iconName: icon.source
    // true = Symbol links vom Text (z. B. „< Zurück“)
    property bool mirror: false

    signal clicked

    implicitHeight: buttonHeight
    implicitWidth: row.implicitWidth + Kirigami.Units.largeSpacing * 2

    readonly property bool hot: mouseItem.containsMouse || item.activeFocus
    readonly property color tint: Kirigami.Theme.textColor

    radius: 4
    color: {
        var a = flat ? (mouseItem.pressed ? 0.05 : hot ? 0.08 : 0.0)
                     : (mouseItem.pressed ? 0.04 : hot ? 0.10 : 0.06);
        return Qt.rgba(tint.r, tint.g, tint.b, a);
    }
    border.width: flat ? 0 : 1
    border.color: Qt.rgba(tint.r, tint.g, tint.b, 0.05)

    Behavior on color {
        ColorAnimation {
            duration: Kirigami.Units.shortDuration
        }
    }

    activeFocusOnTab: true
    Keys.onSpacePressed: item.clicked()
    Keys.onReturnPressed: item.clicked()

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing
        LayoutMirroring.enabled: item.mirror

        PC3.Label {
            id: lb
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
            opacity: mouseItem.pressed ? 0.7 : 0.9
        }

        Kirigami.Icon {
            id: icon
            implicitHeight: Kirigami.Units.iconSizes.small * 0.75
            implicitWidth: implicitHeight
            opacity: lb.opacity
            roundToIconSize: false
            visible: source !== ""
        }
    }

    MouseArea {
        id: mouseItem
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: item.clicked()
    }
}
