MODULENAME = com/jolla/gallery
TARGET = jollagalleryplugin

include (../imports.pri)

GALLERY_SOURCE_PATH = $$PWD/../../../src

QT += dbus qml quick docgallery multimedia concurrent
CONFIG += mobility link_pkgconfig
MOBILITY += gallery

PKGCONFIG += mlite5

INCLUDEPATH += $$GALLERY_SOURCE_PATH

HEADERS += \
        $$GALLERY_SOURCE_PATH/declarativedbusinterface.h \
        $$GALLERY_SOURCE_PATH/declarativemediamodel.h \
        $$GALLERY_SOURCE_PATH/declarativemediasource.h \
        $$GALLERY_SOURCE_PATH/declarativefileinfo.h \
        $$GALLERY_SOURCE_PATH/declarativewallpaper.h \
        $$GALLERY_SOURCE_PATH/declarativethreadedfileremover.h

SOURCES += \
        main.cpp \
        $$GALLERY_SOURCE_PATH/declarativedbusinterface.cpp \
        $$GALLERY_SOURCE_PATH/declarativemediamodel.cpp \
        $$GALLERY_SOURCE_PATH/declarativemediasource.cpp \
        $$GALLERY_SOURCE_PATH/declarativefileinfo.cpp \
        $$GALLERY_SOURCE_PATH/declarativewallpaper.cpp \
        $$GALLERY_SOURCE_PATH/declarativethreadedfileremover.cpp


import.files = qmldir
import.path = $$TARGETPATH
INSTALLS += import
