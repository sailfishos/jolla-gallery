#ifndef WALLPAPERMANAGER_H
#define WALLPAPERMANAGER_H

#include <QObject>
class MGConfItem;
class QUrl;
class WallpaperManager : public QObject
{
    Q_OBJECT
public:
    explicit WallpaperManager(QObject *parent = 0);
    
signals:
    void wallPaperChanged();

public slots:
    void setWallpaper(const QUrl & url);

private:
    MGConfItem * m_gconfItem;
};

#endif // WALLPAPERMANAGER_H
