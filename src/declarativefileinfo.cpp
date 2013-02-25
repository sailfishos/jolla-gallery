#include "declarativefileinfo.h"
#include <QDebug>
#include <QTextCodec>

class DeclarativeFileInfoPrivate
{
public:
    QUrl m_url;
};

DeclarativeFileInfo::DeclarativeFileInfo(QObject *parent) :
    QObject(parent),
    d_ptr(new DeclarativeFileInfoPrivate)
{
}

DeclarativeFileInfo::~DeclarativeFileInfo()
{
    delete d_ptr;
}

void DeclarativeFileInfo::setSource(const QUrl &url)
{
    Q_D(DeclarativeFileInfo);
    bool isLocalFile = localFile();

    if (d->m_url != url) {
        d->m_url = url;
        emit sourceChanged();
    }

    if (isLocalFile != localFile()) {
        emit localFileChanged();
    }
}

QUrl DeclarativeFileInfo::source() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_url;
}

bool DeclarativeFileInfo::localFile() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_url.isLocalFile();
}

QUrl DeclarativeFileInfo::fromPercentEncoding(const QUrl &url) const
{
    return QUrl(QByteArray::fromPercentEncoding(url.toString().toLatin1()));
}

