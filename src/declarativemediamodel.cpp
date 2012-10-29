#include "declarativemediamodel.h"
#include "mediasourceinterface.h"
#include "mediasourcemodelinterface.h"
#include <QDir>
#include <QList>
#include <QPluginLoader>
#include <QtDebug>
#include <QDeclarativeEngine>

#define PLUGINPATH "/usr/lib/gallery"

class DeclarativeMediaModelPrivate
{
public:

    DeclarativeMediaModelPrivate(DeclarativeMediaModel * parent):
        q_ptr(parent)
    {
    }

    ~DeclarativeMediaModelPrivate()
    {
        qDeleteAll(m_plugins);
    }

    void loadPlugins()
    {
        Q_Q(DeclarativeMediaModel);
        QDir dir(PLUGINPATH);
        QStringList entries = dir.entryList(QStringList() << "*.so",
                          QDir::Files | QDir::NoDotAndDotDot, QDir::Name);

        if (entries.isEmpty()){
            qWarning() << "Failed to load MediaModel source plugins.";
            return;
        }

        QPluginLoader loader;
        loader.setLoadHints(QLibrary::ResolveAllSymbolsHint | QLibrary::ExportExternalSymbolsHint);
        foreach (const QString& entry, entries) {
            loader.setFileName(dir.absoluteFilePath(entry));
            MediaSourceInterface * source = qobject_cast<MediaSourceInterface*>(loader.instance());

            if (source == 0){
                qWarning() << "Failed to load MediaSourcePlugin: " << loader.errorString();
                return;
            }
            // TODO: Replace this a bit lighter approach, but for now this is the easiest.
            QObject::connect(source,SIGNAL(sourceReady()),q,SIGNAL(modelReset()));
            source->loadSource();
            m_plugins << source;
        }
    }

    QList<MediaSourceInterface*> m_plugins;
    DeclarativeMediaModel *q_ptr;
    Q_DECLARE_PUBLIC(DeclarativeMediaModel)
};



DeclarativeMediaModel::DeclarativeMediaModel(QObject *parent) :
    QAbstractListModel(parent),
    d_ptr(new DeclarativeMediaModelPrivate(this))
{
    QHash<int, QByteArray> roles;
    roles[MediaCountRole] = "mediaCount";
    roles[MediaQmlSourceIconRole] = "mediaQmlSourceIconUrl";
    roles[MediaTitleRole] = "mediaTitle";
    roles[MediaModelRole] = "mediaModel";
    setRoleNames(roles);

    Q_D(DeclarativeMediaModel);
    d->loadPlugins();
}

DeclarativeMediaModel::~DeclarativeMediaModel()
{
    delete d_ptr;
    d_ptr = 0;
}


int DeclarativeMediaModel::rowCount ( const QModelIndex & parent ) const
{
    Q_UNUSED(parent)
    Q_D(const DeclarativeMediaModel);
    int count = 0;
    Q_FOREACH(MediaSourceInterface * plugin, d->m_plugins){
        if (plugin->ready())
            ++count;
    }

    return count;
}

QVariant DeclarativeMediaModel::data ( const QModelIndex & index, int role) const
{
    Q_D(const DeclarativeMediaModel);
    if (d->m_plugins.count() - 1 > index.row()){
        qWarning() << "MediaModel::data: Index out of range";
        return QVariant();
    }

    MediaSourceInterface * mediaSource = d->m_plugins.at(index.row());
    if (!mediaSource->ready())
        return QVariant();

    switch(role){
    case MediaCountRole:
        return mediaSource->count();
    case MediaQmlSourceIconRole:
        return mediaSource->qmlSourceIcon();
    case MediaTitleRole:
        return mediaSource->title();
    case MediaModelRole:
        return QVariant::fromValue<QObject *>(mediaSource->mediaModel());
    default:
        qWarning() << "Unknown MediaModel role: " << role;
        break;
    }

    return QVariant();
}
