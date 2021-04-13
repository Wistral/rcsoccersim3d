from ubuntu:18.04-cn

ARG DEPS="cmake build-essential make autogen automake libtool git sudo"
RUN apt update && apt install -y ${DEPS}

ADD . /rcss3d
WORKDIR /rcss3d

RUN mkdir rcsoccersim3d-release && cp rcss3dinit.sh rcsoccersim3d-release \
    && cmake . -DINST2SYS=OFF -DDOMESTIC=ON -DWITH_ROBOVIZ=OFF \
    && make && bash clean.sh 

SHELL ["/bin/bash", "-c"]
# RUN apt autoremove -y ${DEPS} && apt clean

CMD ["rcssserver3d"]

