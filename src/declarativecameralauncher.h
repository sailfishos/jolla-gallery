#ifndef DECLARATIVECAMERALAUNCHER_H
#define DECLARATIVECAMERALAUNCHER_H

#include <QObject>
class QQmlEngine;
class QJSEngine;
class DeclarativeCameraLauncher : public QObject
{
    Q_OBJECT
public:
    explicit DeclarativeCameraLauncher(QObject *parent = 0);
    Q_INVOKABLE void exec();
};

static QObject *camera_launcher_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new DeclarativeCameraLauncher;
}
#endif // DECLARATIVECAMERALAUNCHER_H
