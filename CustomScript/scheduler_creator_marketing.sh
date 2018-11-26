periode_run="$1"
datadir="/home/rully/data_thread_share/marketing"
date_end=`date +%Y%m%d`
date_start=`date -d "$date_end - 1 $periode_run" +%Y%m%d`
date_end_ts=`date -d "$date_end" +%s`
date_start_ts=`date -d "$date_start" +%s`
dateonfile=`date -d "$date_end" +"%Y-%m-%d"`
OID_START=`mongo 172.20.0.91/kaskus_forum1 --eval "Math.floor($date_start_ts).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.20.0.91/kaskus_forum1 --eval "Math.floor($date_end_ts).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`

echo '"date","penambahan_creator","total_thread","total_views"' > $datadir/"$periode_run"_creator_statistic_$date_end".csv"

/opt/mongodb_3.0.10/bin/mongo 172.20.0.91/kaskus_user_log -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.user_account_activity_log.find({processname:'accept_vtm_request',_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $datadir/creator_$periode_run".temp"

tot_view=0
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.thread_warehouse.find({time_inserted:{\$gte:$date_start_ts,\$lt:$date_end_ts}},{_id:0,thread_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 > $datadir/tot_thread_$periode_run".temp"

for i in `cat $datadir/tot_thread_$periode_run".temp" |sort |uniq`
do
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({_id:ObjectId('$i')},{_id:0,views:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $datadir/views_$periode_run".temp"
temp_view=`cat $datadir/views_$periode_run".temp"`
total_view=`expr $total_view + $temp_view`
done
total_thread=`cat $datadir/tot_thread_$periode_run".temp" |sort |uniq |wc -l`
total_user=`cat $datadir/creator_$periode_run".temp" |sort |uniq |wc -l`

echo '"'$dateonfile'","'$total_user'","'$total_thread'","'$total_view'"' >> $datadir/"$periode_run"_creator_statistic_$date_end".csv"
sendemail -f statistic@kaskusnetworks.com -t ira.sari@kaskusnetworks.com,atmi.yusron@kaskusnetworks.com,han.mawikere@kaskusnetworks.com,rully@kaskusnetworks.com,db@kaskusnetworks.com -u "[AUTOMATED] CREATOR STATISTIC" -m "STATISTIC CREATOR PER $date_start to $date_end \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/"$periode_run"_creator_statistic_$date_end".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
