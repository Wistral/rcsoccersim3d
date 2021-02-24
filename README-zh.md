## rcsoccersim3d

[![build](https://github.com/Wistral/rcsoccersim3d/actions/workflows/build.yml/badge.svg)](https://github.com/Wistral/rcsoccersim3d/actions/workflows/build.yml)

cmake安装rcsoccersim3d，支持本地目录（非系统目录）安装

### RUN

国内用户运行需要添加`-DDOMESTIC=ON`选项以启用gitee加速

```sh
cmake . -DDOMESTIC=ON
make rcsoccersim3d -j$(nproc)
```

添加`-DWITH_TBB=ON`启用Intel-TBB多线程加速，疑似存在bug，不推荐使用

默认安装到系统路径，需要sudo权限

添加`-DINSTALL_TO_SYSTEM=OFF`选项以启用本地目录（非系统目录）安装

#### 推荐命令
```sh
cmake . -DDOMESTIC=ON -DINSTALL_TO_SYSTEM=OFF
make rcsoccersim3d -j$(nproc)
```

### 卸载
```sh
cmake .
make uninstall_all          # 本地安装
sudo make uninstall_all     # 系统路径安装
```

### 其他项目中如何使用(本地安装)

对于正常的系统路径安装，一切不变

对于本地安装，需要在运行前设置变量`SPARK_DIR`

以 [LARG/utaustinvilla3d](https://github.com/LARG/utaustinvilla3d) 为例

```sh

cd rcsoccersim3d    # 进入本地仓库文件夹
...                 # 编译安装同上
export SPARK_DIR=`pwd`/SimSpark-prefix # 设置 SPARK_DIR

git clone https://github.com/LARG/utaustinvilla3d --depth=1
mkdir utaustinvilla3d/build -p
cd utaustinvilla3d/build
cmake ..
make
```


