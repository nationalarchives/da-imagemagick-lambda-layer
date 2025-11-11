FROM public.ecr.aws/lambda/nodejs:latest

RUN dnf install -y make gcc tar xz gcc-c++ cmake autoconf automake zlib-devel libtool bzip2-devel
ENV LIBPNG_VERSION=1.6.50 \
    LIBJPG_VERSION=9c \
    OPENJP2_VERSION=2.3.1 \
    LIBTIFF_VERSION=4.0.9 \
    BZIP2_VERSION=1.0.6 \
    LIBWEBP_VERSION=0.6.1 \
    IMAGEMAGICK_VERSION=7.0.8-45 \
    TARGET_DIR=/opt \
    CACHE_DIR=/tmp/build/cache

RUN mkdir -p ${CACHE_DIR} ${CACHE_DIR}/lib/pkgconfig

WORKDIR /tmp/build

#################
# Build libjpeg
#################

RUN curl -LO http://ijg.org/files/jpegsrc.v${LIBJPG_VERSION}.tar.gz  \
 && tar xf jpegsrc.v${LIBJPG_VERSION}.tar.gz \
 && cd $(find . -type d -name "jpeg*" -print -quit) \
 && PKG_CONFIG_PATH=${CACHE_DIR}/lib/pkgconfig ./configure \
        CPPFLAGS="-I${CACHE_DIR}/include" \
        LDFLAGS="-L${CACHE_DIR}/lib" \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --prefix=${CACHE_DIR} \
        --build=x86_64-unknown-linux-gnu \
 && make \
 && make install

#################
# Build libpng
#################
RUN curl -LO "https://deac-ams.dl.sourceforge.net/project/libpng/libpng16/1.6.50/libpng-${LIBPNG_VERSION}.tar.xz" \
 && echo libpng-${LIBPNG_VERSION}.tar.xz \
 && ls -la \
 && tar -xf libpng-${LIBPNG_VERSION}.tar.xz \
 && cd $(find . -type d -name "libpng*" -print -quit) \
 && PKG_CONFIG_PATH=${CACHE_DIR}/lib/pkgconfig ./configure \
        CPPFLAGS="-I${CACHE_DIR}/include" \
        LDFLAGS="-L${CACHE_DIR}/lib" \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --prefix=${CACHE_DIR} \
        --build=x86_64-unknown-linux-gnu \
 && make \
 && make install


#################
# Build libtiff
#################
RUN curl -LO http://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz \
 && tar xf tiff-${LIBTIFF_VERSION}.tar.gz \
 && cd $(find . -type d -name "tiff-*" -print -quit) \
 && PKG_CONFIG_PATH=${CACHE_DIR}/lib/pkgconfig ./configure \
        CPPFLAGS="-I${CACHE_DIR}/include" \
        LDFLAGS="-L${CACHE_DIR}/lib" \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --prefix=${CACHE_DIR} \
        --build=x86_64-unknown-linux-gnu \
 && make \
 && make install

#################
# Build libwebp
#################
RUN curl -L https://github.com/webmproject/libwebp/archive/v${LIBWEBP_VERSION}.tar.gz -o libwebp-${LIBWEBP_VERSION}.tar.gz \
 && tar xf libwebp-${LIBWEBP_VERSION}.tar.gz \
 && cd $(find . -type d -name "libwebp-*" -print -quit) \
 && sh autogen.sh \
 && PKG_CONFIG_PATH=${CACHE_DIR}/lib/pkgconfig ./configure \
        CPPFLAGS="-I${CACHE_DIR}/include" \
        LDFLAGS="-L${CACHE_DIR}/lib" \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --prefix=${CACHE_DIR} \
        --build=x86_64-unknown-linux-gnu \
 && make \
 && make install

#################
# Build openjpeg
#################
RUN curl -L https://github.com/uclouvain/openjpeg/archive/v${OPENJP2_VERSION}.tar.gz -o openjp2-${OPENJP2_VERSION}.tar.gz \
 && tar xf openjp2-${OPENJP2_VERSION}.tar.gz \
 && cd $(find . -maxdepth 1 -type d -name "openjpeg-*" -print -quit) \
 && mkdir -p build \
 && cd build \
 && PKG_CONFIG_PATH=${CACHE_DIR}/lib/pkgconfig cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${CACHE_DIR} \
        -DBUILD_SHARED_LIBS:bool=off \
        -DBUILD_CODEC:bool=off \
 && make \
 && make install

######################
# Build ImageMagick
######################
RUN curl -L https://github.com/ImageMagick/ImageMagick/archive/${IMAGEMAGICK_VERSION}.tar.gz -o ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz \
 && tar xf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz \
 && cd $(find . -type d -name "ImageMa*" -print -quit) \
 && PKG_CONFIG_PATH=${CACHE_DIR}/lib/pkgconfig ./configure \
    CPPFLAGS="-I${CACHE_DIR}/include" \
    LDFLAGS="-L${CACHE_DIR}/lib" \
    --disable-dependency-tracking \
    --disable-shared \
    --enable-static \
    --prefix=${TARGET_DIR} \
    --enable-delegate-build \
    --without-modules \
    --disable-docs \
    --without-magick-plus-plus \
    --without-perl \
    --without-x \
    --disable-openmp \
 && make clean \
 && make all \
 && make install

WORKDIR /opt
RUN zip -ry ../package.zip *

