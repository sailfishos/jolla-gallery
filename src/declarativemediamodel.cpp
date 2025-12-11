// SPDX-FileCopyrightText: 2012-2018 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include "declarativemediamodel.h"
#include "declarativemediasource.h"
#include <QDirIterator>
#include <QList>
#include <QtDebug>
#include <QQmlContext>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QDocumentGallery>
#include <QGalleryQueryRequest>
#include <QGalleryResultSet>

#define SOURCES_PATH "/usr/share/jolla-gallery/mediasources"

using namespace QDocGallery;

class AlbumContentData : public QQmlContext
{
    Q_OBJECT
    Q_PROPERTY(QVariant albumId READ albumId CONSTANT)
    Q_PROPERTY(QString albumTitle READ albumTitle NOTIFY albumTitleChanged)
    Q_PROPERTY(int albumCount READ albumCount NOTIFY albumCountChanged)
public:
    AlbumContentData(
                QQmlContext *parentContext,
                int index,
                QGalleryResultSet *resultSet,
                int titleKey,
                int countKey)
        : QQmlContext(parentContext)
        , source(0)
        , m_resultSet(resultSet)
        , m_index(index)
        , m_titleKey(titleKey)
        , m_countKey(countKey)
    {
        setContextObject(this);
    }

    QVariant albumId() const { m_resultSet->fetch(m_index); return m_resultSet->itemId(); }
    QString albumTitle() const { m_resultSet->fetch(m_index); return m_resultSet->metaData(m_titleKey).toString(); }
    int albumCount() const { m_resultSet->fetch(m_index); return m_resultSet->metaData(m_countKey).toInt(); }

    void adjustIndex(int delta) { m_index += delta; }
    void refreshAlbumCount() { emit albumCountChanged(); }

    DeclarativeMediaSource *source;

#ifdef Q_MOC_RUN   // Makes the signals public functions to everything but moc.
signals:
#endif
    void albumTitleChanged();
    void albumCountChanged();

private:
    QGalleryResultSet *m_resultSet;
    int m_index;
    int m_titleKey;
    int m_countKey;
};

class DeclarativeMediaModelPrivate
{
public:

    DeclarativeMediaModelPrivate(DeclarativeMediaModel * parent):
        q_ptr(parent),
        m_albumDelegate(0),
        m_componentComplete(false)
    {
    }

    ~DeclarativeMediaModelPrivate()
    {
        qDeleteAll(m_pluginSources);
    }

    void queryAlbums();

    static void source_append(QQmlListProperty<DeclarativeMediaSource> *property, DeclarativeMediaSource *source)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        DeclarativeMediaModel *q = static_cast<DeclarativeMediaModel *>(property->object);
        d->m_staticSources.append(source);

        if (source->isReady())
            q->updateActiveSources();
    }

    static int source_count(QQmlListProperty<DeclarativeMediaSource> *property)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        return d->m_activeSources.count();
    }

    static DeclarativeMediaSource *source_at(QQmlListProperty<DeclarativeMediaSource> *property, int index)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        return d->m_activeSources.at(index);
    }

    static void source_clear(QQmlListProperty<DeclarativeMediaSource> *property)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        DeclarativeMediaModel *q = static_cast<DeclarativeMediaModel *>(property->object);
        d->m_staticSources.clear();
        q->updateActiveSources();
    }

    DeclarativeMediaModel *q_ptr;
    QQmlComponent *m_albumDelegate;
    QList<DeclarativeMediaSource *> m_staticSources;
    QList<AlbumContentData *> m_albumSources;
    QList<DeclarativeMediaSource *> m_pluginSources;
    QList<DeclarativeMediaSource *> m_activeSources;
    QDocumentGallery m_gallery; // Should create a static instance if it looks like there will be multiple requests.
    QGalleryQueryRequest m_albumsRequest;
    QString m_sourcesPath;
    bool m_componentComplete;

    Q_DECLARE_PUBLIC(DeclarativeMediaModel)
};


void DeclarativeMediaModelPrivate::queryAlbums()
{
    Q_Q(DeclarativeMediaModel);

    m_albumsRequest.execute();

    if (QGalleryResultSet *resultSet = m_albumsRequest.resultSet()) {
        QObject::connect(resultSet, SIGNAL(itemsInserted(int,int)),
                         q, SLOT(albumsInserted(int,int)));
        QObject::connect(resultSet, SIGNAL(itemsRemoved(int,int)),
                         q, SLOT(albumsRemoved(int,int)));
        QObject::connect(resultSet, SIGNAL(metaDataChanged(int,int,QList<int>)),
                         q, SLOT(albumDataChanged(int,int,QList<int>)));

        if (resultSet->itemCount() > 0)
            q->albumsInserted(0, resultSet->itemCount());
    }
}

DeclarativeMediaModel::DeclarativeMediaModel(QObject *parent) :
    QAbstractListModel(parent),
    d_ptr(new DeclarativeMediaModelPrivate(this))
{
    d_ptr->m_sourcesPath = QLatin1String(SOURCES_PATH);
}


