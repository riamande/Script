#daily creator
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
datadir="/home/rully/data_thread_share/daily"

echo '"periode","total_thread","total_users","total_thread_approved","total_user_approved","total_creator"' > $datadir/daily_creator_20170814-20171112.csv

loop_end=20170815
while [ $loop_end -lt 20171114 ]
do
date_end=$loop_end
end_date=`date -d "$date_end" +%s`
start_date=`date -d "$date_end - 1 day" +%s`
OID_START=`mongo --eval "Math.floor($start_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
date_naming=`date -d@$start_date +%Y%m%d`
mongo 172.20.0.91/kaskus_user_log --eval "rs.slaveOk();db.user_account_activity_log.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},processname:'accept_vtm_request'},{user_id:1,_id:0}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' >> $datadir/creator.temp
> $datadir/thread_all.temp
> $datadir/thread_approved.temp
for i in `cat $datadir/creator.temp`
do
mod_user=`expr $i % 500`
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.mythread_$mod_user.find({thread_userid:'$i',dateline:{\$gte:$start_date,\$lt:$end_date}},{_id:0,thread_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $datadir/thread_all.temp
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.mythread_$mod_user.find({thread_userid:'$i',dateline:{\$gte:$start_date,\$lt:$end_date},visible:1},{_id:0,thread_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $datadir/thread_approved.temp
done

date_name=`date -d@$start_date +%m/%d/%Y`
total1=`cat $datadir/thread_all.temp |wc -l`
total2=`cat $datadir/thread_all.temp |sort |uniq |wc -l`
total3=`cat $datadir/thread_approved.temp |wc -l`
total4=`cat $datadir/thread_approved.temp |sort |uniq |wc -l`
total5=`cat $datadir/creator.temp |sort |uniq |wc -l`
echo '"'$date_name'","'$total1'","'$total2'","'$total3'","'$total4'","'$total5'"' >> $datadir/daily_creator_20170814-20171112.csv
loop_end=`date -d "$date_end + 1 day" +%Y%m%d`
done

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "DAILY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER 20170814 \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/daily_creator_20170814-20171112.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

