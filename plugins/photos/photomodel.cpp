#include "photomodel.h"
#include <QDocumentGallery>
#include <QUrl>
#include <QtDebug>
#include <QtScript/QScriptEngine>

QTM_USE_NAMESPACE
PhotoModel::PhotoModel(QObject * parent):
    MediaSourceModelInterface(parent)
{
    m_subModel = new QGalleryQueryModel(new QDocumentGallery);
    m_subModel->setRootType(QDocumentGallery::Image);
    m_subModel->setAutoUpdate(true);

    QHash<int, QByteArray> roleNames;
    roleNames[UrlRole] = "url";
    setRoleNames(roleNames);

    QHash<int, QString> properties;
    properties.insert(UrlRole, QDocumentGallery::url);
    m_subModel->addColumn(properties);

    connect(m_subModel, SIGNAL(finished()), this, SIGNAL(finished()));
    connect(m_subModel, SIGNAL(modelReset()), this, SIGNAL(modelReset()));
    connect(m_subModel, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SIGNAL(rowsInserted(QModelIndex,int,int)));
    connect(m_subModel, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SIGNAL(rowsRemoved(QModelIndex,int,int)));
    connect(m_subModel, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SIGNAL(countChanged()));
    connect(m_subModel, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SIGNAL(countChanged()));
    connect(m_subModel, SIGNAL(dataChanged(QModelIndex,QModelIndex)), this, SIGNAL(dataChanged(QModelIndex,QModelIndex)));
    // TODO Add other signal connections here too
}

PhotoModel::~PhotoModel()
{
    delete m_subModel;
}



int PhotoModel::rowCount(const QModelIndex & parent) const
{
    return m_subModel->rowCount(parent);
}

QVariant PhotoModel::data(const QModelIndex &index, int role) const
{
    return m_subModel->data(index, role);
}

void PhotoModel::execute()
{
    m_subModel->execute();
}

int PhotoModel::count() const
{
    return m_subModel->rowCount();
}

QScriptValue PhotoModel::get(const QScriptValue &index) const
{
    QScriptEngine *scriptEngine = index.engine();

    if (!scriptEngine)
       return QScriptValue();

    const int i = index.toInt32();

    if (i < 0 || i >= rowCount())
       return scriptEngine->undefinedValue();

    QScriptValue object = scriptEngine->newObject();
    QVariant url = data(createIndex(i,0), UrlRole);
    object.setProperty(QLatin1String("url"), scriptEngine->toScriptValue(url.toString()));
    object.setProperty(QLatin1String("mimeType"), scriptEngine->toScriptValue(QString("image")));
    qDebug() << "dada";
    return object;
}
