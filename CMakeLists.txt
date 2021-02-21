cmake_minimum_required(VERSION 3.5)
project(rcsoccoersim3d)

## compiler
set(CMAKE_C_COMPILER "/usr/bin/gcc-7")
set(CMAKE_CXX_COMPILER "/usr/bin/g++-7")
set(DEPEND_APT build-essential subversion cmake make libfreetype6-dev libsdl1.2-dev ruby ruby-dev libdevil-dev libboost-dev libboost-thread-dev libboost-regex-dev libboost-system-dev qt4-default libqt4-opengl libqt4-opengl-dev openjdk-8-jdk autogen automake libtool)

option(DOMESTIC "use domestic mirror for acceleration" OFF)
option(WITH_TBB "use TBB multithread" OFF)
option(INSTALL_TO_SYSTEM "install to system path(need sudo privilege)" ON)
option(WITH_ROBOVIZ "with RoboViz rebinded" ON)

if(DOMESTIC)
    if(WITH_TBB)
        message(WARNING "Use ODE with TBB")
        set(ODE_URL "https://gitee.com/doot/ode-tbb.git")
    else(WITH_TBB)
        set(ODE_URL "https://gitee.com/yukareimu/ode.git")
    endif(WITH_TBB)
    
    set(SIMSPARK_URL "https://gitee.com/yukareimu/SimSpark.git")
    set(ROBOVIZ_URL "https://gitee.com/doot/RoboViz.git")
    foreach(URL ${ODE_URL} ${SIMSPARK_URL} ${ROBOVIZ_URL})
        message(STATUS "repo: ${URL}")
    endforeach()
    
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

# custom targets
add_custom_target(pre_install
    COMMAND sudo apt update && sudo apt install -y ${DEPEND_APT}
)

# cmake externalproject
include(ExternalProject)

if(INSTALL_TO_SYSTEM)
message(WARNING "Install to system path")

if(WITH_TBB)
externalproject_add(ODE
    GIT_REPOSITORY      ${ODE_URL}
    GIT_TAG             "master"
    PREFIX              "ODE-tbb"
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
    GIT_TAG             "master"
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
endif(WITH_ROBOVIZ)
else(INSTALL_TO_SYSTEM)

set(EXTERNALLIB_PREFIX ODElib)
externalproject_add(ODE
    GIT_REPOSITORY      ${ODE_URL}
    GIT_TAG             "master"
    PREFIX              ${EXTERNALLIB_PREFIX}
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND
    cd <SOURCE_DIR> && ./autogen.sh && ./configure --prefix=<INSTALL_DIR>  --enable-shared --disable-demos --enable-double-precision --disable-asserts --enable-malloc && make install -j4
    # CMAKE_ARGS
    #     "-DBUILD_SHARED_LIBS=ON"
    #     "-DODE_DOUBLE_PRECISION=ON"
    #     "-DODE_WITH_DEMOS=OFF"
    #     "-DODE_WITH_TESTS=OFF"
    #     "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>"
    # DEPENDS pre_install
)

externalproject_get_property(ODE INSTALL_DIR)
set(ODE_DIR ${INSTALL_DIR})

set(EXTERNALLIB_PREFIX SimSparkLib)
externalproject_add(SimSpark
    GIT_REPOSITORY      ${SIMSPARK_URL}
    GIT_TAG             "master"
    PREFIX              ${EXTERNALLIB_PREFIX}
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ""
    INSTALL_COMMAND     cd <SOURCE_DIR> && bash build.sh
    CMAKE_ARGS
    # "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>"
    # DEPENDS ODE
)
endif(INSTALL_TO_SYSTEM)

if(WITH_ROBOVIZ)
set(ADir "$bindir/rcssmonitor3d")
set(BDir "${RoboViz_SOURCE_DIR}/bin/linux-amd64/roboviz.sh")
set(Cstr "s#${ADir}#${BDir}#")

add_custom_target(rcsoccersim3d
    COMMAND sudo sed -i "s#${ADir}#${BDir}#" /usr/local/bin/rcsoccersim3d
    WORKING_DIRECTORY ${RoboViz_SOURCE_DIR}
    DEPENDS RoboViz
)
endif(WITH_ROBOVIZ)

# add_custom_target(clean_all
#     COMMAND sudo rm -rf CMakeFiles 
#     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
# )

add_custom_target(uninstall_ode
    COMMAND sudo make uninstall && make clean 
    WORKING_DIRECTORY ${ODE_SOURCE_DIR}
)

add_custom_target(uninstall_simspark
    COMMAND sudo make uninstall
    WORKING_DIRECTORY ${SimSpark_SOURCE_DIR}/spark/build
    COMMAND sudo make uninstall
    WORKING_DIRECTORY ${SimSpark_SOURCE_DIR}/rcssserver3d/build
)

add_custom_target(uninstall_all
    DEPENDS uninstall_simspark uninstall_ode
)