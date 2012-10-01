#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

#include <QDir>
#include <QDeclarativeError>
#include <QDeclarativeEngine>
#include <QDeclarativeComponent>
#include <QDeclarativeContext>
#include <QDebug>
#include <QDeclarativeItem>

static void loadDummyDataFiles(QDeclarativeEngine &engine, const QString path)
{
    QDir dir(path + QDir::separator() + QLatin1String("dummydata"), "*.qml");
    QStringList list = dir.entryList();
    for (int i = 0; i < list.size(); ++i) {
        QString qml = list.at(i);
        QFile f(dir.absoluteFilePath(qml));
        f.open(QIODevice::ReadOnly);
        QByteArray data = f.readAll();
        QDeclarativeComponent comp(&engine);
        comp.setData(data, QUrl(QUrl::fromLocalFile(dir.absoluteFilePath(qml))));
        QObject *dummyData = comp.create();

        if(comp.isError()) {
            QList<QDeclarativeError> errors = comp.errors();
            foreach (const QDeclarativeError &error, errors)
                qWarning() << error;
        }

        if (dummyData) {
            qWarning() << "Loaded dummy data:" << dir.filePath(qml);
            qml.truncate(qml.length()-4);
            engine.rootContext()->setContextProperty(qml, dummyData);
            dummyData->setParent(&engine);
        }
    }
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    QmlApplicationViewer viewer;
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    QString path;

    if (app->arguments().contains("-desktop")) {
        path = app->applicationDirPath() + QDir::separator();
    } else {
        path = QString(DEPLOYMENT_PATH);
    }

    loadDummyDataFiles(*viewer.engine(), path);
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

