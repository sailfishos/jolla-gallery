TEMPLATE = subdirs
SUBDIRS = lib src plugins
CONFIG += ordered

OTHER_FILES += jolla-gallery.desktop rpm/jolla-gallery.spec

desktop.files = jolla-gallery.desktop
desktop.path = /usr/share/applications

INSTALLS += desktop
