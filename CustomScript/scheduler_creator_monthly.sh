#montly creator
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
datadir="/home/rully/data_thread_share/monthly"
date_end=`date +%Y%m%d`
end_date=`date -d "$date_end" +%s`
start_date=`date -d "$date_end - 1 month" +%s`
date_naming=`date -d@$start_date +%Y%m`
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select user_id from forum_user_setting where vtm_status=1;" > $datadir/creator.temp

echo '"periode","total_thread","total_users","total_thread_approved","total_user_approved","total_creator"' > $datadir/monthly_creator_$date_naming".csv"
> $datadir/thread_all.temp
> $datadir/thread_approved.temp
for i in `cat $datadir/creator.temp`
do
mod_user=`expr $i % 500`
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.mythread_$mod_user.find({thread_userid:'$i',dateline:{\$gte:$start_date,\$lt:$end_date}},{_id:0,thread_userid:1,forum_title:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $datadir/thread_all.temp
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.mythread_$mod_user.find({thread_userid:'$i',dateline:{\$gte:$start_date,\$lt:$end_date},visible:1},{_id:0,thread_userid:1,forum_title:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $datadir/thread_approved.temp
done

date_name=`date -d@$start_date +%m/%Y`
total1=`cat $datadir/thread_all.temp |grep thread_userid |cut -d '"' -f4 |wc -l`
total2=`cat $datadir/thread_all.temp |grep thread_userid |cut -d '"' -f4 |sort |uniq |wc -l`
total3=`cat $datadir/thread_approved.temp |grep thread_userid |cut -d '"' -f4 |wc -l`
total4=`cat $datadir/thread_approved.temp |grep thread_userid |cut -d '"' -f4 |sort |uniq |wc -l`
total5=`cat $datadir/creator.temp |sort |uniq |wc -l`

echo '"periode","forum_name","total_thread_all"' > $datadir/monthly_creator_threadall_$date_naming".csv"
cat $datadir/thread_all.temp |grep '"forum_title" :' |awk -F '"forum_title" :' '{print $2}' |sed 's@^ @@g;s@ }$@@g;s@ @|@g' |sort |uniq -c |sed 's@^  *@@g' |awk '{print $2,$1;}' |sed 's@ @,"@g;s@$@"@g;s@|@ @g' |sed "s@^@\"$date_name\",@g" >> $datadir/monthly_creator_threadall_$date_naming".csv"

echo '"periode","forum_name","total_thread_approved"' > $datadir/monthly_creator_threadapprove_$date_naming".csv"
cat $datadir/thread_approved.temp |grep '"forum_title" :' |awk -F '"forum_title" :' '{print $2}' |sed 's@^ @@g;s@ }$@@g;s@ @|@g' |sort |uniq -c |sed 's@^  *@@g' |awk '{print $2,$1;}' |sed 's@ @,"@g;s@$@"@g;s@|@ @g' |sed "s@^@\"$date_name\",@g" >> $datadir/monthly_creator_threadapprove_$date_naming".csv"

echo '"'$date_name'","'$total1'","'$total2'","'$total3'","'$total4'","'$total5'"' >> $datadir/monthly_creator_$date_naming".csv"
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "MONTHLY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/monthly_creator_$date_naming".csv" $datadir/monthly_creator_threadall_$date_naming".csv" $datadir/monthly_creator_threadapprove_$date_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,agnes.revian@kaskusnetworks.com -u "MONTHLY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/monthly_creator_$date_naming".csv" $datadir/monthly_creator_threadall_$date_naming".csv" $datadir/monthly_creator_threadapprove_$date_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
