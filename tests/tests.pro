TEMPLATE = subdirs

SUBDIRS = imports

auto.files = \
    auto/*.qml \
    auto/run-tests.sh
auto.path = /opt/tests/jolla-gallery/auto

definition.files = test-definition/tests.xml
definition.path = /opt/tests/jolla-gallery/test-definition

INSTALLS += auto definition
