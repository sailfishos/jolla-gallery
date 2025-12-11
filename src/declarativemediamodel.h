/*
 * SPDX-FileCopyrightText: 2012-2018 Jolla Ltd.
 * SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef DECLARATIVEMEDIAMODEL_H
#define DECLARATIVEMEDIAMODEL_H

#include <QAbstractListModel>
#include <QQmlListProperty>
#include <QQmlParserStatus>

QT_BEGIN_NAMESPACE
class QQmlComponent;
QT_END_NAMESPACE

class DeclarativeMediaSource;

class DeclarativeMediaModelPrivate;
class DeclarativeMediaModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<DeclarativeMediaSource> sources READ sources)
    Q_PROPERTY(int count READ rowCount NOTIFY sourcesChanged)
    Q_PROPERTY(QQmlComponent *albumDelegate READ albumDelegate WRITE setAlbumDelegate NOTIFY albumDelegateChanged)
    Q_INTERFACES(QQmlParserStatus)
    Q_CLASSINFO("DefaultProperty", "sources")
public:
    enum MediaModelRoles {
        MediaRole
    };

    explicit DeclarativeMediaModel(QObject *parent = 0);
    explicit DeclarativeMediaModel(const QString &sourcesPath, QObject *parent = 0);

    virtual ~DeclarativeMediaModel();

    void classBegin();
    void componentComplete();

    QQmlListProperty<DeclarativeMediaSource> sources();

    QQmlComponent *albumDelegate() const;
    void setAlbumDelegate(QQmlComponent *albumDelegate);

    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;


Q_SIGNALS:
    void sourcesChanged();
    void albumDelegateChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const;

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
