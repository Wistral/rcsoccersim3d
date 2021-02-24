## rcsoccersim3d

[![build](https://github.com/Wistral/rcsoccersim3d/actions/workflows/build.yml/badge.svg)](https://github.com/Wistral/rcsoccersim3d/actions/workflows/build.yml)

### [中文介绍](README-zh.md)

Install rcsoccersim3d simply

### RUN

basically,
```sh
cmake .
make rcsoccersim3d -j$(nproc)
```

For China domestic user, add `-DDOMESTIC=ON` cmake option, eg.
```sh
cmake . -DDOMESTIC=ON
make rcsoccersim3d -j$(nproc)
```

(NOT RECOMMENDED)With Intel-TBB multithreading support, add `-DWITH_TBB=ON` cmake option

By default, install libs into system path. 

Install libs to local folder(without super user privilege) by add `-DINSTALL_TO_SYSTEM=OFF`

### uninstall
```sh
cmake .
make uninstall_all
```

### use in other project(local install)

eg. [LARG/utaustinvilla3d](https://github.com/LARG/utaustinvilla3d)

```sh

cd rcsoccersim3d  # this repo's dir
...  # compile and local install as above
export SPARK_DIR=`pwd`/SimSpark-prefix # set SPARK_DIR

git clone https://github.com/LARG/utaustinvilla3d --depth=1
mkdir utaustinvilla3d/build -p
cd utaustinvilla3d/build
cmake ..
make
```


