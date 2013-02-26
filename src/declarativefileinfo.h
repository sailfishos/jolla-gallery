#ifndef DECLARATIVEFILEINFO_H
#define DECLARATIVEFILEINFO_H

#include <QObject>
#include <QUrl>

class DeclarativeFileInfoPrivate;

// Simple helper class to get info about the file.
// TODO: Add support for figuring out if the file is image or video. Not sure yet,
//       which would be the best way to do it.
class DeclarativeFileInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool localFile READ localFile NOTIFY localFileChanged)

public:
    explicit DeclarativeFileInfo(QObject *parent = 0);
    ~DeclarativeFileInfo();

    void setSource(const QUrl &url);
    QUrl source() const;

    bool localFile() const;

    Q_INVOKABLE QUrl fromPercentEncoding(const QUrl &url) const;


Q_SIGNALS:
    void sourceChanged();
    void localFileChanged();

private:
    DeclarativeFileInfoPrivate *d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeFileInfo)
};

#endif // DECLARATIVEFILEINFO_H
