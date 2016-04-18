#ifndef DECLARATIVETHREADEDFILEREMOVER_H
#define DECLARATIVETHREADEDFILEREMOVER_H

#include <QObject>
#include <QStringList>
#include <QFutureWatcher>
#include <QUrl>

class DeclarativeThreadedFileRemover : public QObject
{
    Q_OBJECT
public:
    explicit DeclarativeThreadedFileRemover(QObject *parent = 0);

    Q_INVOKABLE void deleteFiles(const QStringList &files);
    Q_INVOKABLE bool deleteFileSync(const QUrl &url);

Q_SIGNALS:
    void finished();

private:
    QFutureWatcher<bool> *m_watcher;
};

#endif // DECLARATIVETHREADEDFILEREMOVER_H
