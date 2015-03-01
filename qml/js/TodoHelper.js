.pragma library
Qt.include("utils.js")

function getTodoModel(note) {
    var lines = note.getLines();

    var c = 0;

    for (var i=0; i<lines.length; i++) {
        var item = lines[i];

        if (item.indexOf("[X] ") === 0)
            c++;
    }

    return {"count": lines.length, "checked": c};
}
