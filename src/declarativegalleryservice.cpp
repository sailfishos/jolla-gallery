#include "declarativegalleryservice.h"
#include "galleryadaptor.h"
#include <QtDebug>
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
}

DeclarativeGalleryService::~DeclarativeGalleryService()
{
    QDBusConnection::sessionBus().unregisterObject("/com/jolla/gallery/ui");    
}


void DeclarativeGalleryService::showImages(const QStringList &urls)
{
    emit openImages(urls);
}

void DeclarativeGalleryService::openFile(const QString &file)
{
    emit openImages(QStringList(file));
}

void DeclarativeGalleryService::showPhotos()
{
    emit showAllPhotos();
}

void DeclarativeGalleryService::showVideos()
{
    emit showAllVideos();
}

void DeclarativeGalleryService::showScreenshots()
{
    emit showAllScreenshots();
}

void DeclarativeGalleryService::playVideoStream(const QStringList &urls)
{
    if (!urls.isEmpty()) {
        QString cleanedUrl = QUrl(urls.at(0)).toDisplayString(QUrl::RemoveScheme |
                                                              QUrl::RemoveUserInfo |
                                                              QUrl::RemoveFragment |
                                                              QUrl::StripTrailingSlash);
        // Remove "//" between scheme and host.
        if (!cleanedUrl.remove(0, 2).isEmpty()) {
            emit playStream(urls.at(0));
        }
    }
}
