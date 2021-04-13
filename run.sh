sudo docker run -it --rm \
    -e LD_LIBRARY_PATH=/rcss3d/rcsoccersim3d-release/lib:/rcss3d/rcsoccersim3d-release/lib/rcssserver3d:/rcss3d/rcsoccersim3d-release/lib/simspark \
    -e PATH=$PATH:/rcss3d/rcsoccersim3d-release/bin \
    rcss3d