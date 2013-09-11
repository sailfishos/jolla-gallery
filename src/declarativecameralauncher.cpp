#include "declarativecameralauncher.h"
#include <contentaction.h>

DeclarativeCameraLauncher::DeclarativeCameraLauncher(QObject *parent) :
    QObject(parent)
{
}


void DeclarativeCameraLauncher::exec()
{
    ContentAction::Action action = ContentAction::Action::launcherAction(QStringLiteral("jolla-camera.desktop"),
                                                                         QStringList());
    action.trigger();
}
