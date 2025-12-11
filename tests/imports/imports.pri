# SPDX-FileCopyrightText: 2012 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TEMPLATE = lib

TARGET = $$qtLibraryTarget($$TARGET)
TARGETPATH = /opt/tests/jolla-gallery/imports/$$MODULENAME

target.path = $$TARGETPATH
INSTALLS += target
