/*
    Eigenes Infofenster (Tooltip) im Stil von Windows 11.

    Der Plasma-ToolTip übernimmt seinen Hintergrund aus dem Plasma-Stil – bei manchen
    Stilen ist der weiß, obwohl die Schrift hell ist. Dieses Infofenster zeichnet sich
    selbst in den Farben des Menüs und hängt sich dafür direkt ins Menüfenster,
    damit es nicht von Listen abgeschnitten wird.

    Verwendung (als Kind eines Knopfes):
        NeoToolTip { text: "Herunterfahren" }
    Optional: active (Standard: parent.hovered), delay, timeout
*/
import QtQuick
import QtQuick.Window
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: tip

    property string text: ""
    property bool active: parent ? parent.hovered === true : false
    property int delay: 600
    property int timeout: 0

    readonly property Item target: parent

    width: 0
    height: 0

    Timer {
        id: showTimer
        interval: tip.delay
        onTriggered: tip.open()
    }

    Timer {
        id: hideTimer
        interval: tip.timeout > 0 ? tip.timeout : 1000
        onTriggered: bubble.shown = false
    }

    onActiveChanged: {
        if (active && text !== "") {
            showTimer.restart();
        } else {
            showTimer.stop();
            hideTimer.stop();
            bubble.shown = false;
        }
    }

    function open() {
        const win = target ? target.Window.window : null;
        if (!win || !win.contentItem || !active) {
            return;
        }
        const area = win.contentItem;
        bubble.parent = area;
        const top = target.mapToItem(area, target.width / 2, 0);
        bubble.x = Math.round(Math.max(4, Math.min(top.x - bubble.width / 2, area.width - bubble.width - 4)));
        let y = top.y - bubble.height - 6;
        if (y < 4) {
            y = target.mapToItem(area, 0, target.height).y + 6;
        }
        bubble.y = Math.round(y);
        bubble.shown = true;
        if (timeout > 0) {
            hideTimer.restart();
        }
    }

    Rectangle {
        id: bubble

        property bool shown: false

        z: 100000
        visible: opacity > 0
        opacity: shown ? 1 : 0
        width: label.implicitWidth + Kirigami.Units.largeSpacing * 2
        height: label.implicitHeight + Kirigami.Units.smallSpacing * 3
        radius: 5
        // Etwas heller als der Menühintergrund, feiner Rand – wie die Infofenster von Windows 11
        color: Qt.tint(Kirigami.Theme.backgroundColor,
                       Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08))
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.14)

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
            }
        }

        PC3.Label {
            id: label
            anchors.centerIn: parent
            text: tip.text
            color: Kirigami.Theme.textColor
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
        }
    }
}
