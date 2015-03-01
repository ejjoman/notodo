import QtQuick 2.0
import "../js/utils.js" as Utils

ListModel {
    id: root

    property bool _updatingText: false;
    property string text;
    readonly property string _checkedMarker: "[X] "
    property bool moveCheckedToBottom: true

    readonly property int checkedCount: _checkedCount;
    property int _checkedCount: 0;

    property bool isInitializing: false

    onTextChanged: {
        if (_updatingText)
            return;

        root.isInitializing = true;

        root.clear();

        var lines = note.getLines();

        if (root.moveCheckedToBottom) {
            var uncheckedItems  = [];
            var checkedItems    = [];

            for (var i=0; i<lines.length; i++) {
                var item = _getObject(lines[i], false);

                if (item.checked)
                    checkedItems.push(item);
                else
                    uncheckedItems.push(item);
            }

            for (var i=0; i<uncheckedItems.length; i++)
                root.append(uncheckedItems[i]);

            for (var i=0; i<checkedItems.length; i++)
                root.append(checkedItems[i]);

            root._checkedCount = checkedItems.length;

        } else {
            for (var i=0; i<lines.length; i++) {
                var item = _getObject(lines[i], false);
                root.append(item);

                if (item.checked)
                    root._checkedCount++;
            }
        }

        root.isInitializing = false;
    }

    function _getObject(text, isNewItem) {
        var isChecked = text.indexOf(_checkedMarker) === 0;

        if (isChecked)
            text = text.substring(_checkedMarker.length)

        return {
            "text": text,
            "checked": isChecked,
            "isNewItem": isNewItem
        };
    }

    function addItem(text, updateText) {
        var item = _getObject(text, true);
        var index = 0;

        if (moveCheckedToBottom) {
            if (item.checked) {
                index = root.count
            } else {
                var firstCheckedIndex = -1;

                for (var i=0; i<root.count; i++) {
                    //index = i;

                    var itemAtIndex = root.get(i);

                    if (itemAtIndex.checked) {
                        firstCheckedIndex = i;
                        break;
                    }
                }

                if (firstCheckedIndex === -1)
                    index = root.count
                else
                    index = firstCheckedIndex;

            }
        } else {
            index = root.count
        }

        console.log("insert index:", index)
        root.insert(index, item);

        if (item.checked)
            _checkedCount++;

        if (updateText)
            _updateText();

        return index;
    }

    function _getNewIndex(currentIndex, isChecked) {
        var newIndex = currentIndex;

        if (root.moveCheckedToBottom) {
            if (isChecked) {
                for (var i=root.count-1; i >= 0; i--) {
                    var row = root.get(i);

                    if (!row.checked) {
                        newIndex = i;
                        break;
                    }
                }
            } else {
                newIndex = 0;
            }
        }

        return newIndex;
    }

    function updateCheckedStatus(index, isChecked) {
        var wasChecked = root.get(index).checked;
        var newIndex = _getNewIndex(index, isChecked);

        if (index !== newIndex)
            move(index, newIndex, 1);

        setProperty(newIndex, "checked", isChecked);
        _updateText();

        if (wasChecked !== isChecked)
            if (isChecked)
                root._checkedCount++
            else
                root._checkedCount--;
    }

    function updateText(index, text) {
        setProperty(index, "text", text);
        _updateText();
    }

    function _updateText() {
        var newText = "";

        for (var i=0; i<root.count; i++) {
            var row = root.get(i);

            if (row.checked)
                newText += _checkedMarker;

            newText += row.text;

            if (i < root.count-1)
                newText += "\n";
        }

        root._updatingText = true;
        root.text = newText;
        root._updatingText = false;
    }
}
