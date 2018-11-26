MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
periode_report="$1" ### daily/monthly
datadir="/home/rully/data_thread_share/daily"
day_start=`date -d "- 1 $periode_report" +%Y%m%d`
#day_start=20180221
start_date=`date -d "$day_start" +%s`
end_date=`date -d "$day_start + 1 $periode_report" +%s`
if [ $periode_report = "day" ]
then
day_show=`date -d "$day_start" +%Y%m%d`
title_email="DAILY THREAD CREATOR STATISTIC"
elif [ $periode_report = "month" ]
then
day_show=`date -d "$day_start" +%Y%m`
title_email="MONTHLY THREAD CREATOR STATISTIC"
fi
fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`
echo '"periode","total_thread","total_unique_users"' > $datadir/"$periode_report"_threadcreator_"$day_show".csv
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$fjb_id,6,8]},dateline:{\$gte: $start_date,\$lt: $end_date}, visible:1,post_userid:{\$nin:['8296201','9250512','9682662','4203448','8490746','9568276','9344125','9931398']}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_total_creator_$periode_report".txt"
total_thread=`cat $datadir/temp_total_creator_$periode_report".txt" |wc -l`
total_user=`cat $datadir/temp_total_creator_$periode_report".txt" |sort |uniq |wc -l`
echo '"'$day_show'","'$total_thread'","'$total_user'"' >> $datadir/"$periode_report"_threadcreator_"$day_show".csv
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "$title_email" -m "STATISTIC THREAD CREATOR PER $day_show \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/"$periode_report"_threadcreator_"$day_show".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,seno@kaskusnetworks.com -u "$title_email" -m "STATISTIC THREAD CREATOR PER $day_show \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/"$periode_report"_threadcreator_"$day_show".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
