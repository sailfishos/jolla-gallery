include(../common.pri)

TARGET = jolla-gallery
target.path = /usr/bin
QT += declarative dbus script

qml.files = *.qml pages images
qml.path = $$DEPLOYMENT_PATH

CONFIG += mobility

MOBILITY += gallery

contains(CONFIG, desktop) {
    DEFINES *= DESKTOP
}

CONFIG += link_pkgconfig

PKGCONFIG += mlite

OTHER_FILES += \
    *.qml \
    pages/*.qml \
    pages/scripts/*.js

HEADERS += \
    declarativewallpaper.h \
    declarativemediamodel.h \
    declarativemediasource.h \
    declarativedbusinterface.h

SOURCES += gallery.cpp \
    declarativewallpaper.cpp \
    declarativemediamodel.cpp \
    declarativemediasource.cpp \
    declarativedbusinterface.cpp

INSTALLS += target qml

packagesExist(qdeclarative-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}
