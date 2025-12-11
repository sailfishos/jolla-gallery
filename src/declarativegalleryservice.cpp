// SPDX-FileCopyrightText: 2013-2021 Jolla Ltd.
// SPDX-FileCopyrightText: 2021 Open Mobile Platform LLC.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include "declarativegalleryservice.h"
#include "galleryadaptor.h"
#include <QtDebug>
#include <QTimerEvent>
#include <QUrl>

DeclarativeGalleryService::DeclarativeGalleryService(QObject *parent)
    : QObject(parent)
{
    new GalleryAdaptor(this);

    QDBusConnection connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/com/jolla/gallery/ui", this)) {
        qWarning() << Q_FUNC_INFO
                   << "Failed to register /com/jolla/gallery/ui object";
    }

    bool registeredService = connection.registerService("com.jolla.gallery");
    if (!registeredService) {
        qWarning() << Q_FUNC_INFO
                   << "Failed to register com.jolla.gallery service";
    }

    if (QCoreApplication::arguments().contains("-prestart")) {
        // Exit after 30 seconds if no window has been shown yet.
        m_loopLocker.reset(new QEventLoopLocker);

        m_timeoutId = startTimer(30 * 1000);
    }
}

DeclarativeGalleryService::~DeclarativeGalleryService()
{
    QDBusConnection::sessionBus().unregisterObject("/com/jolla/gallery/ui");
}

void DeclarativeGalleryService::openUrl(const QStringList &urls)
{
    if (urls.isEmpty()) {
        activate();
    } else {
        const QUrl url(urls.first());

        if (url.isLocalFile()) {
            QMimeType mimeType = QMimeDatabase().mimeTypeForUrl(url);

            if (mimeType.name().startsWith(QLatin1String("video/"))) {
                playVideoStream(urls);
            } else {
                showImages(urls);
            }
        } else {
            playVideoStream(urls);
        }
    }
    windowShown();
}

void DeclarativeGalleryService::showImages(const QStringList &urls)
{
    emit openImages(urls, QString());

    windowShown();
}

void DeclarativeGalleryService::openFile(const QString &file)
{
    emit openImages(QStringList(file), QString());

    windowShown();
}

void DeclarativeGalleryService::editFile(const QString &file)
{
    emit openImages(QStringList(file), QStringLiteral("edit"));

    windowShown();
}

void DeclarativeGalleryService::shareFile(const QString &file)
{
    emit openImages(QStringList(file), QStringLiteral("share"));

    windowShown();
}

void DeclarativeGalleryService::showPhotos()
{
    emit showAllPhotos();

    windowShown();
}

void DeclarativeGalleryService::showVideos()
{
    emit showAllVideos();

    windowShown();
}

void DeclarativeGalleryService::showScreenshots()
{
    emit showAllScreenshots();

    windowShown();
}

void DeclarativeGalleryService::playVideoStream(const QStringList &urls)
{
    if (!urls.isEmpty()) {
        QString cleanedUrl = QUrl(urls.at(0)).toDisplayString(QUrl::RemoveScheme
                                                              | QUrl::RemoveUserInfo
                                                              | QUrl::RemoveFragment
                                                              | QUrl::StripTrailingSlash);
        // Remove "//" between scheme and host.
        if (!cleanedUrl.remove(0, 2).isEmpty()) {
            emit playStream(urls.at(0));
        }
    }

    windowShown();
}

void DeclarativeGalleryService::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == m_timeoutId) {
        killTimer(m_timeoutId);
        m_timeoutId = -1;

        m_loopLocker.reset();
    } else {
        return QObject::timerEvent(event);
    }
}

void DeclarativeGalleryService::windowShown()
{
    if (m_timeoutId != -1) {
        killTimer(m_timeoutId);
        m_timeoutId = -1;
    }
    m_loopLocker.reset();
}
