# SPDX-FileCopyrightText: 2012-2021 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TEMPLATE = subdirs
SUBDIRS = src translations tests

OTHER_FILES += \
    com.jolla.gallery.service \
    com.jolla.gallery.xml \
    jolla-gallery.desktop \
    rpm/jolla-gallery.spec \
    sources

desktop.files = jolla-gallery.desktop
desktop.path = /usr/share/applications

mediasources.files = mediasources
mediasources.path = /usr/share/jolla-gallery

service.files = com.jolla.gallery.service
service.path  = /usr/share/dbus-1/services

enablehints.files = enable-gallery-hints
enablehints.path  = /usr/lib/oneshot.d

INSTALLS += desktop mediasources service enablehints
