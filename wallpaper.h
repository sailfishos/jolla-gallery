#ifndef WALLPAPERMANAGER_H
#define WALLPAPERMANAGER_H

#include <QObject>
#include <QUrl>

class MGConfItem;
class Wallpaper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
public:
    explicit Wallpaper(QObject *parent = 0);
    QUrl source() const;
    void setSource(const QUrl & url);

signals:
    void sourceChanged();

private:
    MGConfItem * m_gconfItem;
};

#endif // WALLPAPERMANAGER_H
