#include "declarativewallpaper.h"
#include <MGConfItem>

DeclarativeWallpaper::DeclarativeWallpaper(QObject *parent) :
    QObject(parent),
    m_gconfItem(new MGConfItem("/desktop/meego/background/portrait/picture_filename", this))
{
    connect(m_gconfItem, SIGNAL(valueChanged()), this, SIGNAL(sourceChanged()));
}

void DeclarativeWallpaper::setSource(const QUrl & url)
{
    QUrl oldWallpaper = source();
    if (oldWallpaper != url){
        m_gconfItem->set(url.toLocalFile());
    }
}

QUrl DeclarativeWallpaper::source() const
{
    return QUrl::fromLocalFile(m_gconfItem->value().toString());
}

