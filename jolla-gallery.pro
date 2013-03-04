TEMPLATE = subdirs
SUBDIRS = src translations tests
CONFIG += ordered

OTHER_FILES += \
    com.jolla.gallery.service \
    jolla-gallery.desktop \
    rpm/jolla-gallery.spec \
    sources

desktop.files = jolla-gallery.desktop
desktop.path = /usr/share/applications

mediasources.files = mediasources
mediasources.path = /usr/share/jolla-gallery

service.files = com.jolla.gallery.service
service.path  = /usr/share/dbus-1/services

INSTALLS += desktop mediasources service
