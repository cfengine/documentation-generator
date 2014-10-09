# This provisions a docker image from Ubuntu 12, installs required
# tools, checks out repositories and runs all processes required to
# build the documentation. It then launches a web server that serves
# the documentation.

FROM ubuntu:12.04
MAINTAINER Volker Hilsheimer <volker.hilsheimer@gmail.com>

# 0) set environment variables
# UTF-8 locale for correct decoding of text files in git
# repos
# CORE_BRANCH and DOC_BRANCH can be set via "docker run -env CORE_BRANCH=3.6.x DOC_BRANCH=3.6"
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV WRKDIR /workdir
ENV CORE_BRANCH master
ENV DOC_BRANCH master
ENV GIT_REMOTE cfengine

# 0) All sorts of packages
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    make \
    automake \
    libtool \
    bison \
    flex \
    byacc \
    libpcre3-dev \
    libssl-dev \
    python \
    python-pygments \
    python-software-properties \
    nodejs
RUN apt-get remove -y libruby1.8 ruby1.8 ruby1.8-dev rubygems1.8
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 

# 0.1) Java

RUN add-apt-repository -y ppa:webupd8team/java
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
RUN apt-get update && apt-get install -y oracle-java7-installer

# 1) CFEngine core incl source dependencies

# 1.1) clone and build LMDB
WORKDIR /workdir
RUN git clone git://gitorious.org/mdb/mdb
WORKDIR mdb/libraries/liblmdb
# can't use --branch when cloning, since it's a tag
RUN git checkout LMDB_0.9.9
RUN make && make install

# 1.2) clone and build CFEngine Core
WORKDIR /workdir
RUN git clone -b $CORE_BRANCH http://github.com/$GIT_REMOTE/core
WORKDIR core
RUN ["/bin/bash", "-c", "./autogen.sh --without-pam --with-lmdb=/usr/local"]
RUN make
RUN cf-key/cf-key

# 1) Install Jekyll gems
RUN gem install jekyll -v 0.12.1
RUN gem install yui-compressor -v 0.12.0
RUN gem install \
    jekyll-asset-pipeline \
    closure-compiler \
    redcarpet \
    albino \
    uglifier \
    execjs \
    sanitize

# 3) Clone documentation content
WORKDIR /workdir
RUN git clone -b $DOC_BRANCH http://github.com/$GIT_REMOTE/documentation
RUN git clone -b $DOC_BRANCH http://github.com/$GIT_REMOTE/documentation-generator
RUN git clone -b $CORE_BRANCH http://github.com/$GIT_REMOTE/masterfiles
RUN git clone -b $CORE_BRANCH http://github.com/$GIT_REMOTE/design-center

# patch jekyll to generate flat HTML file structure

RUN patch /var/lib/gems/1.9.1/gems/jekyll-0.12.1/lib/jekyll/page.rb -i /workdir/documentation-generator/_setup/page.rb.patch

#### END of base image ####

# Instruct derived images to process documentation
ONBUILD WORKDIR /workdir
ONBUILD EXPOSE 8080
ONBUILD CMD \
    sh -c 'for i in *; do cd $i; git pull; cd ..; done' && \
    cd documentation-generator && \
    sed -e "s/  display_path/# display_path/" -i _config.yml && \
    _scripts/cfdoc_bootstrap.py && \
    ./_regenerate_json.sh && \
    _scripts/cfdoc_preprocess.py && \
    sh -c 'mkdir pages && cp -r $WRKDIR/documentation/* $WRKDIR/documentation-generator/pages' && \
    jekyll --server 8080
