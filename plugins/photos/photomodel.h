#ifndef PHOTOMODEL_H
#define PHOTOMODEL_H

#include "mediasourcemodelinterface.h"
#include <QGalleryQueryModel>

QTM_USE_NAMESPACE
class PhotoModel: public MediaSourceModelInterface
{
public:
    enum PhotoModelRoles {
        UrlRole = Qt::UserRole + 1
    };

    explicit PhotoModel(QObject * parent = 0);
    virtual ~PhotoModel();

    int rowCount ( const QModelIndex & parent = QModelIndex() ) const;
    QVariant data(const QModelIndex &index, int role) const;

    void execute();

    int count() const;

    Q_INVOKABLE QScriptValue get(const QScriptValue &index) const;

private:
    QGalleryQueryModel *m_subModel;
};

#endif // PHOTOMODEL_H
