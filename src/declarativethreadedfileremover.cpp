// SPDX-FileCopyrightText: 2013-2016 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include "declarativethreadedfileremover.h"
#include <QFile>
#include <QtConcurrentMap>
#include <qqmlinfo.h>

static bool removeFile(const QString &filePath)
{
    QUrl url(filePath);
    return QFile::remove(url.toLocalFile());
}

DeclarativeThreadedFileRemover::DeclarativeThreadedFileRemover(QObject *parent)
    : QObject(parent)
    , m_watcher(new QFutureWatcher<bool>(this))
{
    connect(m_watcher, SIGNAL(finished()), this, SIGNAL(finished()));
}

void DeclarativeThreadedFileRemover::deleteFiles(const QStringList &files)
{
    m_watcher->setFuture(QtConcurrent::mapped(files, removeFile));
}

bool DeclarativeThreadedFileRemover::deleteFileSync(const QUrl &url)
{
    if (!url.isLocalFile()) {
        qmlInfo(this) << url << "is not a local file";
        return false;
    }

    return QFile::remove(url.toLocalFile());
}
