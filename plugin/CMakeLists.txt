cmake_minimum_required(VERSION 3.16)

set(QT_MIN_VERSION "6.5.0")
set(KF_MIN_VERSION "6.0.0")

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs6)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Quick Qml)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS Plasma)

set(qml_SRCS
	qmldir
)

set(cpp_SRCS
	plugin.cpp
	volumepeaks.cpp
)

add_library(plasma-volumewin7mixer-declarative SHARED ${cpp_SRCS})
target_link_libraries(plasma-volumewin7mixer-declarative
	Qt6::Quick
	Qt6::Qml
	KF6::Plasma
)

set(PRIVATE_QML_INSTALL_DIR ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/volumewin7mixer)
install(TARGETS plasma-volumewin7mixer-declarative DESTINATION ${PRIVATE_QML_INSTALL_DIR})
install(FILES ${qml_SRCS} DESTINATION ${PRIVATE_QML_INSTALL_DIR})
