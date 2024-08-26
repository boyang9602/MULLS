ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

ENV TZ=America/New_York

RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install \
    gcc g++ python3-pip build-essential git wget libgl1-mesa-glx xvfb \
    protobuf-compiler libprotobuf-dev libgoogle-glog-dev libgflags-dev libboost-thread-dev \
    libsuitesparse-dev libpcl-dev libproj-dev libopencv-dev libhdf5-serial-dev libopenmpi-dev \
    openmpi-bin libhdf5-openmpi-dev

RUN python3 -m pip install --upgrade pip

RUN wget 'http://de.archive.ubuntu.com/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.4.0-4_all.deb' && \
    dpkg -i libeigen3-dev_3.4.0-4_all.deb

RUN wget https://cmake.org/files/v3.24/cmake-3.24.4-linux-x86_64.tar.gz \
    && tar -xf cmake-3.24.4-linux-x86_64.tar.gz && rm cmake-3.24.4-linux-x86_64.tar.gz \
    && cd cmake-3.24.4-linux-x86_64/ && mv man share/ \
    && cp -r * /usr/local/

RUN wget http://ceres-solver.org/ceres-solver-2.1.0.tar.gz \
    && tar -xf ceres-solver-2.1.0.tar.gz \
    && cd ceres-solver-2.1.0 && mkdir build && cd build && cmake ../ && make -j$(nproc) && make install

RUN git clone --depth 1 --branch 1.24.6 https://github.com/strasdat/Sophus.git && \
    cd Sophus && mkdir build && cd build && cmake .. -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF && \
    make -j$(nproc) && make install

RUN git clone --depth 1 https://github.com/libLAS/libLAS.git && \
    cd libLAS && mkdir build && cd build && cmake .. -DWITH_TESTS=OFF && make -j$(nproc) && make install

RUN git clone --depth 1 https://github.com/MIT-SPARK/TEASER-plusplus.git && \
    cd TEASER-plusplus && mkdir build && cd build && cmake .. -DBUILD_TESTS=OFF && make -j$(nproc) && make install

RUN rm -rf *.deb ceres-solver-2.1.0* Sophus libLAS TEASER-plusplus cmake-3.24.4-linux-x86_64

RUN ldconfig

WORKDIR /MULLS
COPY . .

RUN rm -rf build log bin demo_data

RUN mkdir build && cd build && \
    cmake .. -DBUILD_WITH_SOPHUS=ON -DBUILD_WITH_PROJ4=ON -DBUILD_WITH_LIBLAS=ON && \
    make -j$(nproc)

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
