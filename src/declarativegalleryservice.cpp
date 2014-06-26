#include "declarativegalleryservice.h"
#include "galleryadaptor.h"
#include <QtDebug>
#include <QUrl>

DeclarativeGalleryService::DeclarativeGalleryService(QObject *parent)
    : QObject(parent)
{
    new GalleryAdaptor(this);
    // We have already registered the service in Gallery's main
    QDBusConnection connection = QDBusConnection::sessionBus();
    if (!connection.registerObject("/com/jolla/gallery/ui", this)) {
        qWarning() << Q_FUNC_INFO
                   << "Failed to register /com/jolla/gallery/ui object";
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

void DeclarativeGalleryService::showPhotos()
{
    emit showAllPhotos();
}

void DeclarativeGalleryService::showVideos()
{
    emit showAllVideos();
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
