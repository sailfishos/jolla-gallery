// SPDX-FileCopyrightText: 2012-2021 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

#include "declarativemediasource.h"

DeclarativeMediaSource::DeclarativeMediaSource()
    : m_count(0)
    , m_ready(false)
    , m_busy(false)
    , m_type(DeclarativeMediaSource::Undefined)
{
}

DeclarativeMediaSource::~DeclarativeMediaSource()
{
}

int DeclarativeMediaSource::count() const
{
    return m_count;
}

void DeclarativeMediaSource::setCount(int count)
{
    if (m_count != count) {
        m_count = count;
        emit countChanged();
    }
}

QUrl DeclarativeMediaSource::icon() const
{
    return m_icon;
}

void DeclarativeMediaSource::setIcon(const QUrl &url)
{
    if (m_icon != url) {
        m_icon = url;
        emit iconChanged();
    }
}

QUrl DeclarativeMediaSource::page() const
{
    return m_page;
}

void DeclarativeMediaSource::setPage(const QUrl &url)
{
    if (m_page != url) {
        m_page = url;
        emit pageChanged();
    }
}

QString DeclarativeMediaSource::title() const
{
    return m_title;
}

void DeclarativeMediaSource::setTitle(const QString &title)
{
    if (m_title != title) {
        m_title = title;
        emit titleChanged();
    }
}

QObject *DeclarativeMediaSource::model() const
{
    return m_model.data();
}

void DeclarativeMediaSource::setModel(QObject *model)
{
    if (m_model.data() != model) {
        m_model = model;
        emit modelChanged();
    }
}

bool DeclarativeMediaSource::isReady() const
{
    return m_ready;
}

void DeclarativeMediaSource::setReady(bool ready)
{
    if (ready != m_ready) {
        m_ready = ready;
        emit readyChanged();
    }
}

bool DeclarativeMediaSource::busy() const
{
    return m_busy;
}

void DeclarativeMediaSource::setBusy(bool busy)
{
    if (busy != m_busy) {
        m_busy = busy;
        emit busyChanged();
    }
}

DeclarativeMediaSource::Type DeclarativeMediaSource::type() const
{
    return m_type;
}

void DeclarativeMediaSource::setType(DeclarativeMediaSource::Type type)
{
    if (type != m_type) {
        m_type = type;
        emit typeChanged();
    }
}

