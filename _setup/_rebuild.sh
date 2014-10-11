#! /bin/bash

echo Rebuilding from branch "$1"

RUN_SERVER=true
RUN_JEKYLL=true
BANCH=master

while [[ $# > 1 ]]
do
  case "$1" in
    --no-jekyll)
      RUN_JEKYLL = false
      ;;

    --no-server)
      RUN_SERVER = false
      ;;

    *)
      BRANCH=$1
      ;;

  esac

shift
done

# Update all clones, checkout branch
cd $WRKDIR
cd core && git checkout $BRANCH.x && git pull && make && cd ..
cd masterfiles && git checkout $BRANCH.x && git pull && cd ..
cd design-center && git checkout $BRANCH.x git pull && cd ..
cd documentation && git checkout $BRANCH git pull && cd ..
cd documentation-generator && git checkout $BRANCH && git pull

# Adjust jekyll config for docker file system layout
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
  jekyll
else
  echo "Run jekyll [--server 8080] to build [and serve] the HTML files"
  bash
fi
