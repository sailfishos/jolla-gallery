#include "wallpaper.h"
#include <MGConfItem>

Wallpaper::Wallpaper(QObject *parent) :
    QObject(parent),
    m_gconfItem(new MGConfItem("/desktop/meego/background/portrait/picture_filename", this))
{
    connect(m_gconfItem, SIGNAL(valueChanged()), this, SIGNAL(sourceChanged()));
}

void Wallpaper::setSource(const QUrl & url)
{
    QUrl oldWallpaper = source();
    if (oldWallpaper != url){
        m_gconfItem->set(url.toLocalFile());
    }
}

QUrl Wallpaper::source() const
{
    return QUrl::fromLocalFile(m_gconfItem->value().toString());
}

