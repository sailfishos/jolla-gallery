#ifndef MEDIASOURCEPLUGIN_H
#define MEDIASOURCEPLUGIN_H

#include <QUrl>
#include <QObject>


class MediaSourceModelInterface;
class MediaSourceInterfacePrivate;


class Q_DECL_EXPORT MediaSourceInterface: public QObject
{
    Q_OBJECT
public:
    MediaSourceInterface();

    virtual int count() const = 0;

    virtual QUrl sourceIcon() const = 0;

    virtual QString title() const = 0;

    virtual MediaSourceModelInterface *mediaModel() = 0;

    virtual void loadSource() = 0;

    bool ready() const;

signals:
    void sourceReady();

protected:
    void setReady(bool ready);

private:
    MediaSourceInterfacePrivate *d_ptr;
    Q_DECLARE_PRIVATE(MediaSourceInterface)
};


Q_DECLARE_INTERFACE(MediaSourceInterface, "com.jolla.MediaSourceInterface/1.0")


#endif // MEDIASOURCEPLUGIN_H
