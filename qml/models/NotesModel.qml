import QtQuick 2.0
import QtQuick.LocalStorage 2.0

ListModel {
    id: root

    function __rawOpenDb() {
        return LocalStorage.openDatabaseSync('notodo', '', 'notodo database', 10000);
    }

    function __upgradeSchema(db) {
        if (db.version === '') {
            db.changeVersion('', '1', function(tx) {
                var createTable =
                        'CREATE TABLE "notes" ( \
                            "id" INTEGER PRIMARY KEY, \
                            "type" TEXT NOT NULL, \
                            "title" TEXT NOT NULL, \
                            "note" TEXT NOT NULL, \
                            "color" TEXT NOT NULL, \
                            "created" TEXT NOT NULL, \
                            "changed" TEXT NOT NULL
                        )';

                tx.executeSql(createTable);
            })

            db = __rawOpenDb()
        }

//        if (db.version === '1') {
//            db.changeVersion('1', '2', function(tx) {
//                tx.executeSql('ALTER TABLE "notes" ADD COLUMN revision INTEGER');
//                tx.executeSql('ALTER TABLE "notes" ADD COLUMN revisionInfo TEXT');
//                //tx.executeSql('UPDATE "notes" SET revision=0');
//            })

//            db = __rawOpenDb()
//        }
    }

    function openDb() {
        var db = __rawOpenDb()

        if (db.version !== '1')
            __upgradeSchema(db);

        return db;
    }

    function load() {
        root.clear();

        openDb().transaction(function(tx) {
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

    function getById(noteId) {
        var index = getIndexFromId(noteId)

        if (index < 0)
            return null;

        return get(index);
    }

    function getIndexFromId(id) {
        for (var i=0; i<root.count; i++)
            if (root.get(i).id === id)
                return i;

        return -1;
    }

    function getIdFromIndex(index) {
        var note = root.get(index);

        return note ? note.id : -1;
    }

    function addNote(note, callback) {
        openDb().transaction(function(tx) {
            var insert = "INSERT INTO notes (id, type, title, note, color, created, changed) VALUES (null, ?, ?, ?, ?, ?, ?)";

            var result = tx.executeSql(insert, [
                                           note.type,
                                           note.title,
                                           note.note,
                                           note.color,
                                           new Date().toISOString(),
                                           new Date().toISOString()
                                       ]);

            console.log("ID of new note is", result.insertId);

            var noteId = parseInt(result.insertId)
            note["id"] = noteId;

            var newIndex = root._getNewIndex(note);
            root.insert(newIndex, note);

            callback(noteId);
        })
    }

    function updateNote(noteId, note) {
        //var noteId = root.getIdFromIndex(index);
        console.log("Updating note with id:", noteId)

        if (noteId < 0)
            return;

        openDb().transaction(function(tx) {
            var update = "UPDATE notes SET type=?, title=?, note=?, color=?, changed=? WHERE id=?";

            tx.executeSql(update, [
                              note.type,
                              note.title,
                              note.note,
                              note.color,
                              new Date().toISOString(),
                              noteId
                          ]);
        });

        var index = root.getIndexFromId(noteId)
        root.setProperties(index, note);

        var newIndex = root._getNewIndex(note);
        root.move(index, newIndex, 1);
    }

    function deleteNote(noteId) {
        if (noteId < 0)
            return;

        openDb().transaction(function(tx) {
            tx.executeSql("DELETE FROM notes WHERE id=?", [noteId]);
        });

        var index = root.getIndexFromId(noteId)
        root.remove(index)
    }

    function setProperties(index, obj) {
        for (var prop in obj)
            root.setProperty(index, prop, obj[prop]);
    }

    Component.onCompleted: root.load()
}
