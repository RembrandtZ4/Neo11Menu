/***************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                   *
 *   Neo11-Startbutton (C) 2026 RembrandtZ4                                *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami


Item {
    id: root

    readonly property var screenGeometry: plasmoid.screenGeometry
    readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
                                     || plasmoid.location == PlasmaCore.Types.RightEdge
                                     || plasmoid.location == PlasmaCore.Types.BottomEdge
                                     || plasmoid.location == PlasmaCore.Types.LeftEdge)
    readonly property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (Plasmoid.configuration.useCustomButtonImage
                                                  && Plasmoid.configuration.customButtonImage.length != 0)
    property QtObject dashWindow: null

    // Neo11-Startbutton: 3×3 flache, abgerundete Kacheln
    readonly property bool useNeoButton: Plasmoid.configuration.useNeoButton && !useCustomButtonImage
    readonly property bool menuOpen: dashWindow ? dashWindow.visible : false
    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed

    // Kachelfarbe folgt dem Plasma-Design (hell auf dunkler Leiste, dunkel auf heller Leiste)
    readonly property color baseColor: Kirigami.Theme.textColor
    readonly property color tileColor: (hovered || menuOpen)
                                       ? baseColor
                                       : Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.82)

    Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    // Klassisches Symbol (nur, wenn der Neo11-Button abgeschaltet oder ein eigenes Bild gewählt ist)
    Kirigami.Icon {
        id: buttonIcon

        anchors.fill: parent
        visible: !root.useNeoButton
        source: useCustomButtonImage ? Plasmoid.configuration.customButtonImage : Plasmoid.configuration.icon
        active: mouseArea.containsMouse
        smooth: true
    }

    // Dezente Fläche hinter dem Button – wie bei Windows 11
    Rectangle {
        id: hoverBackground

        visible: root.useNeoButton
        anchors.centerIn: parent
        width: Math.round(Math.min(parent.width, parent.height) * 0.92)
        height: width
        radius: Math.round(width * 0.16)
        color: root.baseColor
        opacity: root.pressed ? 0.06 : ((root.hovered || root.menuOpen) ? 0.11 : 0.0)

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: neoButton

        // Kachelmaß: 3 Kacheln à 7 Teile + 2 Lücken à 3 Teile = 27 Teile
        readonly property real tile: width * 7 / 27
        readonly property real gap: width * 3 / 27

        property real glow: (root.hovered && !root.pressed) ? 0.55 : 0.0

        visible: root.useNeoButton
        anchors.centerIn: parent
        width: Math.round(Math.min(parent.width, parent.height) * 0.58)
        height: width

        scale: root.pressed ? 0.88 : (root.hovered ? 1.1 : 1.0)

        Behavior on scale {
            NumberAnimation { duration: 170; easing.type: Easing.OutBack }
        }
        Behavior on glow {
            NumberAnimation { duration: 170; easing.type: Easing.OutCubic }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: root.baseColor
            shadowOpacity: neoButton.glow
            shadowBlur: 0.7
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 0
        }

        Repeater {
            model: 9

            Rectangle {
                x: (index % 3) * (neoButton.tile + neoButton.gap)
                y: Math.floor(index / 3) * (neoButton.tile + neoButton.gap)
                width: neoButton.tile
                height: neoButton.tile
                radius: neoButton.tile * 0.28
                antialiasing: true
                color: root.tileColor

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
            }
        }
    }

    MouseArea
    {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            dashWindow.visible = !dashWindow.visible;
        }
    }

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("MenuRepresentation {}", root);
        plasmoid.activated.connect(function() {
            dashWindow.visible = !dashWindow.visible;
        });
    }
}
