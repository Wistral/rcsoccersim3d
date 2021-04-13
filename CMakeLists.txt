cmake_minimum_required(VERSION 3.5)
project(rcsoccersim3d)

## compiler
set(CMAKE_C_COMPILER "/usr/bin/gcc-7")
set(CMAKE_CXX_COMPILER "/usr/bin/g++-7")
set(DEPEND_APT build-essential subversion make libfreetype6-dev libsdl1.2-dev ruby ruby-dev libdevil-dev libboost-dev libboost-thread-dev libboost-regex-dev libboost-system-dev qt4-default libqt4-opengl libqt4-opengl-dev autogen automake libtool)

option(DOMESTIC "use domestic mirror for acceleration" OFF)
option(WITH_TBB "use TBB multithread" OFF)
option(INST2SYS "install to system path(need sudo privilege)" ON)
option(WITH_ROBOVIZ "with RoboViz rebinded" ON)

set(RELEASE_PATH "rcsoccersim3d-release")

if(WITH_ROBOVIZ)
set(DEPEND_APT APPEND openjdk-8-jdk)
endif()

if(DOMESTIC)
    if(WITH_TBB)
        message(WARNING "Use ODE with TBB")
        set(ODE_URL "https://gitee.com/doot/ode-tbb.git")
    else(WITH_TBB)
        set(ODE_URL "https://gitee.com/yukareimu/ode.git")
    endif(WITH_TBB)
    
    set(SIMSPARK_URL "https://gitee.com/yukareimu/SimSpark.git")
    set(ROBOVIZ_URL "https://gitee.com/doot/RoboViz.git")
    
else(DOMESTIC)
    if(WITH_TBB)
        message(WARNING "Use ODE with TBB")
        set(ODE_URL "https://github.com/sgvandijk/ode-tbb.git")
    else(WITH_TBB)
        set(ODE_URL "https://bitbucket.org/odedevs/ode.git")
    endif(WITH_TBB)
    message(WARNING "ODE repo: ${ODE_URL}")
    set(SIMSPARK_URL "https://gitlab.com/robocup-sim/SimSpark")
    set(ROBOVIZ_URL "https://github.com/magmaOffenburg/RoboViz")
endif(DOMESTIC)

if(NOT ODE_URL OR NOT SIMSPARK_URL OR NOT ROBOVIZ_URL)
    message(FATAL_ERROR "Repository URL empty!")
endif()

foreach(URL ${ODE_URL} ${SIMSPARK_URL} ${ROBOVIZ_URL})
    message(STATUS "repo: ${URL}")
endforeach()
# custom targets
add_custom_target(pre_install
    COMMAND sudo apt update && sudo apt install -y ${DEPEND_APT}
)

# cmake externalproject
include(ExternalProject)

if(INST2SYS)
message(WARNING "Install to system path")

if(WITH_TBB)
externalproject_add(ODE
    GIT_REPOSITORY      ${ODE_URL}
    GIT_TAG             "master"
    # PREFIX              "ODE-tbb"
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND
    cd <SOURCE_DIR> && ./autogen.sh && ./configure --enable-shared --disable-demos --enable-double-precision --disable-asserts --enable-malloc && make -j$(nproc) && sudo make install
    DEPENDS pre_install
)
else(WITH_TBB)
# set(EXTERNALLIB_PREFIX ODElib)
externalproject_add(ODE
    GIT_REPOSITORY      ${ODE_URL}
    GIT_TAG             "ad7b31fb0b610752d1c5101678e7fff214b84639"
    CMAKE_ARGS
    "-DODE_DOUBLE_PRECISION=ON"
    "-DODE_WITH_DEMOS=OFF"
    "-DODE_WITH_TESTS=OFF"
    INSTALL_COMMAND
    sudo make install
    DEPENDS pre_install
)
endif(WITH_TBB)
externalproject_get_property(ODE SOURCE_DIR)
set(ODE_SOURCE_DIR ${SOURCE_DIR})

externalproject_add(SimSpark
    GIT_REPOSITORY      "${SIMSPARK_URL}"
    GIT_TAG             "master"
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND     cd <SOURCE_DIR> && bash build.sh
    DEPENDS ODE
)
externalproject_get_property(SimSpark SOURCE_DIR)
set(SimSpark_SOURCE_DIR ${SOURCE_DIR})
set(rcsoccersim3d_PATH /usr/local/bin/rcsoccersim3d)

else(INST2SYS)

