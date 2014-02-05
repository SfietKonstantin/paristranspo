TARGET = harbour-paristranspo

CONFIG += sailfishapp

SOURCES += paristranspo.cpp

INCLUDEPATH += libvianavigo/src/lib
include(libvianavigo/src/lib/lib.pri)

OTHER_FILES += qml/harbour-paristranspo.qml \
    qml/MainPage.qml \
    qml/SearchDialog.qml \
    harbour-paristranspo.desktop \
    qml/RouteSearchPage.qml


# Hardcoded for Sailfish OS
target.path = /usr/bin

qmlFiles.files = qml/*.qml
qmlFiles.path = /usr/share/$${TARGET}/qml

desktopFile.files = $$PWD/data/$${TARGET}.desktop
desktopFile.path = /usr/share/applications

iconFile.files = $$PWD/data/$${TARGET}.png
iconFile.path = /usr/share/icons/hicolor/86x86/apps/

iconFiles.files = $$PWD/data/icons/bus.png \
    $$PWD/data/icons/metro.png \
    $$PWD/data/icons/rer.png \
    $$PWD/data/icons/train.png \
    $$PWD/data/icons/tram.png \
    $$PWD/data/icons/waiting.png \
    $$PWD/data/icons/walking.png
iconFiles.path = /usr/share/$${TARGET}/data/icons

INSTALLS += target qmlFiles desktopFile iconFile iconFiles

# Translations
TS_FILE = $$OUT_PWD/paristranspo.ts
EE_QM = $$OUT_PWD/paristranspo-engineering-english.qm

ts.commands += lupdate $$PWD -ts $$TS_FILE
ts.CONFIG += no_check_exist
ts.output = $$TS_FILE
ts.input = .

QMAKE_EXTRA_TARGETS += ts
PRE_TARGETDEPS += ts

# Engineering english
engineering_english.commands += lrelease -idbased $$TS_FILE -qm $$EE_QM
engineering_english.CONFIG += no_check_exist
engineering_english.depends = ts

QMAKE_EXTRA_TARGETS += engineering_english
PRE_TARGETDEPS += engineering_english

engineering_english_install.path = /usr/share/$${TARGET}/translations
engineering_english_install.files = $$EE_QM

#translations_install.path = /usr/share/$${TARGET}/translations
#translations_install.files = $$PWD/paristranspo_*.qm

INSTALLS += engineering_english_install
#INSTALLS += translations_install
