CURDIR=`pwd`

rm -Rf $CBTEMP
mkdir $CBTEMP
mkdir $PHASE1DIR
echo `date`
echo "starting generation of convtab..."
echo "starting generation of convtab..." >> $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt
python $BINDIR/x2r-xml.py

echo "starting conversion..." > $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt
cd $DATADIR
for dir in $SEL
	do
	mkdir $PHASE1DIR/$dir
	cd $dir
	for file in *.xml
		do
		echo $file
#		perl $BINDIR/fix-cb-encoding.pl $file > tmp.xml
		java -Xms64000k -Xmx512000k -jar $SAXON $file $BINDIR/cbetap4top5.xsl current_date=`date "+%Y-%m-%d"` docfile=$file convtabdir=$CONVTABDIR > $PHASE1DIR/$dir/$file
#		rm tmp.xml
	done
	cd ..
done
echo "starting gen-map..."
echo "starting gen-map..." >> $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt

sh $BINDIR/gen-map.sh
echo "starting generation of gaijixml..."
echo "starting generation of gaijixml..." >> $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt
sh $BINDIR/gen-gaijixml.sh

echo "starting phase2..."
echo "starting phase2..." >> $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt
sh $BINDIR/p5-pp.sh
echo "starting validation..."
echo "starting validation..." >> $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt
sh $BINDIR/cb-val.sh
cd $CURDIR
echo "done!"
echo "done!" >> $CBTEMP/log.txt
echo `date` >> $CBTEMP/log.txt
