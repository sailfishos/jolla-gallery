TEMPLATE = subdirs
SUBDIRS = src translations tests
CONFIG += ordered

OTHER_FILES += jolla-gallery.desktop rpm/jolla-gallery.spec sources

desktop.files = jolla-gallery.desktop
desktop.path = /usr/share/applications

mediasources.files = mediasources
mediasources.path = /usr/share/jolla-gallery

INSTALLS += desktop mediasources
