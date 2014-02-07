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

    RouteDetailModel {
        id: routeDetailModel
        routeSearchModel: view.model
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        model: routeSearchModel
        spacing: Theme.paddingMedium
        header: PageHeader {
            //: Title for routes page
            //% "Routes"
            title: qsTrId("paristranspo-route")
        }

        delegate: Item {
            width: view.width
            height: background.height

            Rectangle {
                anchors.fill: background
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
            }

            BackgroundItem {
                id: background
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                height: typeLabel.height + dateColumn.height
                        + Theme.paddingMedium + 2 * Theme.paddingSmall

                Label {
                    id: typeLabel
                    color: Theme.highlightColor
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    anchors.top: parent.top; anchors.topMargin: Theme.paddingSmall
                    text: ParisTranspo.routeType(model.data.type)
                }

                Row {
                    id: mode
                    anchors.top: parent.top; anchors.topMargin: Theme.paddingSmall
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    property var route: model.data
                    spacing: Theme.paddingSmall
                    Repeater {
                        model: ParisTranspo.processedModes(mode.route)
                        Item {
                            width: Theme.iconSizeSmall
                            height: Theme.iconSizeSmall

                            Image {
                                width: Theme.iconSizeSmall
                                height: Theme.iconSizeSmall
                                source: ParisTranspo.modeIcon(model.modelData.type)
                                visible: lineIcon.status != Image.Ready
                            }
                            Image {
                                id: lineIcon
                                width: Theme.iconSizeSmall
                                height: Theme.iconSizeSmall
                                source: ParisTranspo.modeLineIcon(model.modelData)
                                visible: status != Image.Error
                            }
                        }
                    }
                }

                Column {
                    id: dateColumn
                    anchors.top: typeLabel.bottom; anchors.topMargin: Theme.paddingMedium
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                    anchors.right: time.left; anchors.rightMargin: Theme.paddingMedium

                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       qsTrId("paris-transpo-departure"),
                                                       Qt.formatTime(model.data.departureDate, "hh:mm"))
                    }
                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                                                       qsTrId("paris-transpo-arrival"),
                                                       Qt.formatTime(model.data.arrivalDate, "hh:mm"))
                    }
                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                        //: Walking time
                        //% "Walking time"
                                                       qsTrId("paris-transpo-walking-time"),
                                                       qsTrId("paris-transpo-min").arg(model.data.walkingTime))
                    }
                }

                Label {
                    id: time
                    anchors.verticalCenter: dateColumn.verticalCenter
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                    font.pixelSize: Theme.fontSizeLarge
                    text: qsTrId("paris-transpo-min").arg(model.data.totalTime)
                }

                onClicked: {
                    routeDetailModel.routeType = model.data.type
                    routeDetailModel.search()
                    pageStack.push(Qt.resolvedUrl("RouteDetailPage.qml"),
                                   {"model": routeDetailModel})
                }
            }
        }
    }

    BusyIndicator {
        visible: container.model.status == RouteSearchModel.Loading
        running: visible
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}
