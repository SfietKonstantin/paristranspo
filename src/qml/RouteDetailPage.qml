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
    property alias model: view.model

    ListView {
        id: view
        anchors.fill: parent
        header: Column {
            width: view.width
            PageHeader {
                //: Title for route detail page
                //% "Details"
                title: qsTrId("paristranspo-details")
            }

            Rectangle {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                height: dateColumn.height + 2 * Theme.paddingSmall
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)

                Column {
                    id: dateColumn
                    property string departureDate: container.model.route == null ? "" : Qt.formatTime(container.model.route.departureDate, "hh:mm")
                    property string arrivalDate: container.model.route == null ? "" : Qt.formatTime(container.model.route.arrivalDate, "hh:mm")
                    property string zones: container.model.route == null ? "" : container.model.route.zones
                    anchors.top: parent.top; anchors.topMargin: Theme.paddingSmall
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: time.left; anchors.rightMargin: Theme.paddingMedium

                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       //: Departure time text
                                                       //% "Departure"
                                                       qsTrId("paris-transpo-departure"),
                                                       dateColumn.departureDate)
                    }
                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       //: Arrival time text
                                                       //% "Arrival"
                                                       qsTrId("paris-transpo-arrival"),
                                                       dateColumn.arrivalDate)
                    }
                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       //: Zones
                                                       //% "Zones"
                                                       qsTrId("paris-transpo-walking-zones"),
                                                       dateColumn.zones)
                    }
                }

                Label {
                    id: time
                    property int totalTime: container.model.route == null ? -1 : container.model.route.totalTime
                    anchors.verticalCenter: dateColumn.verticalCenter
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    font.pixelSize: Theme.fontSizeLarge
                    //: Time suffix (minutes)
                    //% "%1 min"
                    text: qsTrId("paris-transpo-min").arg(time.totalTime)
                }
            }
        }

        delegate: Column {
            width: view.width
            LocationIndicator {
                anchors.left: parent.left; anchors.right: parent.right
                highlighted: model.index == 0
                time: model.data.departureTime
                place: model.data.departurePlace
            }
            Item {
                width: view.width
                height: Math.max(iconsRow.height, column.height)
                Row {
                    id: iconsRow
                    anchors.left: parent.left; anchors.leftMargin: Theme.iconSizeMedium
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall
                    Image {
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        source: ParisTranspo.modeIcon(model.modelData.type)
                    }
                    Item {
                        width: text.visible ? text.width : lineIcon.width
                        height: Theme.iconSizeSmall
                        Label {
                            id: text
                            anchors.top: parent.top; anchors.bottom: parent.bottom
                            verticalAlignment: Text.AlignVCenter
                            visible: lineIcon.status != Image.Ready
                            text: model.modelData.lineCode
                            font.pixelSize: Theme.fontSizeTiny
                        }

                        Image {
                            id: lineIcon
                            width: Theme.iconSizeSmall
                            height: Theme.iconSizeSmall
                            source: ParisTranspo.modeLineIcon(model.modelData)
                        }
                    }

                }

                Column {
                    id: column
                    anchors.left: iconsRow.right; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium

                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        visible: model.data.type != Mode.Walking
                        font.pixelSize: Theme.fontSizeTiny
                        truncationMode: TruncationMode.Fade
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       //: Indicate some transportation to be taken
                                                       //% "Take"
                                                       qsTrId("paris-transpo-take"),
                                                       model.data.network + " " + model.data.line)
                    }

                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        visible: model.data.type != Mode.Walking
                        font.pixelSize: Theme.fontSizeTiny
                        truncationMode: TruncationMode.Fade
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       //: Indicate some direction to be taken
                                                       //% "To"
                                                       qsTrId("paris-transpo-direction"),
                                                       model.data.direction)
                    }

                    Row {
                        visible: model.data.type == Mode.Walking
                        spacing: Theme.paddingMedium
                        Label {
                            font.pixelSize: Theme.fontSizeTiny
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTrId("paris-transpo-min").arg(model.data.walkingTime)
                        }

                        Image {
                            visible: model.data.waitingTime > 0
                            width: Theme.iconSizeSmall
                            height: Theme.iconSizeSmall
                            source: ParisTranspo.modeIcon(Mode.Waiting)
                        }

                        Label {
                            visible: model.data.waitingTime > 0
                            font.pixelSize: Theme.fontSizeTiny
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTrId("paris-transpo-min").arg(model.data.waitingTime)
                        }
                    }
                }
            }
        }

        footer: LocationIndicator {
            width: view.width
            highlighted: true
            time: container.model.route == null ? null : container.model.route.arrivalDate
            place: container.model.route == null ? "" : container.model.route.to.name
        }
    }
}
