#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFile>
#include <QFont>
#include <QDebug>
#include <QStandardPaths>
#include <QString>

#include "skel_lib/MotionData.h"
#include "skel_lib/PlaybackHub.h"
#include "skel_lib/SkeletonManager.h"
#include "skel_lib/SkeletonMeshGeometry.h"
#include "skel_lib/SkeletonViewModel.h"
#include "skel_lib/SingleViewerConfiguration.h"
#include "skel_lib/UtilityProvider.h"

bool checkResourceExists(const QString& resourcePath);
void setUIDefaults(QGuiApplication &app);
QString extractResourceToTemp(const QString& resPath);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    SingleViewerConfiguration cfg;
    setUIDefaults(app);

    // Register types for QML
    qmlRegisterType<SkeletonMeshGeometry>("HMR_Trial_2", 1, 0, "SkeletonMeshGeometry");
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
    std::string oregon_file = ":/qt/qml/HMR_Trial_2/tmp/smpl_oregon_1_202512_fwd1.npz";
    std::string oregon_file_2 = ":/qt/qml/HMR_Trial_2/tmp/amss_oregon_2_20251215_skel_fwd.npz";

    checkResourceExists(QString::fromStdString(bin_file));
    checkResourceExists(QString::fromStdString(meta_file));
    //checkResourceExists(QString::fromStdString(oregon_file));

    // /auto motion = std::make_shared<MotionData>(meta_file, bin_file, cfg);
    QString npzPath = extractResourceToTemp(QString::fromStdString(oregon_file_2));
    cfg.type = "skel";
    auto smpl_motion = std::make_shared<MotionData>(
        npzPath.toStdString(), cfg
    );

    SkeletonManager* skeletonManager = new SkeletonManager(&engine);
    skeletonManager->addSkeleton(smpl_motion);       // First skeleton
    //skeletonManager->duplicateSkeleton(0);      // Optional second skeleton
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

QString extractResourceToTemp(const QString& resPath)
{
    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QDir().mkpath(tempDir);

    QString outPath = tempDir + "/" + QFileInfo(resPath).fileName();

    QFile in(resPath);
    QFile out(outPath);

    if (!in.open(QIODevice::ReadOnly))
        throw std::runtime_error("Failed to open resource");

    if (!out.open(QIODevice::WriteOnly))
        throw std::runtime_error("Failed to create temp file");

    out.write(in.readAll());

    return outPath;
}
