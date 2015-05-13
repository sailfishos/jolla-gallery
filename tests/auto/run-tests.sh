#!/bin/sh

# Create a temporary DBus session to isolate us from the normal environment.
export `dbus-launch`
export QML2_IMPORT_PATH=/opt/tests/jolla-gallery/imports
export LC_ALL=fi_FI.utf8

/usr/lib/qt5/bin/qmltestrunner $@
exit_code=$?

kill $DBUS_SESSION_BUS_PID

exit $exit_code
