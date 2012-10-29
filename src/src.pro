include(../common.pri)

TARGET = jolla-gallery
target.path = /usr/bin

qml.files = *.qml pages images
qml.path = $$DEPLOYMENT_PATH


# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT += opengl

contains(CONFIG, desktop) {
    DEFINES *= DESKTOP
}

CONFIG += link_pkgconfig
PKGCONFIG += mlite
INCLUDEPATH += ../lib
LIBS += -lgallerymediasource -L../lib

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
# CONFIG += qdeclarative-boostable

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)

OTHER_FILES += \
    *.qml \
    pages/*.qml \
    pages/scripts/*.js

INSTALLS += target qml

#DEFINES *= DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"

HEADERS += \
    declarativewallpaper.h \
    declarativemediamodel.h

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += gallery.cpp \
    declarativewallpaper.cpp \
    declarativemediamodel.cpp
