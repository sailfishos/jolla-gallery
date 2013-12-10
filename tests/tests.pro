TEMPLATE = subdirs

SUBDIRS = imports

OTHER_FILES += auto/* auto/scripts/*

auto.files = auto/*
auto.path = /opt/tests/jolla-gallery/auto

definition.files = test-definition/tests.xml
definition.path = /opt/tests/jolla-gallery/test-definition

images.files = images/*.jpg
images.path = /opt/tests/jolla-gallery/auto/images

INSTALLS += auto definition images
