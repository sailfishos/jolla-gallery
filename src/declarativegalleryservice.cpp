#include "declarativegalleryservice.h"
#include "galleryadaptor.h"
#include <QtDebug>

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
