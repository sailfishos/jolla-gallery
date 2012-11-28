
#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QtDeclarative>
#include <QDir>
#include <QTranslator>
#include <QLocale>

#include "declarativewallpaper.h"
#include "declarativemediamodel.h"
#include "declarativemediasource.h"

#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef HAS_BOOSTER
    QScopedPointer<QApplication> app(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(MDeclarativeCache::qDeclarativeView());
#else
    QScopedPointer<QApplication> app(new QApplication(argc, argv));
    QScopedPointer<QDeclarativeView> view(new QDeclarativeView);
#endif

    QString translationPath("/usr/share/translations/");
    QString extTranslationFile("gallery_content_eng_en");

    if (QFile::exists(translationPath + QDir::separator() + extTranslationFile + ".qm")) {
        QTranslator *extEngineeringEnglish = new QTranslator(view->engine());
        extEngineeringEnglish->load(extTranslationFile, translationPath);
        qApp->installTranslator(extEngineeringEnglish);

        QTranslator *extTranslator = new QTranslator(view->engine());
        extTranslator->load(QLocale(), "gallery_content", "-", translationPath);
        qApp->installTranslator(extTranslator);
    }


    QTranslator engineeringEnglish;
    engineeringEnglish.load("gallery_eng_en", translationPath);
    qApp->installTranslator(&engineeringEnglish);

    QTranslator translator;
    translator.load(QLocale(), "gallery", "-", translationPath);
    qApp->installTranslator(&translator);



    qmlRegisterType<DeclarativeMediaSource>("com.jolla.gallery", 1, 0, "MediaSource");
    qmlRegisterType<DeclarativeMediaModel>("com.jolla.gallery", 1, 0, "MediaSourceModel");

    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
    view->setAutoFillBackground(false);
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    view->viewport()->setAutoFillBackground(false);

    QString path;
    if (app->arguments().contains("-desktop")) {
        path = app->applicationDirPath() + QDir::separator();
    } else {
        path = QString(DEPLOYMENT_PATH);
    }

    DeclarativeWallpaper wallpaper;
    view->rootContext()->setContextProperty("wallpaper", &wallpaper);

    view->setSource(path + QLatin1String("gallery.qml"));

    if (app->arguments().contains("-desktop"))
    {
        view->setFixedSize(480, 854);
        view->rootObject()->setProperty("_desktop", true);
        view->show();
    } else {
        view->showFullScreen();
    }

    return app->exec();
}

