for i in `cat listdb.txt`
do
	mongo $1/$i --eval "db.getCollectionNames().forEach(printjson)" |grep '"' |cut -d'"' -f2 > listtables.txt
	for j in `cat listtables.txt`
	do
	mongo $1/$i --eval "db.$j.find().sort({_id:-1}).limit(1).pretty().forEach(printjson)" |grep -v 'MongoDB shell version: 2.4.9\|connecting to: $1/$i' > result_lastrow/"$i.$j.json"
	done
done
