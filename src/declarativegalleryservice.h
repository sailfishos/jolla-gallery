#ifndef DECLARATIVEGALLERYSERVICE_H
#define DECLARATIVEGALLERYSERVICE_H

#include <QObject>
#include <QStringList>

class DeclarativeGalleryService : public QObject
{
    Q_OBJECT
public:
    explicit DeclarativeGalleryService(QObject *parent = 0);
    ~DeclarativeGalleryService();

public slots:
    void showImages(const QStringList &urls);
    void openFile(const QString &file);
    void editFile(const QString &file);
    void shareFile(const QString &file);
    void showPhotos();
    void showVideos();
    void showScreenshots();
    void playVideoStream(const QStringList &urls);

signals:
    void openImages(const QStringList &urls, const QString &viewerAction);
    void showAllPhotos();
    void showAllVideos();
    void showAllScreenshots();
    void playStream(const QString &url);
};

#endif
