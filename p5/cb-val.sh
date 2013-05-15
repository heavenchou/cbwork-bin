rm -Rf $VALRESDIR
mkdir $VALRESDIR

# cd $PHASE1DIR
# for dir in $SEL
# 	do
# 	cd $dir
# 	for file in *.xml
# 		do
# 		echo $file
# 		echo $file >> $VALRESDIR/results-phase1.txt
# 		java -Xms64000k -Xmx512000k -jar $JING -c  $BINDIR/cbeta-p5.rnc $file 2>&1 >> $VALRESDIR/results-phase1.txt
# 	done
# 	cd ..
# done

cd $PHASE2DIR
for dir in $SEL
	do
	cd $dir
	for file in *.xml
		do
		echo $file
		echo $file >> $VALRESDIR/results-phase2.txt
		java -Xms64000k -Xmx512000k -jar $JING -c  $BINDIR/cbeta-p5.rnc $file 2>&1 >> $VALRESDIR/results-phase2.txt
	done
	cd ..
done
