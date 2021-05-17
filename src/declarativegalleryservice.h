/****************************************************************************************
**
** Copyright (c) 2013 - 2020 Jolla Ltd.
** Copyright (c) 2021 Open Mobile Platform LLC.
** All rights reserved.
**
** License: Proprietary
**
****************************************************************************************/

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
