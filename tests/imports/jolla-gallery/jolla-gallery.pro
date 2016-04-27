MODULENAME = com/jolla/gallery
TARGET = jollagalleryplugin

include (../imports.pri)

GALLERY_SOURCE_PATH = $$PWD/../../../src

system(qdbusxml2cpp -c GalleryAdaptor -a galleryadaptor.h:galleryadaptor.cpp  ../../../com.jolla.gallery.xml)

QT += dbus qml quick docgallery multimedia concurrent
CONFIG += mobility link_pkgconfig
MOBILITY += gallery

PKGCONFIG += mlite5

INCLUDEPATH += $$GALLERY_SOURCE_PATH

HEADERS += \
    galleryadaptor.h \

SOURCES += \
    galleryadaptor.cpp \

HEADERS += \
        $$GALLERY_SOURCE_PATH/declarativemediamodel.h \
        $$GALLERY_SOURCE_PATH/declarativemediasource.h \
        $$GALLERY_SOURCE_PATH/declarativethreadedfileremover.h \
        $$GALLERY_SOURCE_PATH/declarativegalleryservice.h \
        $$GALLERY_SOURCE_PATH/declarativetextcodec.h

SOURCES += \
        main.cpp \
        $$GALLERY_SOURCE_PATH/declarativemediamodel.cpp \
        $$GALLERY_SOURCE_PATH/declarativemediasource.cpp \
        $$GALLERY_SOURCE_PATH/declarativethreadedfileremover.cpp \
        $$GALLERY_SOURCE_PATH/declarativegalleryservice.cpp \
        $$GALLERY_SOURCE_PATH/declarativetextcodec.cpp


import.files = qmldir
import.path = $$TARGETPATH
INSTALLS += import
