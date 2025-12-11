# SPDX-FileCopyrightText: 2012-2013 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TEMPLATE = subdirs

SUBDIRS = imports

OTHER_FILES += auto/* auto/scripts/*

plugin.files = auto/PluginAlbum.qml
plugin.path = /opt/tests/jolla-gallery/mediasources

auto.files = \
    auto/tst_* \
    auto/run-tests.sh \
    auto/images \
    auto/scripts \
    auto/SilicaTestCase.qml
auto.path = /opt/tests/jolla-gallery/auto

definition.files = test-definition/tests.xml
definition.path = /opt/tests/jolla-gallery/test-definition

images.files = images/*.jpg
images.path = /opt/tests/jolla-gallery/auto/images

INSTALLS += auto plugin definition images
