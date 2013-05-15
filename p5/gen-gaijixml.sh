
rm -Rf $GAIJIDIR
mkdir $GAIJIDIR

cd $DATADIR
for dir in $SEL
	do
	echo $dir
	cd $dir
	python $BINDIR/gen-coll.py $DATADIR/$dir > $COLLDIR/$dir.xml
   cd ..
done

cd $GAIJIDIR

for file in $COLLDIR/*\.xml
do
    echo $file
    java -Xms64000k -Xmx1024000k -cp $SAXON net.sf.saxon.Query  $BINDIR/gen-gaijixml.xq coll=$file > `basename $file`
done


