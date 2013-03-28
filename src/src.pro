include(../common.pri)

TARGET = jolla-gallery
target.path = /usr/bin

QT += declarative dbus script network
CONFIG += mobility
CONFIG += link_pkgconfig
MOBILITY += multimedia gallery
PKGCONFIG += mlite libjollasignonuiservice



qml.files = *.qml pages images
qml.path = $$DEPLOYMENT_PATH


contains(CONFIG, desktop) {
    DEFINES *= DESKTOP
}


OTHER_FILES += \
    *.qml \
    pages/*.qml \
    pages/scripts/*.js

HEADERS += \
    declarativewallpaper.h \
    declarativemediamodel.h \
    declarativemediasource.h \
    declarativedbusinterface.h \
    declarativefileinfo.h \
    declarativethreadedfileremover.h

SOURCES += gallery.cpp \
    declarativewallpaper.cpp \
    declarativemediamodel.cpp \
    declarativemediasource.cpp \
    declarativedbusinterface.cpp \
    declarativefileinfo.cpp \
    declarativethreadedfileremover.cpp

INSTALLS += target qml

packagesExist(qdeclarative-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}
