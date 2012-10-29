#ifndef MEDIASOURCEMODELINTERFACE_H
#define MEDIASOURCEMODELINTERFACE_H

#include <QtScript/QScriptValue>
#include <QAbstractListModel>

/*!
 * \brief The MediaSourceModelInterface class is an interface that all the source models in Gallery must implement.
 *
 * MediaSourceModelInterface combines two different interfaces: QAbstractListMode and the one this class introduces.
 *
 * Subclassing:
 * Subclass this MediaSourceModelInterface and implement QAbstractListModel::rowCount() and QAbstractListModel::data()
 * methods. Provide implementation for MediaSourceModelInterface::count() and MediaSourceModelInterface::get() methods.
 * These are used by the QML components in gallery.
 *
 * When model is ready, make sure to emit finished() signal. Also when model's count changes emit countChanged() signal.
 */
class MediaSourceModelInterface: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    MediaSourceModelInterface(QObject * parent = 0);

    virtual int count() const = 0;

    Q_INVOKABLE virtual QScriptValue get(const QScriptValue &index) const = 0;

signals:
    void finished();
    void error(int, QString);
    void countChanged();
};

#endif // MEDIASOURCEMODELINTERFACE_H
