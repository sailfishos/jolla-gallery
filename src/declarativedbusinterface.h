#ifndef DECLARATIVEDBUSINTERFACE_H
#define DECLARATIVEDBUSINTERFACE_H

#include <QObject>

QT_BEGIN_NAMESPACE
class QScriptValue;
class QUrl;
QT_END_NAMESPACE

class DeclarativeDBusInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString iface READ interface WRITE setInterface NOTIFY interfaceChanged)
public:
    DeclarativeDBusInterface(QObject *parent = 0);
    ~DeclarativeDBusInterface();

    QString destination() const;
    void setDestination(const QString &destination);

    QString path() const;
    void setPath(const QString &path);

    QString interface() const;
    void setInterface(const QString &interface);

    Q_INVOKABLE void call(const QString &method, const QScriptValue &arguments);
    Q_INVOKABLE bool removeFile(const QUrl &url);

signals:
    void destinationChanged();
    void pathChanged();
    void interfaceChanged();

private:
    QString m_destination;
    QString m_path;
    QString m_interface;
};

#endif
