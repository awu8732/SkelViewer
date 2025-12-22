#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QFont>
#include <QDebug>
#include <QString>

#include "skel_lib/MotionData.h"
#include "skel_lib/PlaybackHub.h"
#include "skel_lib/SkeletonManager.h"
#include "skel_lib/SkeletonViewModel.h"
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

    // Register types for QML
    qmlRegisterType<SkeletonViewModel>("HMR_Trial_2", 1, 0, "SkeletonViewModel");
    qmlRegisterType<SkeletonManager>("HMR_Trial_2", 1, 0, "SkeletonManager");
    qmlRegisterUncreatableType<SkeletonInstance>("HMR_Trial_2", 1, 0, "SkeletonInstance", "");
    qmlRegisterUncreatableType<SkeletonPlayback>("HMR_Trial_2", 1, 0, "SkeletonPlayback", "");
    qmlRegisterUncreatableType<SkeletonViewModel>("HMR_Trial_2", 1, 0, "SkeletonViewModel", "");
    qmlRegisterSingletonInstance(
        "Utils", 1, 0, "UtilityProvider", new UtilityProvider()
    );
    qmlRegisterSingletonInstance(
        "HMR_Trial_2.Playback", 1, 0, "PlaybackHub", PlaybackHub::instance()
    );

    // Load binary / meta
    std::string bin_file = ":/qt/qml/HMR_Trial_2/tmp/oregon_test_1_ti0.bin";
    std::string meta_file = ":/qt/qml/HMR_Trial_2/tmp/oregon_test_1_ti0.meta.json";

    checkResourceExists(QString::fromStdString(bin_file));
    checkResourceExists(QString::fromStdString(meta_file));

    auto motion = std::make_shared<MotionData>(meta_file, bin_file, cfg);

    SkeletonManager* skeletonManager = new SkeletonManager(&engine);
    skeletonManager->addSkeleton(motion);       // First skeleton
    skeletonManager->duplicateSkeleton(0);      // Optional second skeleton
    engine.rootContext()->setContextProperty("skeletonManager", skeletonManager);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/HMR_Trial_2/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}

void setUIDefaults(QGuiApplication &app){
    QFont defaultFont;
    //defaultFont.setBold(true);
    defaultFont.setPixelSize(16);
    app.setFont(defaultFont);
}

bool checkResourceExists(const QString& resource_path) {
    QFile testPath(resource_path);
    bool exists = testPath.exists();
    qDebug() << resource_path << ": " << exists;
    return exists;
}

