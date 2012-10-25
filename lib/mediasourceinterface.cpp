#include "mediasourceinterface.h"

class MediaSourceInterfacePrivate
{
public:
    MediaSourceInterfacePrivate():
        m_ready(false)
    {}

    bool m_ready;
};

MediaSourceInterface::MediaSourceInterface():
    QObject(),
    d_ptr(new MediaSourceInterfacePrivate)
{
}

bool MediaSourceInterface::ready() const
{
    Q_D(const MediaSourceInterface);
    return d->m_ready;
}

void MediaSourceInterface::setReady(bool ready)
{
    Q_D(MediaSourceInterface);

    if ( d->m_ready != ready){
        d->m_ready = ready;
        emit sourceReady();
    }
}
