#include "declarativetextcodec.h"
#include <QTextCodec>
#include <QtDebug>

DeclarativeTextCodec::DeclarativeTextCodec(QObject *parent) :
    QObject(parent)
{
}

QString DeclarativeTextCodec::codecForLocale() const
{
    QTextCodec *c = QTextCodec::codecForLocale();

    if (c) {
        return QTextCodec::codecForLocale()->name();
    } else {
        return QString();
    }
}

void DeclarativeTextCodec::setCodecForLocale(const QString &codecName)
{
    QTextCodec *c = QTextCodec::codecForLocale();

    if (!c) {
        qWarning() << Q_FUNC_INFO << "NULL Codec for locale!";
        return;
    }

    if (codecName.toUtf8() != c->name()) {
        QTextCodec::setCodecForLocale(QTextCodec::codecForName(codecName.toUtf8()));
        emit codecForLocaleChanged();
    }
}

