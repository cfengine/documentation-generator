#! /bin/bash

RUN_SERVER=true
RUN_JEKYLL=true
REMOTE=cfengine
BRANCH=master

while [[ $# > 0 ]]
do
  case "$1" in
    --no-jekyll)
      RUN_JEKYLL=false
      RUN_SERVER=false
      ;;

    --no-server)
      RUN_SERVER=false
      ;;

    --remote|-r)
      shift
      REMOTE=$1
      ;;

    *)
      BRANCH=$1
      ;;

  esac

shift
done

echo Rebuilding from branch $BRANCH on remote $REMOTE...

# Clone from remote, checkout branch
cd $WRKDIR

git clone -b $BRANCH.x http://github.com/$REMOTE/masterfiles
git clone -b $BRANCH.x http://github.com/$REMOTE/design-center
git clone -b $BRANCH http://github.com/$REMOTE/documentation
git clone -b $BRANCH http://github.com/$REMOTE/documentation-generator

# build core - it's already checked out and built by base image
cd core
git checkout $BRANCH.x
git pull
make
cd ..

# Adjust jekyll config for docker file system layout
cd documentation-generator
sed -e "s/  display_path/# display_path/" -i _config.yml

# build documentation
_scripts/cfdoc_bootstrap.py
./_regenerate_json.sh
_scripts/cfdoc_preprocess.py
mkdir pages && cp -r $WRKDIR/documentation/* $WRKDIR/documentation-generator/pages

if $RUN_SERVER
then
  jekyll --server 8080
elif $RUN_JEKYLL
then
  jekyll
else
  echo "Content cloned and pre-processed."
  echo "Run jekyll [--server 8080] to build [and serve] the HTML files"
  bash
fi
