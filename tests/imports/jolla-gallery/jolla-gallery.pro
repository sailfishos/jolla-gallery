MODULENAME = com/jolla/gallery
TARGET = jollagalleryplugin

include (../imports.pri)

GALLERY_SOURCE_PATH = $$PWD/../../../src

QT += dbus declarative script
CONFIG += mobility
MOBILITY += gallery

INCLUDEPATH += $$GALLERY_SOURCE_PATH

HEADERS += \
        $$GALLERY_SOURCE_PATH/declarativedbusinterface.h \
        $$GALLERY_SOURCE_PATH/declarativemediamodel.h \
        $$GALLERY_SOURCE_PATH/declarativemediasource.h \
        $$GALLERY_SOURCE_PATH/declarativefileinfo.h

SOURCES += \
        main.cpp \
        $$GALLERY_SOURCE_PATH/declarativedbusinterface.cpp \
        $$GALLERY_SOURCE_PATH/declarativemediamodel.cpp \
        $$GALLERY_SOURCE_PATH/declarativemediasource.cpp \
        $$GALLERY_SOURCE_PATH/declarativefileinfo.cpp

import.files = qmldir
import.path = $$TARGETPATH
INSTALLS += import
