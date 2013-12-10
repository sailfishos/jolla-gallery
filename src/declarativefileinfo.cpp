#include "declarativefileinfo.h"
#include <QMimeDatabase>
#include <QMimeType>
#include <QFileInfo>

class DeclarativeFileInfoPrivate
{
public:
    QUrl m_url;
    QFileInfo m_info;
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
    QString oldMimeType = mimeType();
    QString oldType = type();
    QString oldFileName = fileName();

    if (d->m_url != url) {
        d->m_url = url;
        d->m_info.setFile(d->m_url.toLocalFile());
        emit sourceChanged();
    }

    if (isLocalFile != localFile()) {
        emit localFileChanged();
    }

    if (oldType != type()) {
        emit typeChanged();
    }

    if (oldMimeType != mimeType()) {
        emit mimeTypeChanged();
    }

    if (oldFileName != fileName()) {
        emit fileNameChanged();
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

QString DeclarativeFileInfo::mimeType() const
{
    Q_D(const DeclarativeFileInfo);
    if (d->m_url.isEmpty()) {
        return QString();
    }

    QMimeDatabase db;
    QMimeType mimeType;
    if (localFile()) {
        mimeType = db.mimeTypeForFile(d->m_info);
    } else {
        mimeType = db.mimeTypeForUrl(d->m_url);
    }
    return mimeType.name();
}

QString DeclarativeFileInfo::fileName() const
{
    Q_D(const DeclarativeFileInfo);
    if (d->m_url.isEmpty()) {
        return QString();
    }
    return d->m_info.fileName();
}

QString DeclarativeFileInfo::type() const
{
    const QString mt = mimeType();
    if (!mt.contains(QLatin1String("/"))) {
        return QString();
    }

    return mt.left(mt.indexOf(QLatin1String("/")));
}
