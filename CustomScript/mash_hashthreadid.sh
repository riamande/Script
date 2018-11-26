#! /bin/sh

shard_to_backup=$1
ws_listen=$2
#DATE_START=`date -d "$3" +%s`
#DATE_END=`date -d "$4" +%s`
#OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
#OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
logdir=/home/rully/log

checkfile=`ls $logdir/ |grep 'log_'$shard_to_backup'_primary.log' |wc -l`
if [ $checkfile -gt 0 ]
then
rm $logdir/'log_'$shard_to_backup'_primary.log'
fi

mongo $ws_listen --eval "printjson(sh.status())" |grep '"host"' |cut -d '"' -f8 > $logdir/list_shard_member.log
cat $logdir/list_shard_member.log |grep $shard_to_backup'/' |cut -d '/' -f2 |sed -e 's$,$\n$g' > $logdir/list_shard_to_listen.log

for i in `cat $logdir/list_shard_to_listen.log`
do
mongo $i --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2 >> $logdir/'log_'$shard_to_backup'_primary.log'
done

ipprimary=`cat $logdir/'log_'$shard_to_backup'_primary.log' |sort |uniq -c|sort -r |head -n 1|sed -e 's$      $$g'|cut -d' ' -f2 |cut -d':' -f1`
portprimary=`cat $logdir/'log_'$shard_to_backup'_primary.log' |sort |uniq -c|sort -r |head -n 1|sed -e 's$      $$g'|cut -d' ' -f2 |cut -d':' -f2`

mongo $ipprimary:$portprimary/kaskus_forum1 --eval "db.post.count({_id:{\$lt:ObjectId('50687a900000000000000000')}})"

mongo $ipprimary:$portprimary/kaskus_forum1 --eval "db.post.find({_id:{\$lt:ObjectId('50687a900000000000000000')}}).snapshot().forEach( function (elem) { db.post.update( { _id: elem._id }, { \$set: { hash_thread_id: hex_md5(elem.thread_id) } } ); });"
