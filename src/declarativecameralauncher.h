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

#endif // DECLARATIVECAMERALAUNCHER_H
