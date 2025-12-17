cmake_minimum_required(VERSION 3.16)

set(QT_CREATOR_SKIP_VCPKG_SETUP ON)
project(HMR_Trial_2 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(Qt6 6.7 REQUIRED COMPONENTS Quick)

# set(fmt_DIR "D:/vcpkg/installed/x64-windows/share/fmt")
# set(Eigen3_DIR "D:/vcpkg/installed/x64-windows/share/eigen3")
# set(nlohmann_json_DIR "D:/vcpkg/installed/x64-windows/share/nlohmann-json")

set(QT_QML_DEBUG TRUE)

qt_standard_project_setup(REQUIRES 6.7)

qt_add_executable(appHMR_Trial_2
    resources.qrc
    main.cpp
)

qt_add_qml_module(appHMR_Trial_2
    URI HMR_Trial_2
    QML_FILES
        Main.qml
        ui_modules/CameraControls.qml
        ui_modules/CameraSlider.qml
        ui_modules/HUD.qml
        ui_modules/SceneView.qml
        ui_modules/FrameSlider.qml
        ui_modules/MenuBar.qml
        ui_modules/MenuButton.qml
        ui_modules/MotionScatter.qml
        ui_modules/PlaybackHub.qml
        ui_modules/RootImprint.qml
        ui_modules/SideControl.qml
        ui_modules/SkeletonModel.qml
        ui_modules/utility.js
    SOURCES
        skel_lib/DataLoaderBinary.cpp
        skel_lib/JointProvider3D.cpp
        skel_lib/UtilityProvider.cpp

        skel_lib/SingleViewerConfiguration.h
        skel_lib/ArrayMeta.h
        skel_lib/DataLoaderBinary.h
        skel_lib/JointProvider3D.h
        skel_lib/UtilityProvider.h
    RESOURCES
        tmp/oregon_test_1_ti0.bin
        tmp/oregon_test_1_ti0.meta.json
        tmp/wu_squat_185_ti0.bin
        tmp/wu_squat_185_ti0.meta.json
        tmp/coleman_01_ti0.bin
        tmp/coleman_01_ti0.meta.json
)

qt_add_resources(appHMR_Trial_2 "resources"
    PREFIX "/"
    FILES qtquickcontrols2.conf
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appHMR_Trial_2 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appHMR_Trial_2
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

find_package(fmt CONFIG REQUIRED)
find_package(Eigen3 REQUIRED)

target_link_libraries(appHMR_Trial_2 PRIVATE
    Qt6::Quick
    fmt::fmt
    Eigen3::Eigen
)

include(GNUInstallDirs)
install(TARGETS appHMR_Trial_2
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
