#!/bin/sh
rm -Rf $PHASE2DIR
mkdir $PHASE2DIR
cd $PHASE1DIR
for dir in $SEL
	do
	echo $dir
	mkdir $PHASE2DIR/$dir
	cd $dir
	for file in *.xml
		do
		echo $file
		java -Xms64000k -Xmx512000k -jar $SAXON $file $BINDIR/p5-pp.xsl current_date=`date "+%Y-%m-%d"` docfile=$file gpath=$GAIJIDIR > $PHASE2DIR/$dir/$file
		done
  cd ..
done