DeclarativeMediaModel::DeclarativeMediaModel(const QString &sourcesPath, QObject *parent)
    : QAbstractListModel(parent)
    , d_ptr(new DeclarativeMediaModelPrivate(this))
{
    d_ptr->m_sourcesPath = sourcesPath;
}

DeclarativeMediaModel::~DeclarativeMediaModel()
{
    delete d_ptr;
    d_ptr = 0;
}

QHash<int, QByteArray> DeclarativeMediaModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[MediaRole] = "media";
    return roles;
}

void DeclarativeMediaModel::classBegin()
{
}

void DeclarativeMediaModel::componentComplete()
{
    Q_D(DeclarativeMediaModel);
    if (d->m_componentComplete)
        return;
    d->m_componentComplete = true;

    QQmlContext *context = qmlContext(this);

    QDirIterator dir(d->m_sourcesPath);

    while (dir.hasNext()) {
        const QString fileName = dir.next();
        if (!fileName.endsWith(QLatin1String(".qml")))
            continue;

        QQmlComponent component(context->engine(), fileName);
        if (component.isReady()) {
            QObject *object = component.create();   // Create in the root context.
            if (DeclarativeMediaSource *mediaSource = qobject_cast<DeclarativeMediaSource *>(object)) {
                d->m_pluginSources.append(mediaSource);
                if (!mediaSource->isReady())
                    QObject::connect(mediaSource, SIGNAL(readyChanged()), this, SLOT(updateActiveSources()));
            } else {
                delete object;
            }
        }
        if (component.isError()) {
            Q_FOREACH(QQmlError error, component.errors()) {
                qWarning() << error.toString();
            }
        }
    }

    d->m_albumsRequest.setGallery(&d->m_gallery);
    d->m_albumsRequest.setRootType(QDocumentGallery::PhotoAlbum);
    d->m_albumsRequest.setPropertyNames(QStringList()
            << QDocumentGallery::title
            << QDocumentGallery::count);
    d->m_albumsRequest.setSortPropertyNames(QStringList()
            << QDocumentGallery::title.ascending());
    d->m_albumsRequest.setAutoUpdate(true);

    if (d->m_albumDelegate)
        d->queryAlbums();

    updateActiveSources();
}

QQmlListProperty<DeclarativeMediaSource> DeclarativeMediaModel::sources()
{
    Q_D(DeclarativeMediaModel);
    return QQmlListProperty<DeclarativeMediaSource>(
                this,
                d,
                DeclarativeMediaModelPrivate::source_append,
                DeclarativeMediaModelPrivate::source_count,
                DeclarativeMediaModelPrivate::source_at,
                DeclarativeMediaModelPrivate::source_clear);
}

QQmlComponent *DeclarativeMediaModel::albumDelegate() const
{
    Q_D(const DeclarativeMediaModel);
    return d->m_albumDelegate;
}

void DeclarativeMediaModel::setAlbumDelegate(QQmlComponent *delegate)
{
    Q_D(DeclarativeMediaModel);
    if (d->m_albumDelegate != delegate) {
        d->m_albumDelegate = delegate;

        if (d->m_albumSources.count() > 0)
            albumsRemoved(0, d->m_albumSources.count());

        if (d->m_componentComplete) {
            if (d->m_albumsRequest.state() == QGalleryAbstractRequest::Inactive)
                d->queryAlbums();
            else if (d->m_albumsRequest.itemCount() > 0)
                albumsInserted(0, d->m_albumsRequest.itemCount());
        }
        emit albumDelegateChanged();
    }
}

QModelIndex DeclarativeMediaModel::index(int row, int column, const QModelIndex &parent) const
{
    Q_D(const DeclarativeMediaModel);
    return !parent.isValid() && row >= 0 && row < d->m_activeSources.count() && column == 0
            ? createIndex(row, 0)
            : QModelIndex();
}

int DeclarativeMediaModel::rowCount(const QModelIndex &parent) const
{
    Q_D(const DeclarativeMediaModel);
    return !parent.isValid()
            ? d->m_activeSources.count()
            : 0;
}

QVariant DeclarativeMediaModel::data(const QModelIndex &index, int role) const
{
    Q_D(const DeclarativeMediaModel);
    if (!index.isValid()) {
        qWarning() << "MediaModel::data: Index out of range";
        return QVariant();
    }

    DeclarativeMediaSource *mediaSource = d->m_activeSources.at(index.row());
    if (role == MediaRole)
        return QVariant::fromValue<QObject *>(mediaSource);

    return QVariant();
}