if(WITH_TBB)
externalproject_add(ODE
    GIT_REPOSITORY      ${ODE_URL}
    GIT_TAG             "master"
    # PREFIX              "ODE-tbb"
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND
    cd <SOURCE_DIR> && ./autogen.sh && ./configure --prefix=<INSTALL_DIR> --enable-shared --disable-demos --enable-double-precision --disable-asserts --enable-malloc && make -j$(nproc) && sudo make install
    DEPENDS pre_install
)
else(WITH_TBB)
# set(EXTERNALLIB_PREFIX ODElib)
externalproject_add(ODE
    GIT_REPOSITORY      ${ODE_URL}
    GIT_TAG             "ad7b31fb0b610752d1c5101678e7fff214b84639"
    CMAKE_ARGS
    "-DBUILD_SHARED_LIBS=OFF"
    "-DODE_DOUBLE_PRECISION=ON"
    "-DODE_WITH_DEMOS=OFF"
    "-DODE_WITH_TESTS=OFF"
    "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>/../${RELEASE_PATH}"
    DEPENDS pre_install
)
endif(WITH_TBB)


externalproject_add(SimSpark
    GIT_REPOSITORY      ${SIMSPARK_URL}
    GIT_TAG             "e08e263e29787f899e70c8aecf4fe927df69198d"
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND     cd <SOURCE_DIR> && bash build-local.sh <INSTALL_DIR>/../${RELEASE_PATH} ${ODE_HOME}
    DEPENDS ODE
)
externalproject_get_property(SimSpark SOURCE_DIR)
set(SimSpark_SOURCE_DIR ${SOURCE_DIR})
set(rcsoccersim3d_PATH ${SOURCE_DIR}/../../bin/rcsoccersim3d)
endif(INST2SYS)

externalproject_get_property(ODE SOURCE_DIR)
set(ODE_SOURCE_DIR ${SOURCE_DIR})
externalproject_get_property(ODE BINARY_DIR)
set(ODE_BUILD_DIR ${BINARY_DIR})

if(WITH_ROBOVIZ)
externalproject_add(RoboViz
    GIT_REPOSITORY      ${ROBOVIZ_URL}
    GIT_TAG             "1.6.1"
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND     <SOURCE_DIR>/scripts/build-linux64.sh
    DEPENDS SimSpark
)

externalproject_get_property(RoboViz SOURCE_DIR)
set(RoboViz_SOURCE_DIR ${SOURCE_DIR})

if(NOT ${rcsoccersim3d_PATH})
    message(FATAL_ERROR "rcsoccersim3d_PATH empty")
endif()

set(ADir "$bindir/rcssmonitor3d")
set(BDir "${RoboViz_SOURCE_DIR}/bin/linux-amd64/roboviz.sh")
set(Cstr "s#${ADir}#${BDir}#")

add_custom_target(rcsoccersim3d
    COMMAND sudo sed -i "s#${ADir}#${BDir}#" ${rcsoccersim3d_PATH}
    WORKING_DIRECTORY ${RoboViz_SOURCE_DIR}
    DEPENDS RoboViz
)
endif(WITH_ROBOVIZ)

# add_custom_target(clean_all
#     COMMAND sudo rm -rf CMakeFiles 
#     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
# )

if(INST2SYS)
    SET(UNINS_CMD sudo make uninstall && make clean)
else(INST2SYS)
    SET(UNINS_CMD make uninstall && make clean)
endif()

add_custom_target(uninstall_ode
    COMMAND ${UNINS_CMD}
    WORKING_DIRECTORY ${ODE_BUILD_DIR}
)

add_custom_target(uninstall_rcssserver3d
    COMMAND ${UNINS_CMD}
    WORKING_DIRECTORY ${SimSpark_SOURCE_DIR}/rcssserver3d/build
)

add_custom_target(uninstall_simspark
    COMMAND ${UNINS_CMD}
    WORKING_DIRECTORY ${SimSpark_SOURCE_DIR}/spark/build
    DEPENDS uninstall_rcssserver3d
)

add_custom_target(uninstall_all
    DEPENDS uninstall_simspark uninstall_ode
)

add_custom_target(prepack
    COMMAND ldd ${RELEASE_PATH}/bin/rcssserver3d |grep -v shan|awk '{ if($$3 != \"not\") print $$3}'|xargs -i cp {} ${RELEASE_PATH}/lib
    COMMAND cp rcss3dinit.sh ${RELEASE_PATH}
)

add_custom_target(pack
    COMMAND tar -czf rcsoccersim3d.tgz ${RELEASE_PATH}
    DEPENDS prepack
)