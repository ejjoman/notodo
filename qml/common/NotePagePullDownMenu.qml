import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/utils.js" as Utils
import "../models"

PullDownMenu {
    id: root

    property TodoModel todoModel
    property NoteBasePage basePage

//    MenuItem {
//        text: qsTr("Select color")
//        onClicked: pageStack.push(basePage.colorPicker)

//        Rectangle {
//            anchors {
//                bottom: parent.bottom
//                left: parent.left
//                leftMargin: ((parent.width - parent.paintedWidth) / 2) + 2
//            }

//            width: Theme.iconSizeSmall
//            height: Theme.paddingSmall
//            radius: Math.round(height/3)

//            color: basePage.colorResolved
//        }
//    }

    MenuItem {
        text: basePage.type == "note" ? qsTr("Change to <b>task list</b>") : qsTr("Change to <b>note</b>")

        onClicked: {
            root.basePage.isChangingType = true

            console.log("change type from:", basePage.type)
            console.log("current note text:", basePage.note)

            if (basePage.type === "note")
                pageStack.replace(todoPage, {
                                      noteIndex: basePage.noteIndex,
                                      note: basePage.note,
                                      title: basePage.title,
                                      color: basePage.color,
                                      isChangingType: true
                                  }, PageStackAction.Animated)
            else
                pageStack.replace(notePage, {
                                      noteIndex: basePage.noteIndex,
                                      note: basePage.note,
                                      title: basePage.title,
                                      color: basePage.color,
                                      isChangingType: true
                                  }, PageStackAction.Animated)
        }
    }

    MenuLabel {
        visible: text !== ""

        text: {
            if (isNote) {
                return qsTr("%n words", "", basePage.note.countWords())
            } else {
                var checkedCount = todoModel.checkedCount;
                var itemCount = todoModel.count;

                if (itemCount === 0)
                    return "";

                var percentage = checkedCount / itemCount

                return qsTr("%1 of %2 done (%3\%)").arg(checkedCount).arg(itemCount).arg(Math.floor(percentage * 100))
            }
        }
    }
}
