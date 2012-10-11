TARGET = jolla-gallery
TARGETPATH = /usr/bin
target.path = $$TARGETPATH

DEPLOYMENT_PATH = /usr/share/$$TARGET
qml.files = *.qml pages images
qml.path = $$DEPLOYMENT_PATH

desktop.files = jolla-gallery.desktop
desktop.path = /usr/share/applications

#dummydata.files = dummydata
#dummydata.path = $$DEPLOYMENT_PATH

# Add more folders to ship with the application, here
# pages.source = pages
# rootfile.source = 
# DEPLOYMENTFOLDERS = pages rootfile

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

contains(CONFIG, desktop) {
    DEFINES *= DESKTOP
}


CONFIG += link_pkgconfig
PKGCONFIG += mlite


# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
# CONFIG += qdeclarative-boostable

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += gallery.cpp \
    wallpaper.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
# qtcAddDeployment()

OTHER_FILES += \
    *.qml \
    pages/*.qml \
    pages/scripts/*.js \
    jolla-gallery.desktop \
    rpm/jolla-gallery.spec

INSTALLS += target qml desktop

DEFINES *= DEPLOYMENT_PATH=\"\\\"\"$${DEPLOYMENT_PATH}/\"\\\"\"

HEADERS += \
    wallpaper.h
