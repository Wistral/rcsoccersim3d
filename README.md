## rcsoccersim3d

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

By default, install libs into system path. (TODO) Install libs to local folder(without super user privilege) by add `-DINSTALL_TO_SYSTEM=OFF`

### uninstall
```sh
cmake .
make uninstall_all
```

