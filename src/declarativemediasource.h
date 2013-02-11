
#ifndef DECLARATIVEMEDIASOURCE_H
#define DECLARATIVEMEDIASOURCE_H

#include <QObject>
#include <QUrl>
#include <QWeakPointer>

class DeclarativeMediaSource : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QUrl icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QUrl thumbnail READ thumbnail WRITE setThumbnail NOTIFY thumbnailChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QObject *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(bool ready READ isReady WRITE setReady NOTIFY readyChanged)

public:
    DeclarativeMediaSource();
    ~DeclarativeMediaSource();

    int count() const;
    void setCount(int count);

    QUrl icon() const;
    void setIcon(const QUrl &url);

    QUrl thumbnail() const;
    void setThumbnail(const QUrl &url);

    QString title() const;
    void setTitle(const QString &title);

    QObject *model() const;
    void setModel(QObject *model);

    bool isReady() const;
    void setReady(bool ready);

signals:
    void countChanged();
    void iconChanged();
    void thumbnailChanged();
    void titleChanged();
    void modelChanged();
    void readyChanged();

private:
    QWeakPointer<QObject> m_model;
    QUrl m_icon;
    QUrl m_thumbnail;
    QString m_title;
    int m_count;
    bool m_ready;
};

#endif
