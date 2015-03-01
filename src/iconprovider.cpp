#include "iconprovider.h"

#include <sailfishapp.h>
#include <QPainter>
#include <QColor>

IconProvider::IconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap IconProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QStringList parts = id.split('?');

    QPixmap sourcePixmap(QUrl(parts.at(0)).toString(QUrl::RemoveScheme));

    if (size)
        *size  = sourcePixmap.size();

    if (parts.length() > 1 && QColor::isValidColor(parts.at(1))) {
        QPainter painter(&sourcePixmap);
        painter.setCompositionMode(QPainter::CompositionMode_SourceIn);
        painter.fillRect(sourcePixmap.rect(), parts.at(1));
        painter.end();
    }

    if (requestedSize.width() > 0 && requestedSize.height() > 0)
        return sourcePixmap.scaled(requestedSize.width(), requestedSize.height(), Qt::IgnoreAspectRatio);
    else
        return sourcePixmap;
}
