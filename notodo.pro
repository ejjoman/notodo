# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-notodo

CONFIG += sailfishapp

SOURCES += \
    src/iconprovider.cpp \
    src/notodo.cpp \
    src/qmlsettings.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    rpm/harbour-notodo.changes.in \
    rpm/harbour-notodo.spec \
    rpm/harbour-notodo.yaml \
    translations/*.ts \
    qml/js/utils.js \
    qml/models/NotesModel.qml \
    qml/pages/NotePage.qml \
    qml/pages/MainPage.qml \
    qml/js/TodoHelper.js \
    qml/models/TodoModel.qml \
    qml/pages/TodoPage.qml \
    qml/common/NoteBasePage.qml \
    qml/common/NotePagePullDownMenu.qml \
    qml/images/checkmark-checked-50.png \
    qml/images/checkmark-unchecked-50.png \
    qml/common/CheckMarker.qml \
    qml/common/MoveTransition.qml \
    qml/notodo.qml \
    harbour-notodo.desktop \
    qml/pages/AboutPage.qml \
    qml/models/AboutModel.qml \
    qml/common/AboutItem.qml \
    qml/pages/LicensePage.qml \
    qml/images/GPLv3.png \
    qml/common/Settings.qml \
    qml/common/NotePageHeader.qml \
    qml/common/TodoListDelegate.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-notodo-en.ts \
                translations/harbour-notodo-de.ts

HEADERS += \
    src/iconprovider.h \
    src/qmlsettings.h

