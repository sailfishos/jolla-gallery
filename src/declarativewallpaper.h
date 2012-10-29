#ifndef DECLARATIVEWALLPAPER_H
#define DECLARATIVEWALLPAPER_H

#include <QObject>
#include <QUrl>

class MGConfItem;
class DeclarativeWallpaper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
public:
    explicit DeclarativeWallpaper(QObject *parent = 0);
    QUrl source() const;
    void setSource(const QUrl & url);

signals:
    void sourceChanged();

private:
    MGConfItem * m_gconfItem;
};

#endif // DECLARATIVEWALLPAPER_H
