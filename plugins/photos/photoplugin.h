#ifndef PHOTO_PLUGIN_HH
#define PHOTO_PLUGIN_HH

#include "mediasourceinterface.h"
#include <QPointer>

class PhotoModel;
class Q_DECL_EXPORT PhotoPlugin: public MediaSourceInterface
{
    Q_OBJECT
    Q_INTERFACES(MediaSourceInterface)
public:

    PhotoPlugin();
    virtual ~PhotoPlugin();

    int count() const;

    QUrl qmlSourceIcon() const;

    QString title() const;

    MediaSourceModelInterface *mediaModel();

    void loadSource();

private slots:
    void ready();
    void error(int code, const QString error);

private:
    QPointer <PhotoModel> m_model;

};
#endif
