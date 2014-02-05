import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.paristranspo 1.0

Page {
    id: container
    property alias model: view.model

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
                                source: ParisTranspo.modeIcon(model.modelData)
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
                        //: Departure time text
                        //% "Departure"
                                                       qsTrId("paris-transpo-departure"),
                                                       Qt.formatTime(model.data.departureDate, "hh:mm"))
                    }
                    Label {
                        anchors.left: parent.left; anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        textFormat: Text.RichText
                        text: ParisTranspo.coloredText(Theme.highlightColor,
                        //: Arrival time text
                        //% "Arrival"
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
                                                       //: Time suffix (minutes)
                                                       //% "%1 min"
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
