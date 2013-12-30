
#include "declarativemediamodel.h"
#include "declarativemediasource.h"
#include "declarativedbusinterface.h"
#include "declarativefileinfo.h"
#include "declarativethreadedfileremover.h"
#include "declarativegalleryservice.h"

#include <QQmlExtensionPlugin>
#include <qqml.h>

#include <QtDebug>
#include <QDBusAbstractAdaptor>
#include <QDBusConnection>
#include <QDBusError>
#include <QDBusMetaType>
#include <QStringList>
#include <QVector>

class TestDBusService;

class TestMediaModel : public DeclarativeMediaModel
{
public:
    TestMediaModel(QObject *parent = 0)
        : DeclarativeMediaModel(QLatin1String("/opt/tests/jolla-gallery/mediasources"), parent)
    {
    }
};

class JollaGalleryPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.jolla.gallery")

public:
    virtual void registerTypes(const char *uri)
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.jolla.gallery"));

        QDBusConnection connection = QDBusConnection::sessionBus();
        bool registeredService = connection.registerService("com.jolla.gallery");
        if (!registeredService) {
            qWarning() << Q_FUNC_INFO
                       << "Failed to register com.jolla.gallery service";
        }

        qmlRegisterType<DeclarativeFileInfo>("com.jolla.gallery", 1, 0, "FileInfo");
        qmlRegisterType<DeclarativeMediaSource>("com.jolla.gallery", 1, 0, "MediaSource");
        qmlRegisterType<TestMediaModel>("com.jolla.gallery", 1, 0, "MediaSourceModel");
        qmlRegisterType<DeclarativeDBusInterface>("com.jolla.gallery", 1, 0, "DBusInterface");
        qmlRegisterType<DeclarativeThreadedFileRemover>("com.jolla.gallery", 1, 0, "FileRemover");
        qmlRegisterType<DeclarativeGalleryService>("com.jolla.gallery", 1, 0, "GalleryService");
    }
};

#include "main.moc"

