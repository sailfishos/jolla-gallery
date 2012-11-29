#include "declarativedbusinterface.h"

#include <QDBusMessage>
#include <QDBusConnection>
#include <QScriptEngine>
#include <QScriptValue>
#include <QFile>
#include <QUrl>

#include <qdeclarativeinfo.h>
#include <QtDebug>

DeclarativeDBusInterface::DeclarativeDBusInterface(QObject *parent)
    : QObject(parent)
{
}

DeclarativeDBusInterface::~DeclarativeDBusInterface()
{
}

QString DeclarativeDBusInterface::destination() const
{
    return m_destination;
}

void DeclarativeDBusInterface::setDestination(const QString &destination)
{
    if (m_destination != destination) {
        m_destination = destination;
        emit destinationChanged();
    }
}

QString DeclarativeDBusInterface::path() const
{
    return m_path;
}

void DeclarativeDBusInterface::setPath(const QString &path)
{
    if (m_path != path) {
        m_path = path;
        emit pathChanged();
    }
}

QString DeclarativeDBusInterface::interface() const
{
    return m_interface;
}

void DeclarativeDBusInterface::setInterface(const QString &interface)
{
    if (m_interface != interface) {
        m_interface = interface;
        emit interfaceChanged();
    }
}

void DeclarativeDBusInterface::call(const QString &method, const QScriptValue &arguments)
{
    QVariantList dbusArguments;

    if (arguments.isVariant())
        dbusArguments.append(arguments.toVariant());
    else if (arguments.isString())
        dbusArguments.append(arguments.toString());
    else if (arguments.isNumber())
        dbusArguments.append(arguments.toNumber());
    else if (arguments.isBool())
        dbusArguments.append(arguments.toBool());
    else if (arguments.isArray())
        qScriptValueToSequence(arguments, dbusArguments);

    QDBusMessage message = QDBusMessage::createMethodCall(
                m_destination,
                m_path,
                m_interface,
                method);
    message.setArguments(dbusArguments);
    if (!QDBusConnection::sessionBus().send(message))
        qmlInfo(this) << QDBusConnection::systemBus().lastError();
}

bool DeclarativeDBusInterface::removeFile(const QUrl &url)
{
    if (!url.isLocalFile()) {
        qmlInfo(this) << url << "is not a local file";
        return false;
    }

    return QFile::remove(url.toLocalFile());
}
