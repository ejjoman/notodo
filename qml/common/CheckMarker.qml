import QtQuick 2.0
import Sailfish.Silica 1.0

Flipable {
    id: flipable
    //anchors.fill: parent

    property int animationDuration: 200
    property bool checked: false

    property alias checkedImage: frontImage.source
    property alias uncheckedImage: uncheckedImage.source

    property color checkmarkColor: Theme.primaryColor

    width: 50; height: 50;

    front: Image {
        id: frontImage
        anchors.fill: parent
        source: "image://myIcons/" + Qt.resolvedUrl("../images/checkmark-checked-50.png") + "?" + checkmarkColor
        smooth: true
    }

    back: Image {
        id: uncheckedImage
        anchors.fill: parent
        source: "image://myIcons/" + Qt.resolvedUrl("../images/checkmark-unchecked-50.png") + "?" + checkmarkColor
        smooth: true
    }

    transform: Rotation {
        id: rotation
        origin.x: flipable.width/2
        origin.y: flipable.height/2
        axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
        angle: 0    // the default angle
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: 180 }
        PropertyChanges { target: flipable; opacity: .4 }
        when: !flipable.checked
    }

    transitions: Transition {
        enabled: _initialized
        NumberAnimation { target: rotation; property: "angle"; duration: animationDuration }
        NumberAnimation { target: flipable; property: "opacity"; duration: animationDuration * 2 }
    }

    property bool _initialized: false
    Component.onCompleted: _initialized = true;
}
