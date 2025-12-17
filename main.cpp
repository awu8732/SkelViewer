#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QFont>
#include <QDebug>
#include <QString>

#include "skel_lib/DataLoaderBinary.h"
#include "skel_lib/JointProvider3D.h"
#include "skel_lib/SingleViewerConfiguration.h"
#include "skel_lib/UtilityProvider.h"

bool checkResourceExists(const QString& resourcePath);
void setUIDefaults(QGuiApplication &app);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    SingleViewerConfiguration cfg;
    setUIDefaults(app);
    qmlRegisterType<JointProvider3D>("HMR_Trial_2", 1, 0, "JointProvider3D");
    qmlRegisterSingletonInstance("Utils", 1, 0, "UtilityProvider",
                                 new UtilityProvider());

    std::string bin_file = ":/qt/qml/HMR_Trial_2/tmp/oregon_test_1_ti0.bin";
    std::string meta_file = ":/qt/qml/HMR_Trial_2/tmp/oregon_test_1_ti0.meta.json";

    // --- Optional: Check resources exist ---
    checkResourceExists(QString::fromStdString(bin_file));
    checkResourceExists(QString::fromStdString(meta_file));

    // --- Initialize DataLoaderBinary using QRC paths ---
    DataLoaderBinary* dlb = new DataLoaderBinary(
        meta_file, bin_file, cfg
    );

    // First skeleton
    JointProvider3D jp(dlb);
    engine.rootContext()->setContextProperty("jointProvider3D", &jp);

    // Second skeleton
    JointProvider3D jp2(dlb);
    engine.rootContext()->setContextProperty("jointProvider3D_2", &jp2);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/HMR_Trial_2/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}

void setUIDefaults(QGuiApplication &app){
    QFont defaultFont;
    //defaultFont.setBold(true);
    defaultFont.setPixelSize(18);
    app.setFont(defaultFont);
}

bool checkResourceExists(const QString& resource_path) {
    QFile testPath(resource_path);
    bool exists = testPath.exists();
    qDebug() << resource_path << ": " << exists;
    return exists;
}

