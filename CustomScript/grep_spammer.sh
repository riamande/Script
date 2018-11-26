tglstart=1419872400
tglend=1420477199

echo \"userid\",\"joindate\",\"threadid\",\"thread title\",\"thread content\",\"thread visibility\" > data_spam.csv
for i in `mysql -upercona -pkaskus2014 -h 172.20.0.73 user -r -s -N -e "select userid,joindate from userinfo where joindate>=$tglstart and joindate<=$tglend;"`
do
uid=`echo $i |sed -e 's$\t$ $g' |cut -d ' ' -f1`
tgljoin=`echo $i |sed -e 's$\t$ $g' |cut -d ' ' -f2`
tgljoin_date=`date -d @$tgljoin`
partisi=`expr $uid % 500`
countthread=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.count({thread_userid:\"$uid\"})" |sed -n 3p`

if [ $countthread -gt 0 ]
then
#thread1=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:1}).sort({dateline:1}).forEach(printjson)" |sed -n 4p |cut -d '"' -f4`
thread1=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:1}).sort({dateline:1}).forEach(printjson)" |grep -v "MongoDB shell version" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed -n 1p |cut -d '"' -f4`
thread_starter1=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:0,thread_starter:1}).sort({dateline:1}).forEach(printjson)" |grep -v "MongoDB shell version" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed -n 1p |cut -d ':' -f2 |sed -e 's/}$//g'`
title1=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:0,thread_title:1}).sort({dateline:1}).forEach(printjson)" |sed -e 's/^{//g' |sed -e 's/}$//g' |sed -e 's$"thread_title" : $$g' |grep -v "MongoDB shell version: 2.4.9" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed '/^$/d' |sed -n 1p`
content1=`mongo kaskus_forum1 --eval "db.post.find({_id:ObjectId($thread_starter1)},{pagetext:1,_id:0}).forEach(printjson)" |sed -e 's/^{//g' |sed -e 's/}$//g' |sed -e 's$"pagetext" : $$g' |grep -v "MongoDB shell version: 2.4.9" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed '/^$/d'`
visible1=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:0,visible:1}).sort({dateline:1}).forEach(printjson)" |grep -v "MongoDB shell version" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed -n 1p |sed -e 's/^{//g' |sed -e 's/}$//g' |sed -e 's$"visible" : $$g' |sed -e 's/ NumberLong(//g' |sed -e 's/)//g'`
echo \"$uid\",\"$tgljoin_date\",\"$thread1\",$title1,$content1,\"$visible1\" >> data_spam.csv
fi
if [ $countthread -gt 1 ]
then
thread2=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:1}).sort({dateline:1}).forEach(printjson)" |grep -v "MongoDB shell version" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed -n 2p |cut -d '"' -f4`
thread_starter2=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:0,thread_starter:1}).sort({dateline:1}).forEach(printjson)" |grep -v "MongoDB shell version" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed -n 2p |cut -d ':' -f2 |sed -e 's/}$//g'`
title2=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:0,thread_title:1}).sort({dateline:1}).forEach(printjson)" |sed -e 's/^{//g' |sed -e 's/}$//g' |sed -e 's$"thread_title" : $$g' |grep -v "MongoDB shell version: 2.4.9" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed '/^$/d' |sed -n 2p`
content2=`mongo kaskus_forum1 --eval "db.post.find({_id:ObjectId($thread_starter2)},{pagetext:1,_id:0}).forEach(printjson)" |sed -e 's/^{//g' |sed -e 's/}$//g' |sed -e 's$"pagetext" : $$g' |grep -v "MongoDB shell version: 2.4.9" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed '/^$/d'`
visible2=`mongo 172.20.0.242/kaskus_forum1 --eval "db.mythread_$partisi.find({thread_userid:\"$uid\"},{_id:0,visible:1}).sort({dateline:1}).forEach(printjson)" |grep -v "MongoDB shell version" |grep -v "connecting to: 172.20.0.242/kaskus_forum1" |sed -n 2p |sed -e 's/^{//g' |sed -e 's/}$//g' |sed -e 's$"visible" : $$g' |sed -e 's/ NumberLong(//g' |sed -e 's/)//g'`
echo \"$uid\",\"$tgljoin_date\",\"$thread2\",$title2,$content2,\"$visible2\" >> data_spam.csv
fi


done
