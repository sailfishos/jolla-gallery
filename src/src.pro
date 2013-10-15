include(../common.pri)

TARGET = jolla-gallery
target.path = /usr/bin

QT += qml quick dbus network docgallery multimedia concurrent
CONFIG += link_pkgconfig
PKGCONFIG += mlite5 libjollasignonuiservice-qt5 contentaction5

MODULENAME = com/jolla/gallery

system(qdbusxml2cpp -c GalleryAdaptor -a galleryadaptor.h:galleryadaptor.cpp  ../com.jolla.gallery.xml)


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

interface.files = ../com.jolla.gallery.xml
interface.path  = /usr/share/dbus-1/interfaces/


HEADERS += \
    galleryadaptor.h \
    declarativegalleryservice.h
SOURCES += \
    galleryadaptor.cpp \
    declarativegalleryservice.cpp

HEADERS += \
    declarativemediamodel.h \
    declarativemediasource.h \
    declarativedbusinterface.h \
    declarativefileinfo.h \
    declarativethreadedfileremover.h \
    declarativecameralauncher.h

SOURCES += gallery.cpp \
    declarativemediamodel.cpp \
    declarativemediasource.cpp \
    declarativedbusinterface.cpp \
    declarativefileinfo.cpp \
    declarativethreadedfileremover.cpp \
    declarativecameralauncher.cpp

INSTALLS += target qml component interface

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slower")
}
