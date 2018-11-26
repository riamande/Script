#daily/monthly creator
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
datadir="/home/rully/data_thread_share/daily"
datadir_month="/home/rully/data_thread_share/monthly"
date_end=`date +%Y%m%d`
#date_end="$1"
cur_day=`date -d "$date_end" +%d`
end_date=`date -d "$date_end" +%s`
start_date=`date -d "$date_end - 1 day" +%s`
date_naming=`date -d@$start_date +%Y%m%d`
date_naming_month=`date -d@$start_date +%Y%m`
OID_START=`/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "Math.floor($start_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`

echo '"periode","total_thread","total_users","total_thread_approved","total_user_approved","total_creator"' > $datadir/daily_creator_$date_naming".csv"

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select user_id from forum_user_setting where vtm_status=1;" > $datadir/creator.temp

/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.thread_warehouse.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{userid:1, _id:0,plagiarism_status:1,thread_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/warehouse.temp

cat $datadir/warehouse.temp |sed ':a;N;$!ba;s/{\n\t/{ /g;s@\n}@ }@g;s@,\n\t@, @g' |sed 's@{ "thread_id" : "@@g;s@", "userid" : NumberLong(@,@g;s@), @, @g' > $datadir/thread_warehouse.temp

date_name=`date -d@$start_date +%m/%d/%Y`
total1=`cat $datadir/thread_warehouse.temp |wc -l`
total2=`cat $datadir/thread_warehouse.temp |cut -d ',' -f2 |sort |uniq |wc -l`
total3=`cat $datadir/thread_warehouse.temp |grep '"plagiarism_status" : NumberLong(1)' |wc -l`
total4=`cat $datadir/thread_warehouse.temp |grep '"plagiarism_status" : NumberLong(1)' |cut -d ',' -f2 |sort |uniq |wc -l`
total5=`cat $datadir/creator.temp |sort |uniq |wc -l`
echo '"'$date_name'","'$total1'","'$total2'","'$total3'","'$total4'","'$total5'"' >> $datadir/daily_creator_$date_naming".csv"

> $datadir/thread_apprv.temp
> $datadir/thread_reject.temp
for i in `cat $datadir/thread_warehouse.temp |cut -d ',' -f1`
do
userid_warehouse=`cat $datadir/thread_warehouse.temp |grep "$i" |cut -d ',' -f2 |sort |uniq`
status_warehouse=`cat $datadir/thread_warehouse.temp |grep "$i" |grep '"plagiarism_status" : NumberLong(1)' |wc -l`
mod_user=`expr $userid_warehouse % 500`
if [ $status_warehouse -gt 0 ]
then
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.mythread_$mod_user.find({thread_userid:'$userid_warehouse',_id:ObjectId('$i')},{_id:0,thread_userid:1,forum_title:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $datadir/thread_apprv.temp
else
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.mythread_$mod_user.find({thread_userid:'$userid_warehouse',_id:ObjectId('$i')},{_id:0,thread_userid:1,forum_title:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $datadir/thread_reject.temp
fi
done

cat $datadir/thread_apprv.temp >> $datadir_month/thread_all_month.temp
cat $datadir/thread_reject.temp >> $datadir_month/thread_all_month.temp
cat $datadir/thread_apprv.temp >> $datadir_month/thread_approved_month.temp


if [ $cur_day = '01' ]
then
date_name=`date -d@$start_date +%m/%Y`
start_date_month=`date -d "$date_end - 1 month" +%s`
OID_START_MONTH=`/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "Math.floor($start_date_month).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END_MONTH=`/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`

echo '"periode","total_thread","total_users","total_thread_approved","total_user_approved","total_creator"' > $datadir_month/monthly_creator_$date_naming_month".csv"

/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.thread_warehouse.find({_id:{\$gte:ObjectId('$OID_START_MONTH'),\$lt:ObjectId('$OID_END_MONTH')}},{userid:1, _id:0,plagiarism_status:1,thread_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir_month/warehouse.temp
cat $datadir_month/warehouse.temp |sed ':a;N;$!ba;s/{\n\t/{ /g;s@\n}@ }@g;s@,\n\t@, @g' |sed 's@{ "thread_id" : "@@g;s@", "userid" : NumberLong(@,@g;s@), @, @g' > $datadir_month/thread_warehouse.temp

total_month1=`cat $datadir_month/thread_warehouse.temp |wc -l`
total_month2=`cat $datadir_month/thread_warehouse.temp |cut -d ',' -f2 |sort |uniq |wc -l`
total_month3=`cat $datadir_month/thread_warehouse.temp |grep '"plagiarism_status" : NumberLong(1)' |wc -l`
total_month4=`cat $datadir_month/thread_warehouse.temp |grep '"plagiarism_status" : NumberLong(1)' |cut -d ',' -f2 |sort |uniq |wc -l`
total_month5=`cat $datadir_month/creator.temp |sort |uniq |wc -l`
echo '"'$date_name'","'$total_month1'","'$total_month2'","'$total_month3'","'$total_month4'","'$total_month5'"' >> $datadir_month/monthly_creator_$date_naming_month".csv"

echo '"periode","forum_name","total_thread_all"' > $datadir_month/monthly_creator_threadall_$date_naming_month".csv"
cat $datadir_month/thread_all_month.temp |grep '"forum_title" :' |awk -F '"forum_title" :' '{print $2}' |sed 's@^ @@g;s@ }$@@g;s@ @|@g' |sort |uniq -c |sed 's@^  *@@g' |awk '{print $2,$1;}' |sed 's@ @,"@g;s@$@"@g;s@|@ @g' |sed "s@^@\"$date_name\",@g" >> $datadir_month/monthly_creator_threadall_$date_naming_month".csv"
mv $datadir_month/thread_all_month.temp $datadir_month/thread_all_month$date_naming_month".temp"

echo '"periode","forum_name","total_thread_approved"' > $datadir_month/monthly_creator_threadapprove_$date_naming_month".csv"
cat $datadir_month/thread_approved_month.temp |grep '"forum_title" :' |awk -F '"forum_title" :' '{print $2}' |sed 's@^ @@g;s@ }$@@g;s@ @|@g' |sort |uniq -c |sed 's@^  *@@g' |awk '{print $2,$1;}' |sed 's@ @,"@g;s@$@"@g;s@|@ @g' |sed "s@^@\"$date_name\",@g" >> $datadir_month/monthly_creator_threadapprove_$date_naming_month".csv"
mv $datadir_month/thread_approved_month.temp $datadir_month/thread_approved_month$date_naming_month".temp"

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,seno@kaskusnetworks.com -u "MONTHLY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir_month/monthly_creator_$date_naming_month".csv" $datadir_month/monthly_creator_threadall_$date_naming_month".csv" $datadir_month/monthly_creator_threadapprove_$date_naming_month".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "DAILY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/daily_creator_$date_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,seno@kaskusnetworks.com -u "DAILY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/daily_creator_$date_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
