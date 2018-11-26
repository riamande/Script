DIR_RM="/home/rully/rmforum0"
for listfile in `ls $DIR_RM`
do
	for ((i=1;i<=1000;i++))
	do
	a=`expr $i \* 100`
	b=`expr $a - 100 + 1`
	sed -n $b,$a'p' $DIR_RM/$listfile > temprm.json
	c=`cat temprm.json |wc -l`
	if [ $c = 0 ]; then break; fi
	mongo kaskus_forum1 temprm.json
	sleep 1
	done
done
