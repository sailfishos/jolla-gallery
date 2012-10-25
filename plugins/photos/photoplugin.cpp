#include "photoplugin.h"
#include "photomodel.h"
#include <QAbstractItemModel>
#include <QtPlugin>
#include <QtDebug>
#include <QtScript/QScriptEngine>

PhotoPlugin::PhotoPlugin():
    MediaSourceInterface()
{
}

PhotoPlugin::~PhotoPlugin()
{
    qDebug() << "PhotoPlugin deleted";
}

int PhotoPlugin::count() const
{
    return m_model->rowCount();
}

QUrl PhotoPlugin::sourceIcon() const
{
    QScriptEngine engine;
    QScriptValue obj = m_model->get(engine.toScriptValue(0));
    return QUrl(obj.property("url").toString());
}

QString PhotoPlugin::title() const
{
    return tr("Photos");
}

MediaSourceModelInterface *PhotoPlugin::mediaModel()
{
    qDebug() << "PhotoPlugin::mediaModel ";
    if (!m_model)
        loadSource();

    return m_model;
}

void PhotoPlugin::loadSource()
{

    m_model = new PhotoModel(this);
    connect(m_model,SIGNAL(finished()),this,SLOT(ready()));
    connect(m_model,SIGNAL(error(int,QString)),this,SLOT(error(int,QString)));
    m_model->execute();
}

void PhotoPlugin::ready()
{
    setReady(true);
}

void PhotoPlugin::error(int code, const QString error)
{
    // TODO: Handle errors properly
    qDebug() << "Error: " << code << " msg: " << error;
}

Q_EXPORT_PLUGIN2(photosplugin, PhotoPlugin);
