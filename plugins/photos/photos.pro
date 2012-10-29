
include(../../common.pri)
TEMPLATE = lib
TARGET = $$qtLibraryTarget(photosplugin)
CONFIG += plugin mobility
DEPENDPATH += .
INCLUDEPATH += . ../../lib
MOBILITY += gallery

LIBS += -lgallerymediasource -L../../lib

# Input
HEADERS += photoplugin.h \
    photomodel.h
SOURCES += photoplugin.cpp \
    photomodel.cpp


target.path = /usr/lib/gallery/plugins
INSTALLS += target

OTHER_FILES += \
    PhotoIcon.qml

RESOURCES += \
    photoplugin.qrc
