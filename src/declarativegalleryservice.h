/*
 * SPDX-FileCopyrightText: 2013-2021 Jolla Ltd.
 * SPDX-FileCopyrightText: 2021 Open Mobile Platform LLC.
 * SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef DECLARATIVEGALLERYSERVICE_H
#define DECLARATIVEGALLERYSERVICE_H

#include <QObject>

#include <QEventLoopLocker>
#include <QStringList>

class DeclarativeGalleryService : public QObject
{
    Q_OBJECT
public:
    explicit DeclarativeGalleryService(QObject *parent = 0);
    ~DeclarativeGalleryService();

public slots:
    void openUrl(const QStringList &urls);
    void showImages(const QStringList &urls);
    void openFile(const QString &file);
    void editFile(const QString &file);
    void shareFile(const QString &file);
    void showPhotos();
    void showVideos();
    void showScreenshots();
    void playVideoStream(const QStringList &urls);

protected:
    void timerEvent(QTimerEvent *event) override;

signals:
    void activate();
    void openImages(const QStringList &urls, const QString &viewerAction);
    void showAllPhotos();
    void showAllVideos();
    void showAllScreenshots();
    void playStream(const QString &url);

private:
    void windowShown();

    QScopedPointer<QEventLoopLocker> m_loopLocker;
    int m_timeoutId = -1;
};

#endif
