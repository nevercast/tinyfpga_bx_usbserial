FROM ubuntu:latest
MAINTAINER Josh Lloyd <j.nevercast@gmail.com>
# Docker ENV
ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Prerequisites
RUN apt-get install -y build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 python3-venv libftdi-dev \
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

# Python VEnvs for different build environments
# https://tinyfpga.com/bx/guide.html
RUN mkdir /pyenv && \
    python3 -m venv /pyenv/tinyfpga-bx-stable && \
    /pyenv/tinyfpga-bx-stable/bin/python3 -m pip install apio==0.4.0b5 tinyprog

RUN python3 -m venv /pyenv/tinyfpga-bx-nextpnr && \
    /pyenv/tinyfpga-bx-nextpnr/bin/python3 -m pip install wheel && \
    /pyenv/tinyfpga-bx-nextpnr/bin/python3 -m pip install apio tinyprog fusesoc && \
    /pyenv/tinyfpga-bx-nextpnr/bin/fusesoc init -y

# Working directory
RUN mkdir "/workspace"
VOLUME ["/workspace"]
WORKDIR "/workspace"

# Default interpreter
CMD ["/bin/bash"]
