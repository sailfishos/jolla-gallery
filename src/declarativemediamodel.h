#ifndef DECLARATIVEMEDIAMODEL_H
#define DECLARATIVEMEDIAMODEL_H

#include <QAbstractItemModel>

class DeclarativeMediaModelPrivate;
class DeclarativeMediaModel : public QAbstractItemModel
{
    Q_OBJECT
public:
    enum MediaModelRoles {
        MediaCountRole = Qt::UserRole + 1,
        MediaQmlSourceIconRole,
        MediaTitleRole,
        MediaModelRole
    };

    explicit DeclarativeMediaModel(QObject *parent = 0);

    ~DeclarativeMediaModel();

    QModelIndex index ( int row, int column, const QModelIndex & parent = QModelIndex() ) const;

    QModelIndex parent ( const QModelIndex & index ) const;

    int rowCount ( const QModelIndex & parent = QModelIndex() ) const;

    int columnCount ( const QModelIndex & parent = QModelIndex() ) const;

    QVariant data ( const QModelIndex & index, int role = Qt::DisplayRole ) const;


private:
    DeclarativeMediaModelPrivate * d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeMediaModel)
};

#endif // DECLARATIVEMEDIAMODEL_H
