
#ifndef DECLARATIVEMEDIASOURCE_H
#define DECLARATIVEMEDIASOURCE_H

#include <QObject>
#include <QUrl>
#include <QWeakPointer>

/*!
 * \brief The DeclarativeMediaSource class
 *
 * Usage:
 *
 * MediaSource {
 *    icon: "/url/to/icon/component/Icon.qml"
 *    page: "/url/to/sourcepage/component/PluginPage.qml"
 *    title: "My Plugin"
 *    ready: model.count > 0
 *    model: MySourceModel {...}
 * }
 *
 * If thumbnail property is not defined, then the default Gallery thumbnail will be used.
 * If page property is not defined then GalleryGridPage will be used.
 * When setting the page property, it means that the plugin must provide the whole UI
 * and functionality, but this way it easier to provide customized look-and-feel for the
 * plugin functionality.
 *
 */
class DeclarativeMediaSource : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QUrl icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QUrl page READ page WRITE setPage NOTIFY pageChanged)
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

    QUrl page() const;
    void setPage(const QUrl &url);

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
    void pageChanged();
    void titleChanged();
    void modelChanged();
    void readyChanged();

private:
    QWeakPointer<QObject> m_model;
    QUrl m_icon;
    QUrl m_thumbnail;
    QUrl m_page;
    QString m_title;
    int m_count;
    bool m_ready;
};

#endif
