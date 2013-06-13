include(../common.pri)

TARGET = jolla-gallery
target.path = /usr/bin

QT += qml quick dbus network docgallery multimedia concurrent
CONFIG += link_pkgconfig
PKGCONFIG += mlite5
# libjollasignonuiservice

MODULENAME = com/jolla/gallery


qml.files = *.qml pages images
qml.path = $$DEPLOYMENT_PATH


contains(CONFIG, desktop) {
    DEFINES *= DESKTOP
}


OTHER_FILES += \
    *.qml \
    pages/*.qml \
    pages/scripts/*.js \
    components/*

component.files += \
    components/MediaSourceIcon.qml \
    components/MediaSourcePage.qml \
    components/qmldir
component.path = $$[QT_INSTALL_QML]/$$MODULENAME


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

INSTALLS += target qml component

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}
