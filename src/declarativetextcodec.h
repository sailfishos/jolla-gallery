#ifndef DECLARATIVETEXTCODEC_H
#define DECLARATIVETEXTCODEC_H

#include <QObject>

class DeclarativeTextCodec : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString codecForLocale READ codecForLocale WRITE setCodecForLocale NOTIFY codecForLocaleChanged)
public:
    explicit DeclarativeTextCodec(QObject *parent = 0);

    QString codecForLocale() const;
    void setCodecForLocale(const QString &codecName);
    
signals:
    void codecForLocaleChanged();
};

#endif // DECLARATIVETEXTCODEC_H
