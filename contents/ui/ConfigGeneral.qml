/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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

//import QtQuick 2.15
//import QtQuick.Controls 2.15
//import QtQuick.Dialogs 1.2
//import QtQuick.Layouts 1.0
//import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
//import org.kde.draganddrop 2.0 as DragDrop
//import org.kde.kirigami 2.4 as Kirigami

import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.5 as Kirigami
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM



KCM.SimpleKCM {
    id: configGeneral


    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage
    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_numberRows: numberRows.value

    property alias cfg_labels2lines: labels2lines.checked

    property alias cfg_appsIconSize: appsIconSize.currentIndex
    property alias cfg_docsIconSize: docsIconSize.currentIndex
    property alias cfg_displayPosition: displayPosition.currentIndex
    property alias cfg_allAppsViewMode: allAppsViewMode.currentIndex
    property alias cfg_allAppsSortMode: allAppsSortMode.currentIndex
    property alias cfg_showRecentDocs: showRecentDocsCb.checked
    property alias cfg_showRecentApps: showRecentAppsCb.checked
    property alias cfg_enableShellRunner: enableShellRunnerCb.checked
    property alias cfg_showQuickActions: showQuickActionsCb.checked
    property alias cfg_showSleepButton: showSleepCb.checked
    property alias cfg_showRestartButton: showRestartCb.checked
    property alias cfg_showShutdownButton: showShutdownCb.checked
    property alias cfg_showWeather: showWeatherCb.checked
    property alias cfg_weatherLocation: weatherLocationCombo.currentIndex
    property alias cfg_weatherLatitude: weatherLatitudeField.value
    property alias cfg_weatherLongitude: weatherLongitudeField.value

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Button {
            id: iconButton

            Kirigami.FormData.label: i18n("Symbol:")

            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2

            // Just to provide some visual feedback when dragging;
            // cannot have checked without checkable enabled
            checkable: true
            checked: dropArea.containsAcceptableDrag

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            DragDrop.DropArea {
                id: dropArea

                property bool containsAcceptableDrag: false

                anchors.fill: parent

                onDragEnter: {
                    // Cannot use string operations (e.g. indexOf()) on "url" basic type.
                    var urlString = event.mimeData.url.toString();

                    // This list is also hardcoded in KIconDialog.
                    var extensions = [".png", ".xpm", ".svg", ".svgz"];
                    containsAcceptableDrag = urlString.indexOf("file:///") === 0 && extensions.some(function (extension) {
                        return urlString.indexOf(extension) === urlString.length - extension.length; // "endsWith"
                    });

                    if (!containsAcceptableDrag) {
                        event.ignore();
                    }
                }
                onDragLeave: containsAcceptableDrag = false

                onDrop: {
                    if (containsAcceptableDrag) {
                        // Strip file:// prefix, we already verified in onDragEnter that we have only local URLs.
                        iconDialog.setCustomButtonImage(event.mimeData.url.toString().substr("file://".length));
                    }
                    containsAcceptableDrag = false;
                }
            }

            KIconThemes.IconDialog {
                id: iconDialog

                function setCustomButtonImage(image) {
                    configGeneral.cfg_customButtonImage = image || configGeneral.cfg_icon || "start-here-kde-symbolic"
                    configGeneral.cfg_useCustomButtonImage = true;
                }

                onIconNameChanged: setCustomButtonImage(iconName);
            }

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: Plasmoid.location === PlasmaCore.Types.Vertical || Plasmoid.location === PlasmaCore.Types.Horizontal
                           ? "widgets/panel-background" : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: configGeneral.cfg_useCustomButtonImage ? configGeneral.cfg_customButtonImage : configGeneral.cfg_icon
                }
            }

            Menu {
                id: iconMenu

                // Appear below the button
                y: +parent.height

                onClosed: iconButton.checked = false;

                MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Auswählen …")
                    icon.name: "document-open-folder"
                    onClicked: iconDialog.open()
                }
                MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Symbol zurücksetzen")
                    icon.name: "edit-clear"
                    onClicked: {
                        configGeneral.cfg_icon = "start-here-kde-symbolic"
                        configGeneral.cfg_useCustomButtonImage = false
                    }
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        ComboBox {
            id: appsIconSize
            Kirigami.FormData.label: i18n("Symbolgröße Apps:")
            Layout.fillWidth: true
            model: [i18n("Klein"),i18n("Mittel"),i18n("Groß"), i18n("Riesig")]
        }

        ComboBox {
            id: docsIconSize
            Kirigami.FormData.label: i18n("Symbolgröße Dokumente:")
            Layout.fillWidth: true
            model: [i18n("Klein"),i18n("Mittel"),i18n("Groß"), i18n("Riesig")]
        }


        ComboBox {

            Kirigami.FormData.label: i18n("Menüposition")
            id: displayPosition
            model: [
                i18n("Standard"),
                i18n("Mitte"),
                i18n("Mitte unten"),
            ]
            //onActivated: cfg_displayPosition = currentIndex
        }


        CheckBox {
            id: labels2lines
            text: i18n("Beschriftungen zweizeilig anzeigen")
            visible: true
        }

        SpinBox{
            id: numberColumns

            from: 3
            to: 15
            Kirigami.FormData.label: i18n("Anzahl der Spalten")

        }

        SpinBox{
            id: numberRows
            from: 1
            to: 15
            Kirigami.FormData.label: i18n("Anzahl der Zeilen")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Alle Apps")
        }

        CheckBox {
            id: showRecentDocsCb
            Kirigami.FormData.label: i18n("Zuletzt verwendete Dokumente:")
            text: i18n("Bereich „Zuletzt verwendet“ anzeigen")
        }

        ComboBox {
            id: allAppsViewMode
            Kirigami.FormData.label: i18n("Standard-Ansicht:")
            Layout.fillWidth: true
            model: [i18n("Liste"), i18n("Raster"), i18n("Kategorien")]
        }

        ComboBox {
            id: allAppsSortMode
            Kirigami.FormData.label: i18n("Standard-Sortierung:")
            Layout.fillWidth: true
            model: [i18n("A → Z"), i18n("Z → A"), i18n("Neueste"), i18n("Älteste"), i18n("Nach Typ")]
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Suchen")
        }

        CheckBox {
            id: showRecentAppsCb
            Kirigami.FormData.label: i18n("Startseite:")
            text: i18n("Zuletzt geöffnete Apps anzeigen")
        }

        CheckBox {
            id: enableShellRunnerCb
            text: i18n("Shell-Befehle ausführen ( > Befehl )")
        }

        CheckBox {
            id: showQuickActionsCb
            text: i18n("Schnellaktionen anzeigen (Bildschirmfoto, Sperren, Terminal …)")
        }

        CheckBox {
            id: showWeatherCb
            text: i18n("Wetter-Widget anzeigen (benötigt Internet)")
        }

        ComboBox {
            id: weatherLocationCombo
            Kirigami.FormData.label: i18n("Wetter-Standort:")
            Layout.fillWidth: true
            model: [
                i18n("Paris"),
                i18n("London"),
                i18n("New York"),
                i18n("Tokio"),
                i18n("Sydney"),
                i18n("Johannesburg"),
                i18n("Dubai"),
                i18n("Singapur"),
                i18n("Hongkong"),
                i18n("Bangkok"),
                i18n("Mumbai"),
                i18n("Kairo"),
                i18n("São Paulo"),
                i18n("Mexiko-Stadt"),
                i18n("Toronto"),
                i18n("Los Angeles"),
                i18n("Berlin"),
                i18n("Moskau"),
                i18n("Istanbul"),
                i18n("Benutzerdefiniert")
            ]
            onCurrentIndexChanged: {
                var locations = [
                    {lat: 48.8566, lon: 2.3522},      // Paris
                    {lat: 51.5074, lon: -0.1278},     // London
                    {lat: 40.7128, lon: -74.0060},    // New York
                    {lat: 35.6762, lon: 139.6503},    // Tokyo
                    {lat: -33.8688, lon: 151.2093},   // Sydney
                    {lat: -26.2023, lon: 28.0436},    // Johannesburg
                    {lat: 25.2048, lon: 55.2708},     // Dubai
                    {lat: 1.3521, lon: 103.8198},     // Singapore
                    {lat: 22.3193, lon: 114.1694},    // Hong Kong
                    {lat: 13.7563, lon: 100.5018},    // Bangkok
                    {lat: 28.6139, lon: 77.2090},     // Mumbai
                    {lat: 30.0444, lon: 31.2357},     // Cairo
                    {lat: -23.5505, lon: -46.6333},   // São Paulo
                    {lat: 19.4326, lon: -99.1332},    // Mexico City
                    {lat: 43.6629, lon: -79.3957},    // Toronto
                    {lat: 34.0522, lon: -118.2437},   // Los Angeles
                    {lat: 52.5200, lon: 13.4050},     // Berlin
                    {lat: 55.7558, lon: 37.6173},     // Moscow
                    {lat: 41.0082, lon: 28.9784},     // Istanbul
                    {lat: 0, lon: 0}                   // Custom (placeholder)
                ];
                if (currentIndex < locations.length && currentIndex !== locations.length - 1) {
                    weatherLatitudeField.value = locations[currentIndex].lat;
                    weatherLongitudeField.value = locations[currentIndex].lon;
                    configGeneral.cfg_weatherLatitude = locations[currentIndex].lat;
                    configGeneral.cfg_weatherLongitude = locations[currentIndex].lon;
                }
            }
        }

        SpinBox {
            id: weatherLatitudeField
            Kirigami.FormData.label: i18n("Eigener Breitengrad:")
            from: -90
            to: 90
            value: 48
            editable: true
            visible: weatherLocationCombo.currentIndex === weatherLocationCombo.model.length - 1
        }

        SpinBox {
            id: weatherLongitudeField
            Kirigami.FormData.label: i18n("Eigener Längengrad:")
            from: -180
            to: 180
            value: 2
            editable: true
            visible: weatherLocationCombo.currentIndex === weatherLocationCombo.model.length - 1
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Energie-Schaltflächen in der Fußleiste")
        }

        CheckBox {
            id: showSleepCb
            Kirigami.FormData.label: i18n("Anzeigen:")
            text: i18n("Energie sparen / Standby")
        }

        CheckBox {
            id: showRestartCb
            text: i18n("Neu starten")
        }

        CheckBox {
            id: showShutdownCb
            text: i18n("Herunterfahren")
        }

        RowLayout{

            visible: false
            Button {
                text: i18n("Alle ausgeblendeten Anwendungen wieder einblenden")
                onClicked: {
                    plasmoid.configuration.hiddenApplications = [""];
                    unhideAllAppsPopup.text = i18n("Wieder eingeblendet!");
                }
            }
            Label {
                id: unhideAllAppsPopup
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Info")
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: i18n("Version: 1.0.0 (basiert auf Menu 11 Next 1.3)")
                Layout.fillWidth: true
            }

        }

    }
}
