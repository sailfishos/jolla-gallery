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
    void showPhotos();
    void showVideos();
    void playVideoStream(const QStringList &urls);

signals:
    void openImages(const QStringList &urls);
    void showAllPhotos();
    void showAllVideos();
    void playStream(const QString &url);
};

#endif
