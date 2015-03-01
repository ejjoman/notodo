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

Page {
    id: root

    property int noteIndex
    //onNoteIndexChanged: _init()

    property string type

    readonly property bool isTodo: type === "todo"
    readonly property bool isNote: type === "note"

    property string note
    onNoteChanged: _updateTitle()

    property string title
    property color color: "#FF0000"

    property bool loaded: false
    property bool isChangingType: false

    property QtObject originalNote

    readonly property bool dataChanged: {
        if (!originalNote)
            return true;

        return title !== originalNote.title || note !== originalNote.note || color + "" !== originalNote.color || type !== originalNote.type
    }

    property alias colorPicker: colorPicker

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            if (noteIndex >= 0 && root.note.trim() == '') {
                notesModel.deleteNote(noteIndex)
                noteIndex = -1
            } else if(root.note.trim() != '') {
                saveNote()
            }
        }
    }

    function saveNote() {
        console.log("NoteIndex", noteIndex)

        if (isChangingType) {
            console.log("Changing type, don't save.")
            return;
        }

        if (!dataChanged) {
            console.log("Nothing changed...")
            return;
        }

        console.log("Save changed note...")

        if (noteIndex >= 0) {
            notesModel.updateNote(noteIndex, {
                                      "type": root.type,
                                      "title": root.title,
                                      "note": root.note,
                                      "color": root.color + "",
                                      "changedDate": new Date()
                                  })
        } else {
            notesModel.addNote({
                                   "type": root.type,
                                   "title": root.title,
                                   "note": root.note,
                                   "color": root.color + "",
                                   "createdDate": new Date(),
                                   "changedDate": new Date()
                               })
        }
    }

    function _init() {
        console.log("_init")

        if (isChangingType) {
            isChangingType = false;
            return;
        }

        if (loaded)
            return;

        if (noteIndex < 0 || noteIndex > notesModel.count)
            return;

        var item = notesModel.get(noteIndex)
        root.title = item.title
        root.note = item.note
        root.color = item.color

        if (!root.type)
            root.type = item.type

        originalNote = item

        root.loaded = true
    }

    function _updateTitle() {
        if (root.noteIndex >= 0)
            return;

        var firstLine = note.getFirstLineWithText();
        root.title = firstLine;
    }

    Component {
        id: colorPicker

        ColorPickerDialog {
            color: root.colorResolved

            onColorChanged: {
                if (color === Theme.primaryColor)
                    root.color = "transparent"
                else
                    root.color = color
            }
        }
    }

    Component.onCompleted: _init()
}





