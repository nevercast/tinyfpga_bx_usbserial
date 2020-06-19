FROM ubuntu:latest
LABEL maintainer="Josh Lloyd <j.nevercast@gmail.com>"
# Docker ENV
ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

# Prerequisites
RUN apt-get update -y && \
    apt-get install -y build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz xdot  \
                     pkg-config python python3 python3-venv python3-pip libftdi-dev \
                     qt5-default python3-dev libboost-all-dev cmake libeigen3-dev

# IceStorm Tools
RUN git clone https://github.com/cliffordwolf/icestorm.git icestorm &&  \
    cd icestorm &&  \
    make -j$(nproc) &&  \
    make install

# NextPNR
RUN git clone https://github.com/YosysHQ/nextpnr nextpnr && \
    cd nextpnr &&  \
    cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . &&  \
    make -j$(nproc) &&  \
    make install

# Yosys
RUN git clone https://github.com/cliffordwolf/yosys.git yosys && \
    cd yosys && \
    make -j$(nproc) && \
    make install

# Arachne-PNR (predecessor to NextPNR)
RUN git clone https://github.com/cseed/arachne-pnr.git arachne-pnr && \
    cd arachne-pnr && \
    make -j$(nproc) && \
    make install

RUN python3 -m pip install wheel && \
    python3 -m pip install apio tinyprog fusesoc && \
    fusesoc init -y

# Working directory
RUN mkdir "/workspace"
VOLUME ["/workspace"]
WORKDIR "/workspace"

# Default interpreter
CMD ["/bin/bash"]
