# This installs required tools, checks out repositories
# and runs all processes required to build the documentation.

FROM vohi/dev:basic
MAINTAINER Volker Hilsheimer <volker.hilsheimer@gmail.com>

# 0) set environment variables
# CORE_BRANCH and DOC_BRANCH can be set via "docker run -env CORE_BRANCH=3.6.x DOC_BRANCH=3.6"
ENV WRKDIR /workdir
ENV CORE_BRANCH master
ENV DOC_BRANCH master
ENV GIT_REMOTE cfengine

# 1.1) Python and Ruby dependencies
RUN ["/bin/bash", "-c", " \
    apt-get install -y \
        python-pygments \
        python-software-properties \
        nodejs && \
    apt-get remove -y libruby1.8 ruby1.8 ruby1.8-dev rubygems1.8 && \
    apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 \
    "]

# 1.2) Java

RUN ["/bin/bash", "-c", " \
    add-apt-repository -y ppa:webupd8team/java && \
    echo 'debconf shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections && \
    echo 'debconf shared/accepted-oracle-license-v1-1 seen true' | debconf-set-selections && \
    apt-get update && apt-get install -y oracle-java7-installer \
    "]

# 2) Install Jekyll gems
RUN ["/bin/bash", "-c", " \
    gem install jekyll -v 0.12.1 && \
    gem install yui-compressor -v 0.12.0 && \
    gem install \
        jekyll-asset-pipeline \
        closure-compiler \
        redcarpet \
        albino \
        uglifier \
        execjs \
        sanitize \
    "]

# 3) CFEngine core incl source dependencies

# 3.1) clone and build LMDB
WORKDIR /workdir
RUN git clone git://gitorious.org/mdb/mdb
WORKDIR mdb/libraries/liblmdb
# can't use --branch when cloning, since it's a tag
RUN ["/bin/bash", "-c", " \
    git checkout LMDB_0.9.9 && \
    make && make install \
    "]

# 3.2) clone and build CFEngine Core
WORKDIR /workdir
RUN git clone -b $CORE_BRANCH http://github.com/$GIT_REMOTE/core
WORKDIR core
RUN ["/bin/bash", "-c", " \
    ./autogen.sh --without-pam --with-lmdb=/usr/local && \
    make && \
    cf-key/cf-key \
    "]

# 4) Clone documentation content
WORKDIR /workdir
RUN ["/bin/bash", "-c", " \
    git clone -b $DOC_BRANCH http://github.com/$GIT_REMOTE/documentation && \
    git clone -b $DOC_BRANCH http://github.com/$GIT_REMOTE/documentation-generator && \
    git clone -b $CORE_BRANCH http://github.com/$GIT_REMOTE/masterfiles && \
    git clone -b $CORE_BRANCH http://github.com/$GIT_REMOTE/design-center \
    "]

# patch jekyll to generate flat HTML file structure and install CFEngine lexer

RUN ["/bin/bash", "-c", " \
    patch /var/lib/gems/1.9.1/gems/jekyll-0.12.1/lib/jekyll/page.rb -i /workdir/documentation-generator/_setup/page.rb.patch && \
    cp /workdir/documentation-generator/_setup/pygments_cfengine_lexer.py /usr/lib/python2.7/dist-packages/pygments/lexers/cfengine.py && \
    cd /usr/lib/python2.7/dist-packages/pygments/lexers && \
    python _mapping.py \
    "]

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
