#include "declarativemediamodel.h"
#include "declarativemediasource.h"
#include <QDirIterator>
#include <QList>
#include <QtDebug>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QDeclarativeEngine>

#define SOURCES_PATH "/usr/share/jolla-gallery/mediasources"

class DeclarativeMediaModelPrivate
{
public:

    DeclarativeMediaModelPrivate(DeclarativeMediaModel * parent):
        q_ptr(parent),
        m_componentComplete(false)
    {
    }

    ~DeclarativeMediaModelPrivate()
    {
        qDeleteAll(m_pluginSources);
    }


    static void source_append(QDeclarativeListProperty<DeclarativeMediaSource> *property, DeclarativeMediaSource *source)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        DeclarativeMediaModel *q = static_cast<DeclarativeMediaModel *>(property->object);
        d->m_staticSources.append(source);

        if (source->isReady())
            q->updateActiveSources();
    }

    static int source_count(QDeclarativeListProperty<DeclarativeMediaSource> *property)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        return d->m_activeSources.count();
    }

    static DeclarativeMediaSource *source_at(QDeclarativeListProperty<DeclarativeMediaSource> *property, int index)
    {
        DeclarativeMediaModelPrivate *d = static_cast<DeclarativeMediaModelPrivate *>(property->data);
        return d->m_activeSources.at(index);
    }

    DeclarativeMediaModel *q_ptr;
    QList<DeclarativeMediaSource *> m_staticSources;
    QList<DeclarativeMediaSource *> m_pluginSources;
    QList<DeclarativeMediaSource*> m_activeSources;
    bool m_componentComplete;

    Q_DECLARE_PUBLIC(DeclarativeMediaModel)
};



DeclarativeMediaModel::DeclarativeMediaModel(QObject *parent) :
    QAbstractListModel(parent),
    d_ptr(new DeclarativeMediaModelPrivate(this))
{
    QHash<int, QByteArray> roles;
    roles[MediaRole] = "media";
    setRoleNames(roles);
}

DeclarativeMediaModel::~DeclarativeMediaModel()
{
    delete d_ptr;
    d_ptr = 0;
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

    QDeclarativeContext *context = qmlContext(this);

    QDirIterator dir(QLatin1String(SOURCES_PATH));

    while (dir.hasNext()) {
        const QString fileName = dir.next();
        if (!fileName.endsWith(QLatin1String(".qml")))
            continue;

        QDeclarativeComponent component(context->engine(), fileName);
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
    }

    updateActiveSources();
}


QDeclarativeListProperty<DeclarativeMediaSource> DeclarativeMediaModel::sources()
{
    Q_D(DeclarativeMediaModel);
    return QDeclarativeListProperty<DeclarativeMediaSource>(
                this,
                d,
                DeclarativeMediaModelPrivate::source_append,
                DeclarativeMediaModelPrivate::source_count,
                DeclarativeMediaModelPrivate::source_at);
}

QModelIndex DeclarativeMediaModel::index(int row, int column, const QModelIndex &parent) const
{
    Q_D(const DeclarativeMediaModel);
    return !parent.isValid() && row >= 0 && row < d->m_activeSources.count() && column == 0
            ? createIndex(row, 0)
            : QModelIndex();
}

int DeclarativeMediaModel::rowCount ( const QModelIndex & parent ) const
{
    Q_D(const DeclarativeMediaModel);
    return !parent.isValid()
            ? d->m_activeSources.count()
            : 0;
}

QVariant DeclarativeMediaModel::data ( const QModelIndex & index, int role) const
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
    DeclarativeMediaSource *nextActiveSource = !d->m_activeSources.isEmpty()
            ? d->m_activeSources.first()
            : 0;
    for (int i = 0; i < d->m_staticSources.count(); ++i) {
        DeclarativeMediaSource *source = d->m_staticSources.at(i);
        if (nextActiveSource == source) {
            ++activeIndex;
            nextActiveSource = activeIndex < d->m_activeSources.count()
                    ? d->m_activeSources.at(activeIndex)
                    : 0;
        } else if (d->m_staticSources.at(i)->isReady()) {
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
        } else if (d->m_pluginSources.at(i)->isReady()) {
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
