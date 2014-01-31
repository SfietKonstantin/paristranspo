TARGET = harbour-paristranspo

CONFIG += sailfishapp

SOURCES += paristranspo.cpp

INCLUDEPATH += libvianavigo/src/lib
include(libvianavigo/src/lib/lib.pri)

OTHER_FILES += qml/harbour-paristranspo.qml \
    qml/MainPage.qml \
    qml/SearchDialog.qml \
    harbour-paristranspo.desktop


# Hardcoded for Sailfish OS
target.path = /usr/bin

qmlFiles.files = qml/*.qml
qmlFiles.path = /usr/share/$${TARGET}/qml

desktopFile.files = $${TARGET}.desktop
desktopFile.path = /usr/share/applications

iconFile.files = $${TARGET}.png
iconFile.path = /usr/share/icons/hicolor/86x86/apps/

INSTALLS += target qmlFiles iconFile
