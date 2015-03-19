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

import "../js/utils.js" as Utils
import "../js/TodoHelper.js" as TodoHelper

Page {
    id: page
    objectName: "MainPage"

    property alias listView: list

    SilicaListView {
        id: list
        anchors.fill: parent
        model: notesModel

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                visible: false
                text: qsTr("Settings")
            }

            MenuItem {
                text: qsTr("New note")
                onClicked: pageStack.push(notePage, {noteId: -1})
            }

            MenuItem {
                text: qsTr("New task list")
                onClicked: pageStack.push(todoPage, {noteId: -1})
            }
        }

        delegate: ListItem {
            id: listItem

            width: parent.width
            contentHeight: Theme.itemSizeLarge

            ListView.onAdd: AddAnimation {
                target: listItem
            }

            ListView.onRemove: RemoveAnimation {
                target: listItem
            }

            menu: contextMenu

//            readonly property color noteColor: {
//                if (model.color === "transparent")
//                    return Theme.primaryColor

//                return model.color;
//            }

            Row {
                spacing: Theme.paddingLarge

                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium

                    right: parent.right
                    rightMargin: Theme.paddingMedium

                    verticalCenter: parent.verticalCenter
                }

                Image {
                    id: noteIcon
                    source: "image://myIcons/" + Qt.resolvedUrl("../images/" + model.type + "-32.png") + "?" + (listItem.highlighted ? Theme.highlightColor : Theme.primaryColor)
                    anchors {
                        //left: parent.left
                        //leftMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                }

                Column {
                    width: parent.width - noteIcon.width - Theme.paddingLarge

                    Label {
                        text: model.title
                        font.bold: true
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor

                        anchors {
                            left: parent.left
                            right: parent.right
                        }

                        truncationMode: TruncationMode.Fade
                    }

                    Label {
                        id: noteDetailsLabel

                        anchors {
                            left: parent.left
                            right: parent.right
                        }

                        text: {
                            if (model.type === "note")
                                return model.note.getFirstLineWithText();

                            var todoModel = TodoHelper.getTodoModel(model.note);

                            if (todoModel.count === todoModel.checked)
                                return qsTr("All done")

                            return qsTr("%1 of %2 done").arg(todoModel.checked).arg(todoModel.count)
                        }

                        truncationMode: TruncationMode.Fade

                        maximumLineCount: 1
                        font.pixelSize: Theme.fontSizeSmall
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    }
                }
            }

            function remove() {
                remorseAction(qsTr("Deleting"), function() {
                    notesModel.deleteNote(model.id)
                })
            }

            Component {
                id: contextMenu

                ContextMenu {
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: listItem.remove()
                    }
                }
            }

            onClicked: {
                if (model.type === "note")
                    pageStack.push(notePage, {noteId: model.id})
                else
                    pageStack.push(todoPage, {noteId: model.id})
            }
        }

        ViewPlaceholder {
            enabled: list.count == 0
            text: qsTr("No notes or task lists available yet")
            hintText: qsTr("Add a new note or task list")
        }
    }

    Component {
        id: notePage

        NotePage {}
    }

    Component {
        id: todoPage

        TodoPage {}
    }


    //    // To enable PullDownMenu, place our content in a SilicaFlickable
    //    SilicaFlickable {
    //        anchors.fill: parent



    //        // Tell SilicaFlickable the height of its content.
    //        contentHeight: column.height

    //        // Place our content in a Column.  The PageHeader is always placed at the top
    //        // of the page, followed by our content.
    //        Column {
    //            id: column

    //            width: page.width
    //            spacing: Theme.paddingLarge
    //            PageHeader {
    //                title: qsTr("UI Template")
    //            }
    //            Label {
    //                x: Theme.paddingLarge
    //                text: qsTr("Hello Sailors")
    //                color: Theme.secondaryHighlightColor
    //                font.pixelSize: Theme.fontSizeExtraLarge
    //            }
    //        }
    //    }
}


