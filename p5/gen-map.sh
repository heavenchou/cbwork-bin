
rm -Rf $MAPDIR
mkdir $MAPDIR
rm -Rf $COLLDIR
mkdir $COLLDIR

cd $PHASE1DIR
 for dir in $SEL
 	do
 	echo $dir
 	cd $dir
 	python $BINDIR/gen-coll.py $PHASE1DIR/$dir > $COLLDIR/$dir.xml
   cd ..
 done


cd $MAPDIR

for file in $COLLDIR/*\.xml
 	do
 	echo $file
 	java -Xms64000k -Xmx512000k -cp $SAXON net.sf.saxon.Query  $BINDIR/gen-charmap$SOLR.xq coll=$file > `basename $file`
 done

cd $MAPDIR
python $BINDIR/gen-coll.py $MAPDIR > $COLLDIR/map-coll.xml
java -Xms64000k -Xmx512000k -cp $SAXON net.sf.saxon.Query  $BINDIR/gen-charmap${SOLR}2.xq coll=$COLLDIR/map-coll.xml > $BINDIR/cbeta-map$SOLR.xsl
cd $CURDIR

