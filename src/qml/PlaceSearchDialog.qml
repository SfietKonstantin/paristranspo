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

Dialog {
    id: container
    property int position: ParisTranspo.UnknownPosition
    signal placeSelected(int position, var place)
    canAccept: view.currentIndex != -1
    onAccepted: {
        placeSelected(position, model.getData(view.currentIndex))
    }

    SilicaListView {
        id: view
        property int currentSelected: -1
        anchors.fill: parent
        currentIndex: -1
        model: PlaceSearchModel {
            id: model
            onTextChanged: view.currentIndex = -1
        }

        header: Column {
            width: view.width
            DialogHeader {
                //: Accept text for the place search dialog
                //% "Select place"
                title: qsTrId("paristranspo-place-select")
            }
            SearchField {
                id: searchField
                anchors.left: parent.left; anchors.right: parent.right
            }

            Binding { target: model; property: "text"; value: searchField.text }
        }

//        section.property: "section"
//        section.delegate: SectionHeader {)
//            text: section
//        }

        delegate: BackgroundItem {
            Label {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                text: model.data.name
                truncationMode: TruncationMode.Fade
                color: model.index == view.currentIndex ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: view.currentIndex = model.index
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: model.text.trim().length == 0
            //: Text shown on the place search placeholder, to ask the user to search for a place
            //% "Search for a place"
            text: qsTrId("paristranspo-place-empty")
        }

        ViewPlaceholder {
            enabled: model.status == PlaceSearchModel.Error
            //: Text shown on the place search placeholder, to notify an error
            //% "An error happened. Check your internet connection and search again."
            text: qsTrId("paristranspo-place-error")
        }

        BusyIndicator {
            visible: model.status == PlaceSearchModel.Loading
            running: visible
            anchors.centerIn: parent
        }
    }

}
