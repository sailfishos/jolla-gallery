#include "declarativewallpaper.h"
#include <MGConfItem>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QDir>
#include <QtDebug>
#include <QImage>

DeclarativeWallpaper::DeclarativeWallpaper(QObject *parent) :
    QObject(parent),
    m_gconfItem(new MGConfItem("/desktop/meego/background/portrait/picture_filename", this)),
    m_netMgr(0)
{
    connect(m_gconfItem, SIGNAL(valueChanged()), this, SIGNAL(sourceChanged()));
}

void DeclarativeWallpaper::setSource(const QUrl & url)
{
    QUrl oldWallpaper = source();
    if (oldWallpaper != url) {
        if (url.isLocalFile()) {
            m_gconfItem->set(url.toLocalFile());
        } else {
            setOnlineImage(url);
        }
    }
}

QUrl DeclarativeWallpaper::source() const
{
    return QUrl::fromLocalFile(m_gconfItem->value().toString());
}

void DeclarativeWallpaper::setOnlineImage(const QUrl &url)
{
    if (!m_netMgr){
        m_netMgr = new QNetworkAccessManager(this);
        connect(m_netMgr, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));
    }

    QNetworkRequest request(url);
    m_netMgr->get(request);
}

void DeclarativeWallpaper::finished(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Error in" << reply->url() << ":" << reply->errorString();
        return;
    }

    QByteArray data = reply->readAll();
    QImage image;
    image.loadFromData(data);
    reply->deleteLater();

    const QString path = nextOnlineFileName();

    if (!image.save(path)) {
        qWarning() << "Failed to save online image..." << path;
        return;
    }

    m_gconfItem->set(path);
}

QString DeclarativeWallpaper::nextOnlineFileName()
{
    const QString path = QDir::homePath() + QDir::separator() + QLatin1String("Pictures");
    QDir imageDir(path);
    QStringList fileList = imageDir.entryList(QStringList() << "online_img*", QDir::Files, QDir::Name);
    return path + QDir::separator() + QLatin1String("online_img") + QString::number(fileList.count()) + QLatin1String(".jpg");
}
