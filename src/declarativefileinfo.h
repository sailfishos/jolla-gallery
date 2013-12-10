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
    Q_PROPERTY(QString type READ type NOTIFY typeChanged)
    Q_PROPERTY(QString mimeType READ mimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged)

public:

    explicit DeclarativeFileInfo(QObject *parent = 0);
    ~DeclarativeFileInfo();

    void setSource(const QUrl &url);
    QUrl source() const;

    bool localFile() const;

    QString type() const;
    QString mimeType() const;
    QString fileName() const;

    Q_INVOKABLE QUrl fromPercentEncoding(const QUrl &url) const;


Q_SIGNALS:
    void sourceChanged();
    void localFileChanged();
    void typeChanged();
    void mimeTypeChanged();
    void fileNameChanged();

private:
    DeclarativeFileInfoPrivate *d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeFileInfo)
};

#endif // DECLARATIVEFILEINFO_H
