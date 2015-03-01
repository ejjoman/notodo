/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"
import "../js/utils.js" as Utils
import "../common"

NoteBasePage {
    id: root
    objectName: "TodoPage"

    property alias model: todoModel

    type: "todo"

    SilicaListView {
        id: todoList
        clip: true

        NotePagePullDownMenu {
            basePage: root
            todoModel: todoModel
        }

        header: PageHeader {
            title: {
                if (root.noteIndex >= 0)
                    return root.title;

                if (root.title.trim() != "")
                    return root.title.trim();

                if (root.type == "note")
                    return qsTr("New note")

                return qsTr("New to-do")
            }
        }

        //add:

        move: MoveTransition {}
        displaced: MoveTransition {}

        model: todoModel

        anchors {
            fill: parent
            bottomMargin: panel.height
        }
        visible: root.isTodo

        delegate: Item {
            id: listItem

            property alias backgroundRectAnimation: backgroundRectAnimation
            readonly property int index: model.index

            height: Theme.itemSizeSmall
            width: parent.width

            Rectangle {
                id: backgroundRect
                color: Theme.highlightColor

                z: -1
                anchors.fill: parent

                opacity: 0

                PropertyAnimation {
                    id: backgroundRectAnimation

                    target: backgroundRect
                    property: "opacity"
                    from: .7
                    to: 0
                    duration: 300
                }
            }

            MouseArea {
                id: checkMarkerMouseArea

                readonly property bool down: pressed && containsMouse

                width: checkMarker.width + 2 * Theme.paddingLarge
                height: parent.height

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }

                onClicked: todoModel.updateCheckedStatus(model.index, !checkMarker.checked)

                Rectangle {
                    width: 1
                    color: Theme.primaryColor
                    opacity: .3

                    height: parent.height
                    anchors.left: parent.left
                }

                CheckMarker {
                    id: checkMarker
                    animationDuration: 150
                    anchors.centerIn: parent
                    checked: model.checked
                    checkmarkColor: checkMarkerMouseArea.down ? Theme.highlightColor : Theme.primaryColor
                }
            }

            TextField {
                id: textField

                property bool _initialized: false

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: checkMarkerMouseArea.left
                }

                font.strikeout: checkMarker.checked

                labelVisible: false
                background: null
                color: checkMarkerMouseArea.down ? Theme.highlightColor : Theme.primaryColor
                text: model.text

                onTextChanged: {
                    if (!_initialized)
                        return;

                    todoModel.updateText(model.index, text);
                }

                EnterKey.onClicked: {
                    if (text === '')
                        todoModel.remove(model.index);
                    else
                        todoModel.insert(model.index + 1, {checked: false, text:''})
                }

                EnterKey.highlighted: true
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"

                Component.onCompleted: {
                    _initialized = true;
                }
            }
        }

        VerticalScrollDecorator {}
    }

    Item {
        id: panel

        width: parent.width
        height: newEntryField.height + Theme.paddingLarge

        anchors.bottom: parent.bottom

        TextField {
            id: newEntryField
            width: parent.width

            anchors {
                verticalCenter: parent.verticalCenter
                //verticalCenterOffset: newEntryField.textVerticalCenterOffset
                //top: parent.verticalCenter
                //topMargin: -newEntryField.textVerticalCenterOffset
            }

            placeholderText: qsTr("New entry")
            label: qsTr("New entry")

            EnterKey.enabled: text.trim().length > 0
            EnterKey.onClicked: {
                focus = true

                var index = todoModel.addItem(text, true)

                // Ugly hack...
                // Animation does not start, if set with ListItem.onAdd signal and new item is out of bounds (cacheBuffer).
                // So bring item into view first, search it and start animation after that.
                todoList.positionViewAtIndex(index, ListView.Center)

                for (var i=0; i<todoList.contentItem.children.length; i++) {
                    var item = todoList.contentItem.children[i];

                    if (item.index === index) {
                        item.backgroundRectAnimation.start()
                        break;
                    }
                }

                text = ''
            }

            EnterKey.highlighted: true
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
        }

        PanelBackground {
            z: -1
            anchors.fill: parent
        }
    }

    TodoModel {
        id: todoModel
        text: root.note

        property bool _initialized: false;
        onTextChanged: {
            if (!_initialized)
                return;

            console.log("Updating note with todo-text")
            root.note = text
        }

        Component.onCompleted: _initialized = true;
    }
}
