#!/bin/sh

# SPDX-FileCopyrightText: 2012-2021 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

# Create a temporary DBus session to isolate us from the normal environment.
export `dbus-launch`
export QML2_IMPORT_PATH=/opt/tests/jolla-gallery/imports
export LC_ALL=fi_FI.utf8

qmltestrunner -input $@
exit_code=$?

kill $DBUS_SESSION_BUS_PID

exit $exit_code
