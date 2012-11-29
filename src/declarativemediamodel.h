#ifndef DECLARATIVEMEDIAMODEL_H
#define DECLARATIVEMEDIAMODEL_H

#include <QAbstractListModel>
#include <QDeclarativeListProperty>
#include <QDeclarativeParserStatus>

QT_BEGIN_NAMESPACE
class QDeclarativeComponent;
QT_END_NAMESPACE

class DeclarativeMediaSource;

class DeclarativeMediaModelPrivate;
class DeclarativeMediaModel : public QAbstractListModel, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QDeclarativeListProperty<DeclarativeMediaSource> sources READ sources)
    Q_PROPERTY(int count READ rowCount NOTIFY sourcesChanged)
    Q_PROPERTY(QDeclarativeComponent *albumDelegate READ albumDelegate WRITE setAlbumDelegate NOTIFY albumDelegateChanged)
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

    QDeclarativeComponent *albumDelegate() const;
    void setAlbumDelegate(QDeclarativeComponent *albumDelegate);

    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    int rowCount ( const QModelIndex & parent = QModelIndex() ) const;

    QVariant data ( const QModelIndex & index, int role = Qt::DisplayRole ) const;


Q_SIGNALS:
    void sourcesChanged();
    void albumDelegateChanged();

private slots:
    void updateActiveSources();
    void albumsInserted(int index, int count);
    void albumsRemoved(int index, int count);
    void albumDataChanged(int index, int count, const QList<int> &keys);

private:
    DeclarativeMediaModelPrivate * d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeMediaModel)
};

#endif // DECLARATIVEMEDIAMODEL_H
