month_start=`date +%Y%m01`
end_date=`date -d "$month_start" +%s`
start_date1=`date -d "$month_start - 1 month" +%s`
start_date2=`date -d "$month_start - 2 month" +%s`
data_dir="/home/rully/kreator_report/monthly/total"

mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$start_date1,\$lt:$end_date}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/Warehouse_month.temp
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$start_date1,\$lt:$end_date},current_status:2},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/approve_month.temp
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$start_date1,\$lt:$end_date},current_status:1},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/pending_month.temp

mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$start_date2,\$lt:$start_date1}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/Warehouse_month2.temp
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$start_date2,\$lt:$start_date1},current_status:2},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/approve_month2.temp
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$start_date2,\$lt:$start_date1},current_status:1},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/pending_month2.temp

cat $data_dir/Warehouse_month.temp |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=','  > $data_dir/allthread_month1
cat $data_dir/approve_month.temp    |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=',' > $data_dir/thread_approv_month1
cat $data_dir/pending_month.temp    |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=',' > $data_dir/thread_pending_month1

cat $data_dir/Warehouse_month2.temp  |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=','  > $data_dir/allthread_month2
cat $data_dir/approve_month2.temp    |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=',' > $data_dir/thread_approv_month2
cat $data_dir/pending_month2.temp    |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=',' > $data_dir/thread_pending_month2

date_name=`date -d@$start_date2 +%Y%m`
join -11 -a1 $data_dir/allthread_month2 $data_dir/thread_approv_month2 -o1.1,1.2,2.2 -e0 -t ',' > $data_dir/all_and_approve_month2
join -11 -a1 $data_dir/all_and_approve_month2 $data_dir/thread_pending_month2 -o1.1,1.2,1.3,2.2 -e0 -t ',' |sed "s@^@\"$date_name\",@g" > $data_dir/kreator-author-monthly2.csv

date_name=`date -d@$start_date1 +%Y%m`
join -11 -a1 $data_dir/allthread_month1 $data_dir/thread_approv_month1 -o1.1,1.2,2.2 -e0 -t ',' > $data_dir/all_and_approve_month1
join -11 -a1 $data_dir/all_and_approve_month1 $data_dir/thread_pending_month1 -o1.1,1.2,1.3,2.2 -e0 -t ',' |sed "s@^@\"$date_name\",@g"  > $data_dir/kreator-author-monthly1.csv

date_naming=`date -d@$start_date1 +%Y%m`
#echo '"Date","userid","Jumlah Thread Created","Jumlah thread approved","Jumlah Thread pending"' > $data_dir/user_kreator_author_monthly.csv
cat $data_dir/kreator-author-monthly2.csv >> $data_dir/user_kreator_author_monthly.csv
cat $data_dir/kreator-author-monthly1.csv >> $data_dir/user_kreator_author_monthly.csv

#create table user_kreator_author_monthly (date_created Date, userid int(11), total_thread int(11), total_thread_approv int(11), total_thread_pending int(11));
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/user_kreator_author_monthly.csv;

mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select user_kreator_author_monthly.date_created, user_kreator_author_monthly.userid, userlogin.username ,user_kreator_author_monthly.total_thread,user_kreator_author_monthly.total_thread_approv,user_kreator_author_monthly.total_thread_pending from user_kreator_author_monthly join userlogin on user_kreator_author_monthly.userid=userlogin.userid where date_created>=date_format(DATE_SUB(NOW(), INTERVAL 2 MONTH),'%Y%m');" > $data_dir/kreator_author_monthly_$date_name".csv"

bq load kaskus_reporting.user_kreator_author_monthly $data_dir/user_kreator_author_monthly.csv

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[MONTHLY] KREATOR AUTHOR STATISTIC" -m "STATISTIC KREATOR AUTHOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/kreator_author_monthly_$date_name".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[MONTHLY] KREATOR AUTHOR STATISTIC" -m "STATISTIC KREATOR AUTHOR PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/kreator_author_monthly_$date_name".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
