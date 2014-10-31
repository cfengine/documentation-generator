#!/bin/sh
echo "PDF generation started"

#
# This script will generate PDF from html files and write them to the _site/pdf
#
# Require:
# - weasyprint installed (see _setup/start.sh)
# - local Apache2 (or any other http server) with configured virtual host
# - LOCAL_WEBSERVER_URL - url for html files
# - LOCAL_WEBROOT       - path to the local webroot
#

if [ -z "$WRKDIR" ]
then
    echo Environment WRKDIR is not set, setting it to current working directory
    WRKDIR=`pwd`
    export WRKDIR
fi

#html source
DIR=$WRKDIR/documentation-generator/_site

#output pdf folder
DIR2=$WRKDIR/documentation-generator/_site/pdf

#git branch
CUR_BRANCH='3.6'

LOCAL_WEBROOT=/var/www/docs/$CUR_BRANCH

LOCAL_WEBSERVER_URL='http://localhost/docs'

if [ "$LOCAL_WEBROOT" ]; then
 sudo mkdir -p $LOCAL_WEBROOT || true
fi

# copy _site to the local webroot
sudo rm -R $LOCAL_WEBROOT/*
sudo cp -R $DIR/* $LOCAL_WEBROOT/


#get all files and remove / and .html from filename
FILENAME=`find $DIR -type f -name *.html | awk -F $DIR '{print $2}' |  cut -d "/" -f 2 | cut -d . -f 1`

if [ "$DIR2" ]; then
 mkdir -p $DIR2 || true
fi

# do not create PDF for tags or TODO printable-reference
for i in $FILENAME; do
    if [ $i != "tags" ] && [ $i != "printable-reference" ]
    then
        echo '\n' $i '\n'
        weasyprint $LOCAL_WEBSERVER_URL/$CUR_BRANCH/$i.html $DIR2/$i.pdf || true
    fi
done

echo "PDF generation finished"
