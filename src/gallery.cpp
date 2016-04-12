
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QtQml>
#include <QDir>
#include <QTranslator>
#include <QLocale>
#include <QtDebug>

#include <QtDBus/QDBusConnection>

#include "declarativemediamodel.h"
#include "declarativemediasource.h"
#include "declarativefileinfo.h"
#include "declarativethreadedfileremover.h"
#include "declarativecameralauncher.h"
#include "declarativegalleryservice.h"
#include "declarativetextcodec.h"

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);
#ifdef HAS_BOOSTER
    QScopedPointer<QGuiApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QQuickView> view(MDeclarativeCache::qQuickView());
#else
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
    QScopedPointer<QQuickView> view(new QQuickView);
#endif

    QDBusConnection connection = QDBusConnection::sessionBus();
    bool registeredService = connection.registerService("com.jolla.gallery");
    if (!registeredService) {
        qWarning() << Q_FUNC_INFO
                   << "Failed to register com.jolla.gallery service";
    }

    QString translationPath("/usr/share/translations/");

    // First try to load translation files for gallery extensions
    QDir extDir(translationPath + QDir::separator() + "gallery-extensions");
    QStringList qmExtFiles = extDir.entryList(QStringList() << "*.qm", QDir::Files);

    foreach(QString qmFile, qmExtFiles) {
        QTranslator *extEngineeringEnglish = new QTranslator(view->engine());
        extEngineeringEnglish->load(qmFile, extDir.absolutePath());
        qApp->installTranslator(extEngineeringEnglish);

        QTranslator *extTranslator = new QTranslator(view->engine());
        extTranslator->load(QLocale(), qmFile, "-", extDir.absolutePath());
        qApp->installTranslator(extTranslator);
    }


    // Second load the gallery translation files
    QTranslator engineeringEnglish;
    engineeringEnglish.load("gallery_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "gallery", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeFileInfo>("com.jolla.gallery", 1, 0, "FileInfo");
    qmlRegisterType<DeclarativeMediaSource>("com.jolla.gallery", 1, 0, "MediaSource");
    qmlRegisterType<DeclarativeMediaModel>("com.jolla.gallery", 1, 0, "MediaSourceModel");
    qmlRegisterType<DeclarativeThreadedFileRemover>("com.jolla.gallery", 1, 0, "FileRemover");
    qmlRegisterType<DeclarativeGalleryService>("com.jolla.gallery", 1, 0, "GalleryService");
    qmlRegisterType<DeclarativeTextCodec>("com.jolla.gallery", 1, 0, "TextCodec");

    qmlRegisterSingletonType<DeclarativeCameraLauncher>("com.jolla.gallery", 1, 0, "CameraLauncher", camera_launcher_provider);
    QString path = QString(DEPLOYMENT_PATH);

    //: Gallery application name
    //% "Gallery"
    view->setTitle(qtTrId("gallery-ap-name"));
    view->setSource(path + QLatin1String("gallery.qml"));
    view->showFullScreen();

    return app->exec();
}
