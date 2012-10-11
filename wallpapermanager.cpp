#include "wallpapermanager.h"
#include <MGConfItem>
#include <QUrl>
#include <QtDebug>
WallpaperManager::WallpaperManager(QObject *parent) :
    QObject(parent),
    m_gconfItem(new MGConfItem("/desktop/meego/background/portrait/picture_filename", this))
{
    connect(m_gconfItem, SIGNAL(valueChanged()), this, SIGNAL(wallPaperChanged()));
}

void WallpaperManager::setWallpaper(const QUrl & url)
{
    m_gconfItem->set(url.toLocalFile());
}
