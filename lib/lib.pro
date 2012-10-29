TEMPLATE = lib
TARGET = gallerymediasource
DEPENDPATH += .
INCLUDEPATH += .
CONFIG += shared

# Input
HEADERS += mediasourceinterface.h \
    mediasourcemodelinterface.h
SOURCES += mediasourceinterface.cpp \
    mediasourcemodelinterface.cpp

target.path = /usr/lib
INSTALLS += target
