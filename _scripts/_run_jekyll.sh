#!/bin/bash
sed '/^\[.*\[.*\].*\]/d' $WRKDIR/documentation-generator/_references.md > $WRKDIR/documentation-generator/new_references.md
mv $WRKDIR/documentation-generator/new_references.md $WRKDIR/documentation-generator/_references.md

mkdir $WRKDIR/documentation-generator/pages
cp -r $WRKDIR/documentation/* $WRKDIR/documentation-generator/pages
cd $WRKDIR/documentation-generator
source /home/vagrant/.rvm/scripts/rvm
echo "Latest jekyll run :$BUILD_ID" > $WRKDIR/output.log
echo "Based on latest git commit :$GIT_COMMIT" >> $WRKDIR/output.log
echo "*********************************************************" >> $WRKDIR/output.log
echo "*                  CONSOLE OUTPUT                       *" >> $WRKDIR/output.log
echo "*********************************************************" >> $WRKDIR/output.log
jekyll
$WRKDIR/documentation-generator/_scripts/cfdoc_postprocess.py
