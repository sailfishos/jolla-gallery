TEMPLATE = subdirs
SUBDIRS = src translations tests

OTHER_FILES += \
    com.jolla.gallery.service \
    com.jolla.gallery.xml \
    jolla-gallery.desktop \
    rpm/jolla-gallery.spec \
    sources

desktop.files = jolla-gallery.desktop jolla-gallery-openfile.desktop
desktop.path = /usr/share/applications

mediasources.files = mediasources
mediasources.path = /usr/share/jolla-gallery

service.files = com.jolla.gallery.service
service.path  = /usr/share/dbus-1/services

disablehints.files = disable-gallery-hints
disablehints.path  = /usr/lib/oneshot.d

INSTALLS += desktop mediasources service disablehints
