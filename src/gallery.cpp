
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QtQml>
#include <QDir>
#include <QTranslator>
#include <QLocale>
#include <QtDebug>

#include "declarativemediamodel.h"
#include "declarativemediasource.h"
#include "declarativethreadedfileremover.h"
#include "declarativegalleryservice.h"
#include "declarativetextcodec.h"

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#include <qqmldebug.h>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);
    if (!qgetenv("QML_DEBUGGING_ENABLED").isEmpty()) {
        QQmlDebuggingEnabler qmlDebuggingEnabler;
    }

#ifdef HAS_BOOSTER
    QScopedPointer<QGuiApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QQuickView> view(MDeclarativeCache::qQuickView());
#else
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
    QScopedPointer<QQuickView> view(new QQuickView);
#endif

    app->setOrganizationName("com.jolla");
    app->setApplicationName("gallery");

    QString translationPath("/usr/share/translations/");

    QTranslator engineeringEnglish;
    engineeringEnglish.load("gallery_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "gallery", "-", translationPath);
    qApp->installTranslator(&translator);

    qmlRegisterType<DeclarativeMediaSource>("com.jolla.gallery", 1, 0, "MediaSource");
    qmlRegisterType<DeclarativeMediaModel>("com.jolla.gallery", 1, 0, "MediaSourceModel");
    qmlRegisterType<DeclarativeThreadedFileRemover>("com.jolla.gallery", 1, 0, "FileRemover");
    qmlRegisterType<DeclarativeGalleryService>("com.jolla.gallery", 1, 0, "GalleryService");
    qmlRegisterType<DeclarativeTextCodec>("com.jolla.gallery", 1, 0, "TextCodec");

    QString path = QString(DEPLOYMENT_PATH);

    //: Gallery application name
    //% "Gallery"
    view->setTitle(qtTrId("gallery-ap-name"));
    view->setSource(path + QLatin1String("gallery.qml"));
    view->showFullScreen();

    return app->exec();
}
