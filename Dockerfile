FROM fpco/stack-build:lts-5

MAINTAINER Vikraman <git@vikraman.org>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install llvm-3.6

WORKDIR /root

RUN git clone --quiet --recursive git://git.haskell.org/ghc.git

WORKDIR /root/ghc

ENV SUBMOD_SHA 8c17982648434fae28dedb102ab4624a7323476b

RUN git remote add fork https://github.com/iu-parfunc/ghc.git && \
    git fetch fork && \
    git checkout ${SUBMOD_SHA} && \
    git reset --hard && git clean -dfx && \
    git submodule update --init --recursive

ENV GHC_PREFIX /opt/ghc

RUN mkdir -p ${GHC_PREFIX}

RUN sed -e 's/#BuildFlavour = quick/BuildFlavour = quick/' \
        -e 's/#V=0/V=0/' mk/build.mk.sample > mk/build.mk && \
    ./boot && ./configure --quiet --prefix ${GHC_PREFIX} && \
    make -j2 && make install

ENV PATH ${GHC_PREFIX}/bin:${PATH}
WORKDIR /root
