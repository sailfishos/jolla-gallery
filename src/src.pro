include(../common.pri)

TARGET = jolla-gallery
target.path = /usr/bin
QT += declarative

qml.files = *.qml pages images
qml.path = $$DEPLOYMENT_PATH

contains(CONFIG, desktop) {
    DEFINES *= DESKTOP
}

CONFIG += link_pkgconfig
PKGCONFIG += mlite
INCLUDEPATH += ../lib
LIBS += -lgallerymediasource -L../lib

OTHER_FILES += \
    *.qml \
    pages/*.qml \
    pages/scripts/*.js

HEADERS += \
    declarativewallpaper.h \
    declarativemediamodel.h

SOURCES += gallery.cpp \
    declarativewallpaper.cpp \
    declarativemediamodel.cpp

INSTALLS += target qml

packagesExist(qdeclarative-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}

