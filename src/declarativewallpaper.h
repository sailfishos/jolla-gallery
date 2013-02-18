#ifndef DECLARATIVEWALLPAPER_H
#define DECLARATIVEWALLPAPER_H

#include <QObject>
#include <QUrl>

class MGConfItem;
class QNetworkAccessManager;
class QNetworkReply;
class DeclarativeWallpaper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
public:
    explicit DeclarativeWallpaper(QObject *parent = 0);
    QUrl source() const;
    void setSource(const QUrl & url);

Q_SIGNALS:
    void sourceChanged();

private Q_SLOTS:
    void finished(QNetworkReply *reply);

private:
    void setOnlineImage(const QUrl &url);
    QString nextOnlineFileName();

private:
    MGConfItem * m_gconfItem;
    QNetworkAccessManager *m_netMgr;
};

#endif // DECLARATIVEWALLPAPER_H