void DeclarativeMediaModel::updateActiveSources()
{
    Q_D(DeclarativeMediaModel);

    if (!d->m_componentComplete)
        return;

    bool changed = false;
    int activeIndex = 0;

    // clean away inactive sources
    for (int i = 0; i < d->m_activeSources.count(); ++i) {
        DeclarativeMediaSource *source = d->m_activeSources.at(i);
        if (!source->isReady()) {
            beginRemoveRows(QModelIndex(), i, i);
            d->m_activeSources.removeAt(i);
            i--;
            endRemoveRows();
            changed = true;
        }
    }

    QObject *nextActiveSource = !d->m_activeSources.isEmpty()
            ? d->m_activeSources.first()
            : 0;
    for (int i = 0; i < d->m_staticSources.count(); ++i) {
        DeclarativeMediaSource *source = d->m_staticSources.at(i);
        if (nextActiveSource == source) {
            ++activeIndex;
            nextActiveSource = activeIndex < d->m_activeSources.count()
                    ? d->m_activeSources.at(activeIndex)
                    : 0;
        } else if (source->isReady()) {
            beginInsertRows(QModelIndex(), activeIndex, activeIndex);
            d->m_activeSources.insert(activeIndex, source);
            ++activeIndex;
            endInsertRows();
            changed = true;
        }
    }

    for (int i = 0; i < d->m_albumSources.count(); ++i) {
        if (!d->m_albumSources.at(i))
            continue;
        DeclarativeMediaSource *source = d->m_albumSources.at(i)->source;

        if (nextActiveSource == source) {
            ++activeIndex;
            nextActiveSource = activeIndex < d->m_activeSources.count()
                    ? d->m_activeSources.at(activeIndex)
                    : 0;
        } else if (source->isReady()) {
            beginInsertRows(QModelIndex(), activeIndex, activeIndex);
            d->m_activeSources.insert(activeIndex, source);
            ++activeIndex;
            endInsertRows();
            changed = true;
        }
    }

    for (int i = 0; i < d->m_pluginSources.count(); ++i) {
        DeclarativeMediaSource *source = d->m_pluginSources.at(i);
        if (nextActiveSource == source) {
            ++activeIndex;
            nextActiveSource = activeIndex < d->m_activeSources.count()
                    ? d->m_activeSources.at(activeIndex)
                    : 0;
        } else if (source->isReady()) {
            beginInsertRows(QModelIndex(), activeIndex, activeIndex);
            d->m_activeSources.insert(activeIndex, source);
            ++activeIndex;
            endInsertRows();
            changed = true;
        }
    }

    if (changed)
        emit sourcesChanged();
}

void DeclarativeMediaModel::albumsInserted(int index, int count)
{
    Q_D(DeclarativeMediaModel);

    bool activeChanged = false;

    QGalleryResultSet *resultSet = d->m_albumsRequest.resultSet();

    const int titleKey = resultSet->propertyKey(QDocumentGallery::title);
    const int countKey = resultSet->propertyKey(QDocumentGallery::count);

    QQmlContext *context = d->m_albumDelegate->creationContext();
    if (!context)
        context = qmlContext(this);

    for (int i = index; i < index + count; ++i) {
        AlbumContentData *data = new AlbumContentData(context, i, resultSet, titleKey, countKey);
        if (QObject *object = d->m_albumDelegate->create(data)) {
            data->setParent(object);
            if (!(data->source = qobject_cast<DeclarativeMediaSource *>(object)))
                delete object;
        }
        if (!data->source) {
            delete data;
            // Insert a null pointer so there remains a one-to-one relationship between
            // items in the result set and the albumsSources list.
            d->m_albumSources.insert(i, 0);
        } else {
            if (!data->source->isReady())
                connect(data->source, SIGNAL(readyChanged()), this, SLOT(updateActiveSources()));
            d->m_albumSources.insert(i, data);
            activeChanged = true;
        }
    }

    for (int i = index + count; i < d->m_albumSources.count(); ++i) {
        if (AlbumContentData *data = d->m_albumSources.at(i))
            data->adjustIndex(count);
    }

    if (activeChanged)
        updateActiveSources();
}

void DeclarativeMediaModel::albumsRemoved(int index, int count)
{
    Q_D(DeclarativeMediaModel);

    int firstIndex = -1;
    int lastIndex = 0;
    int activeCount = 0;

    for (int i = 0; i < count; ++i) {
        if (AlbumContentData *data = d->m_albumSources.at(index)) {
            data->source->deleteLater();
            if (data->source->isReady()) {
                lastIndex = d->m_activeSources.indexOf(data->source, lastIndex);
                if (firstIndex == -1)
                    firstIndex = lastIndex;
                ++activeCount;
            }
        }
        d->m_albumSources.removeAt(index);
    }

    for (int i = index; i < d->m_albumSources.count(); ++i) {
        if (AlbumContentData *data = d->m_albumSources.at(i))
            data->adjustIndex(-count);
    }

    if (activeCount > 0) {
        beginRemoveRows(QModelIndex(), firstIndex, firstIndex + activeCount - 1);
        for (int i = 0; i < activeCount; ++i)
            d->m_activeSources.removeAt(firstIndex);
        endRemoveRows();
    }
}

void DeclarativeMediaModel::albumDataChanged(int index, int count, const QList<int> &keys)
{
    Q_D(DeclarativeMediaModel);

    const bool titleChanged = keys.isEmpty() || keys.contains(0);
    const bool countChanged = keys.isEmpty() || keys.contains(1);

    for (int i = index; i < index + count; ++i) {
        if (AlbumContentData *data = d->m_albumSources.at(index)) {
            if (titleChanged)
                emit data->albumTitleChanged();
            if (countChanged)
                emit data->albumCountChanged();
        }
    }
}

#include "declarativemediamodel.moc"
