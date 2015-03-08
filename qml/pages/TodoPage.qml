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

    type: "todo"
    newTitle: "New Todo"

    property bool _modelUpdating: false;

    SilicaListView {
        id: todoList
        clip: true

        function getItemByIndex(index) {
            for (var i=0; i<todoList.contentItem.children.length; i++) {
                var item = todoList.contentItem.children[i];

                if (item.index === index) {
                    return item;
                }
            }

            return null;
        }

        NotePagePullDownMenu {
            basePage: root
            todoModel: todoModel
        }

        header: NotePageHeader {
            id: header
            page: root

            title: root.title

            onTextChanged: {
                if (root._updatingTitle)
                    return;

                _updatingTitle = true;
                root.title = text
                _updatingTitle = false;

                root._titleChangedManually = true
            }

            onActiveFocusChanged: {
                if (activeFocus) {
                    if (root._titleChangedManually) {
                        textItem.cursorPosition = title.length
                    } else {
                        textItem.selectAll();
                    }
                } else {
                    root._updateTitle()
                }
            }

            Component.onCompleted: root._updatingTitle = false
        }

        move: MoveTransition {}
        displaced: MoveTransition {}

        model: todoModel

        anchors {
            fill: parent
            bottomMargin: panel.height
        }

        delegate: TodoListDelegate {}

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
                addItem()
            }

            function addItem() {
                if (text.trim() === '')
                    return;

                var index = todoModel.addItem(text.trim(), true)

                // Ugly hack...
                // Animation does not work, if it was set with ListItem.onAdd signal and new item is out of bounds (cacheBuffer).
                // So bring item into view first, search it and start animation after that.
                todoList.positionViewAtIndex(index, ListView.Center)

                var item = todoList.getItemByIndex(index);

                if (item)
                    item.backgroundRectAnimation.start()

                text = ''
            }

            EnterKey.highlighted: true
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"

            onActiveFocusChanged: {
                if (!activeFocus)
                    addItem()
            }
        }

        PanelBackground {
            z: -1
            anchors.fill: parent
        }
    }

    onNoteChanged: {
        if (_modelUpdating)
            return;

        todoModel.initModel(root.note)
    }

    TodoModel {
        id: todoModel

        onModelUpdated: {
            _modelUpdating = true;
            root.note = text
            _modelUpdating = false;
        }
    }

    Component.onCompleted: {
        if (root.noteIndex < 0)
            newEntryField.forceActiveFocus()
    }
}
