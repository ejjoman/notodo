import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: listItem 

    function focus() {
        textField.forceActiveFocus();
    }

    property alias backgroundRectAnimation: backgroundRectAnimation
    readonly property int index: model.index

    height: Math.max(Theme.itemSizeSmall, textField.implicitHeight)
    width: parent ? parent.width : Screen.width

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

            right: settings.checkmarkersOnRight ? parent.right : undefined
            left: settings.checkmarkersOnRight ? undefined : parent.left
        }

        onClicked: todoModel.updateItemCheckedStatus(model.index, !checkMarker.checked)

        Rectangle {
            width: 1
            color: Theme.primaryColor
            opacity: .5

            height: parent.height

            anchors {
                left: settings.checkmarkersOnRight ? parent.left : undefined
                right: settings.checkmarkersOnRight ? undefined : parent.right
            }
        }

        CheckMarker {
            id: checkMarker
            animationDuration: 150
            anchors.centerIn: parent
            checked: model.checked
            checkmarkColor: checkMarkerMouseArea.down ? Theme.highlightColor : Theme.primaryColor
        }
    }

    TextArea {
        id: textField
        wrapMode: TextEdit.Wrap

        property bool _initialized: false

        anchors {
            verticalCenter: parent.verticalCenter
            left: settings.checkmarkersOnRight ? parent.left : checkMarkerMouseArea.right
            right: settings.checkmarkersOnRight ? checkMarkerMouseArea.left : parent.right
        }

        font.strikeout: checkMarker.checked

        labelVisible: false
        background: null
        color: checkMarkerMouseArea.down ? Theme.highlightColor : Theme.primaryColor
        text: model.text

        onActiveFocusChanged: {
            if (!activeFocus) {
                if (text.trim() === '')
                    todoModel.removeItem(model.index);
                else
                    todoModel.updateItemText(model.index, text);
            }
        }

        EnterKey.onClicked: focus = false
        EnterKey.highlighted: true
        EnterKey.iconSource: "image://theme/icon-m-enter-accept"

        Component.onCompleted: _initialized = true;

        onTextChanged: text = text.replace("\n", "")
    }
}
