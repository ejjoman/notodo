#include "qmlsettings.h"

QmlSettings::QmlSettings(QObject *parent) :
    QObject(parent)
{
    this->_settings = new QSettings("harbour-notodo", "NoTodo", this);
}

void QmlSettings::saveSetting(const QString &key, const QVariant &value)
{
    this->_settings->setValue(key, value);
    this->_settings->sync();
}

QVariant QmlSettings::loadSetting(const QString &key, const QVariant &defaultValue)
{
    this->_settings->sync();

    QVariant value = this->_settings->value(key, defaultValue);

    // Ugly hack. Type of value is not correct - so use type of defaultValue, assuming that this is the correct type...
    switch (defaultValue.type()) {
    case QVariant::Bool:
        return value.toBool();

    case QVariant::Double:
        return value.toDouble();

    case QVariant::Int:
        return value.toInt();

    case QVariant::String:
        return value.toString();

    case QVariant::StringList:
        return value.toStringList();

    case QVariant::List:
        return value.toList();

    default:
        return value;

    }
}

QObject *QmlSettings::singletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    static QmlSettings *settings = NULL;

    if (!settings)
        settings = new QmlSettings();

    return settings;
}
