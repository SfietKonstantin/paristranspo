/*
 * Copyright (C) 2014 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * The names of its contributors may not be used to endorse or promote
 *     products derived from this software without specific prior written
 *     permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.paristranspo 1.0

Page {
    id: container    
    RouteSearchModel {
        id: routeSearchModel
        manager: manager
        Component.onCompleted: ParisTranspo.initDate(routeSearchModel)
    }

    SilicaFlickable {
        id: flickable
        function validate(position, place) {
            ParisTranspo.setPlace(routeSearchModel,position, place)
        }

        function openPlaceSearchDialog(position) {
            var page = pageStack.push(Qt.resolvedUrl("PlaceSearchDialog.qml"),
                                      {"position": position})
            page.position = position
            page.placeSelected.connect(validate)
        }

        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column
            anchors.left: parent.left; anchors.right: parent.right

            PageHeader {
                //: Name of the application
                //% "Paris-Transpo"
                title: qsTrId("paristranspo-name")
            }

            SectionHeader {
                //: A section that indicates the route category: departure and arrival
                //% "Routing"
                text: qsTrId("paristranspo-routing")
            }

            BackgroundItem {
                Label {
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    //: Placeholder for the departure field
                    //% "Departure"
                    text: routeSearchModel.departure == null ? qsTrId("paristranspo-departure")
                                                             : routeSearchModel.departure.name
                }
                onClicked: flickable.openPlaceSearchDialog(ParisTranspo.Departure)
            }

            BackgroundItem {
                Label {
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    //: Placeholder for the arrival field
                    //% "Arrival"
                    text: routeSearchModel.arrival == null ? qsTrId("paristranspo-arrival")
                                                           : routeSearchModel.arrival.name
                }
                onClicked: flickable.openPlaceSearchDialog(ParisTranspo.Arrival)
            }

            Item {
                anchors.left: parent.left; anchors.right: parent.right
                height: Theme.itemSizeSmall

                BackgroundItem {
                    anchors.left: parent.left; anchors.right: parent.horizontalCenter

                    Image {
                        id: date
                        anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-s-date"
                    }

                    Label {
                        anchors.left: date.right; anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDate(routeSearchModel.date)
                    }
                    onClicked: {
                        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog",
                                                    { date: routeSearchModel.date})

                        dialog.accepted.connect(function() {
                            ParisTranspo.setDate(routeSearchModel, dialog.date)
                        })
                    }
                }

                BackgroundItem {
                    anchors.left: parent.horizontalCenter; anchors.right: parent.right

                    Image {
                        id: time
                        anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-s-time"
                    }

                    Label {
                        anchors.left: time.right; anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatTime(routeSearchModel.date, "hh:mm")
                    }

                    onClicked: {
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog",
                                                    {hour: routeSearchModel.date.getHours(),
                                                     minute: routeSearchModel.date.getMinutes()})

                        dialog.accepted.connect(function() {
                            ParisTranspo.setTime(routeSearchModel, dialog.time)
                        })
                    }
                }
            }

            SectionHeader {
                //: A section header for preferences for the journey
                //% "Preferences"
                text: qsTrId("paristranspo-preferences")
            }

            ListItem {
                menu: ContextMenu {
                    Repeater {
                        model: ListModel {
                            ListElement {
                                //: Entry for using train
                                //% "Train"
                                text: QT_TRID_NOOP("paristranspo-use-train")
                                property: "useTrain"
                            }
                            ListElement {
                                //: Entry for using RER
                                //% "RER"
                                text: QT_TRID_NOOP("paristranspo-use-rer")
                                property: "useRer"
                            }
                            ListElement {
                                //: Entry for using metro
                                //% "Metro"
                                text: QT_TRID_NOOP("paristranspo-use-metro")
                                property: "useMetro"
                            }
                            ListElement {
                                //: Entry for using tram
                                //% "Tram"
                                text: QT_TRID_NOOP("paristranspo-use-tram")
                                property: "useTram"
                            }
                            ListElement {
                                //: Entry for using bus
                                //% "Bus"
                                text: QT_TRID_NOOP("paristranspo-use-bus")
                                property: "useBus"
                            }
                        }
                        delegate: TextSwitch {
                            id: modeSwitch
                            text: qsTrId(model.text)
                            property bool prepared: false
                            Binding {
                                target: routeSearchModel
                                property: model.property
                                value: modeSwitch.checked
                                when: modeSwitch.prepared
                            }

                            Component.onCompleted: {
                                modeSwitch.checked = routeSearchModel[model.property]
                                modeSwitch.prepared = true
                            }
                        }
                    }
                }

                Label {
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    //: Modes field
                    //% "Modes"
                    text: qsTrId("paristranspo-modes")
                }
                onClicked: !menuOpen ? showMenu() : hideMenu()
            }

            ListItem {
                showMenuOnPressAndHold: false
                menu: ContextMenu {
                    Repeater {
                        model: ListModel {
                            ListElement {
                                speed: RouteSearchModel.Slow
                            }
                            ListElement {
                                speed: RouteSearchModel.Normal
                            }
                            ListElement {
                                speed: RouteSearchModel.Fast
                            }
                        }
                        delegate: MenuItem {
                            text: ParisTranspo.walkSpeed(model.speed)
                            color: routeSearchModel.walkSpeed != model.speed ? Theme.primaryColor
                                                                             : Theme.highlightColor
                            onClicked: routeSearchModel.walkSpeed = model.speed
                        }
                    }
                }

                Label {
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    text: ParisTranspo.walkSpeed(routeSearchModel.walkSpeed)
                }
                onClicked: !menuOpen ? showMenu() : hideMenu()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: (routeSearchModel.departure != null && routeSearchModel.arrival != null)
                //: Button to search for a journey
                //% "Search"
                text: qsTrId("paristranspo-search")
                onClicked: {
                    routeSearchModel.search()
                    pageStack.push(Qt.resolvedUrl("RouteSearchPage.qml"),
                                   {"model": routeSearchModel})
                }
            }
        }
    }
}
