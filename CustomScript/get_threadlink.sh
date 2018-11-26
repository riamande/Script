for i in `cat usercewek.txt`
do
partition=`expr $i % 500`
mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partition.find({thread_userid:'$i'},{_id:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting >> thread_cewek.json
var=$((var+1))
echo $var
done

sed -i 's${ "_id" : ObjectId("$http://www.kaskus.co.id/thread/$g' thread_cewek.json
sed -i 's$") }$$g' thread_cewek.json
