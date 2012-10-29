#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include "declarativewallpaper.h"
#include "declarativemediamodel.h"

#include <QDir>
#include <QDeclarativeError>
#include <QDeclarativeEngine>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDebug>
#include <QDeclarativeItem>

#include <QtOpenGL/QGLWidget>
#include <QtOpenGL/qgl.h>


Q_DECL_EXPORT int main(int argc, char *argv[])
{

    QScopedPointer<QApplication> app(createApplication(argc, argv));

    qmlRegisterType<DeclarativeMediaModel>("com.jolla.gallery", 1, 0, "MediaSourceModel");

    app->setGraphicsSystem("opengl");

    QmlApplicationViewer viewer;

    // TODO: Check what are the best viewport attributes

    QGLWidget *gl = new QGLWidget;
    gl->setAttribute(Qt::WA_OpaquePaintEvent);
    gl->setAttribute(Qt::WA_NoSystemBackground);
    gl->setAutoFillBackground(false);
    viewer.setViewport(gl);
    viewer.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    QString path;

    if (app->arguments().contains("-desktop")) {
        path = app->applicationDirPath() + QDir::separator();
    } else {
        path = QString(DEPLOYMENT_PATH);
    }

    DeclarativeWallpaper wallpaper;
    viewer.rootContext()->setContextProperty("wallpaper", &wallpaper);

    viewer.setMainQmlFile(path +  QLatin1String("gallery.qml"));

    if (app->arguments().contains("-desktop"))
    {
        viewer.setFixedSize(480, 854);
        viewer.rootObject()->setProperty("_desktop", true);
        viewer.show();
    } else {
        viewer.showFullScreen();
    }

    return app->exec();
}

