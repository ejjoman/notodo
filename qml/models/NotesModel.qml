import QtQuick 2.0
import QtQuick.LocalStorage 2.0

ListModel {
    id: root

    function __db() {
        try {
            var db = LocalStorage.openDatabaseSync("notodo", "", "notodo database", 1000000);

            if (db.version === "") {
                db.changeVersion("", "1", function(tx) {
                    var createTable =
                            'CREATE TABLE "notes" ( \
                                "id" INTEGER PRIMARY KEY, \
                                "type" TEXT NOT NULL, \
                                "title" TEXT NOT NULL, \
                                "note" TEXT NOT NULL, \
                                "color" TEXT NOT NULL, \
                                "created" TEXT NOT NULL, \
                                "changed" TEXT NOT NULL
                            );';

                    tx.executeSql(createTable);
                })
            }

            return db;
        } catch(e) {
            console.log("Could not open DB: " + e);
        }

        return null;
    }

    function load() {
        root.clear();

        __db().transaction(function(tx) {
            var results = tx.executeSql("SELECT * FROM notes ORDER BY changed DESC")

            for (var i=0; i<results.rows.length; i++) {
                var row = results.rows.item(i);

                root.append({
                                "id": row.id,
                                "type": row.type,
                                "title": row.title,
                                "note": row.note,
                                "color": row.color,
                                "createdDate": new Date(row.created),
                                "changedDate": new Date(row.changed)
                            });
            }
        });

        console.log("Items loaded:", root.count)
    }

    function _getNewIndex(note) {
        var i;
        for (i=root.count-1; i >= 0; i--) {
            var row = root.get(i);

            if (row.changedDate > note.changedDate)
                break;

        }

        return i + 1;
    }

    property color test: "#000"

    function addNote(note) {
        __db().transaction(function(tx) {
            var insert = "INSERT INTO notes (id, type, title, note, color, created, changed) VALUES (null, ?, ?, ?, ?, ?, ?)";

            tx.executeSql(insert, [
                              note.type,
                              note.title,
                              note.note,
                              note.color,
                              note.createdDate.toISOString(),
                              note.changedDate.toISOString()
                          ]);
        })

        var newIndex = root._getNewIndex(note);
        root.insert(newIndex, note);

        return newIndex;
    }

    function getIdFromIndex(index) {
        var note = root.get(index);

        return note ? note.id : -1;
    }

    function updateNote(index, note) {
        var noteId = root.getIdFromIndex(index);

        if (noteId < 0)
            return;

        __db().transaction(function(tx) {
            var update = "UPDATE notes SET type=?, title=?, note=?, color=?, changed=? WHERE id=?";

            tx.executeSql(update, [
                              note.type,
                              note.title,
                              note.note,
                              note.color,
                              note.changedDate.toISOString(),
                              noteId
                          ]);
        });

        root.setProperties(index, note);

        var newIndex = root._getNewIndex(note);
        root.move(index, newIndex, 1);

        return newIndex;
    }

    function deleteNote(index) {
        var noteId = root.getIdFromIndex(index);

        if (noteId < 0)
            return;

        __db().transaction(function(tx) {
            tx.executeSql("DELETE FROM notes WHERE id=?", [noteId]);
        });

        root.remove(index)
    }

    function setProperties(index, obj) {
        for (var prop in obj)
            root.setProperty(index, prop, obj[prop]);
    }

    Component.onCompleted: root.load()
}
