#ifndef DECLARATIVEMEDIAMODEL_H
#define DECLARATIVEMEDIAMODEL_H

#include <QAbstractListModel>
#include <QDeclarativeListProperty>
#include <QDeclarativeParserStatus>

class DeclarativeMediaSource;

class DeclarativeMediaModelPrivate;
class DeclarativeMediaModel : public QAbstractListModel, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QDeclarativeListProperty<DeclarativeMediaSource> sources READ sources)
    Q_PROPERTY(int count READ rowCount NOTIFY sourcesChanged)
    Q_INTERFACES(QDeclarativeParserStatus)
    Q_CLASSINFO("DefaultProperty", "sources")
public:
    enum MediaModelRoles {
        MediaRole
    };

    explicit DeclarativeMediaModel(QObject *parent = 0);

    virtual ~DeclarativeMediaModel();

    void classBegin();
    void componentComplete();

    QDeclarativeListProperty<DeclarativeMediaSource> sources();

    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    int rowCount ( const QModelIndex & parent = QModelIndex() ) const;

    QVariant data ( const QModelIndex & index, int role = Qt::DisplayRole ) const;


Q_SIGNALS:
    void sourcesChanged();

private slots:
    void updateActiveSources();

private:
    DeclarativeMediaModelPrivate * d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeMediaModel)
};

#endif // DECLARATIVEMEDIAMODEL_H
