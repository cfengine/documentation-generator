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

#git branch always passed as $BRANCH argument

# Note: LOCAL_WEBROOT must NOT end with /
LOCAL_WEBROOT=$WRKDIR/www/docs/$BRANCH

LOCAL_WEBSERVER_URL="http://localhost:8000/docs/$BRANCH"

set -x

# make a website
rm -Rf $LOCAL_WEBROOT
mkdir -p ${LOCAL_WEBROOT%/*}
cp -R $DIR $LOCAL_WEBROOT
( cd $WRKDIR/www && python -m SimpleHTTPServer) &

#get all files and remove / and .html from filename
FILENAME=`find $DIR -type f -name *-printable.html | awk -F $DIR '{print $2}' |  cut -d "/" -f 2 | cut -d . -f 1`

if [ "$DIR2" ]; then
 mkdir -p $DIR2 || true
fi

for i in $FILENAME; do
    echo '\n' $i '\n'
    wkhtmltopdf $LOCAL_WEBSERVER_URL/$i.html $DIR2/$i.pdf || true
done

kill %1

echo "PDF generation finished"
