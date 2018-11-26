condition="$1"
start_date=`date +%Y%m01`
month_start=`date -d "$start_date" +%s`
hariini=`date +%Y%m%d`
currentday=`date -d "$hariini" +%s`
data_dir="/home/rully/kreator_report/weekly"


if [ "$condition" = "week" ]
then
subjek="WEEKLY"
tgl_mulai=`date -d "$hariini 1 week ago" "+%s"`
  if [ $tgl_mulai -lt $month_start ]
  then
    tgl_mulai=$month_start
                echo "1" > $data_dir/temp_count_week
                counter_week=`cat $data_dir/temp_count_week`
    else
    tgl_mulai=$tgl_mulai
                counter_week=`cat $data_dir/temp_count_week`
                counter_week=`expr $counter_week + 1`
                echo $counter_week > $data_dir/temp_count_week
  fi
        month_naming=`date -d@$month_start +"%m_%Y"`
        file_naming='kreator_weekly_w'$counter_week'_'$month_naming
  if [ $currentday -eq $month_start ]
    then
      exit
  fi
elif [ "$condition" = "month" ]
then
subjek="MONTHLY"
tgl_mulai=`date -d '1 month ago' "+%s"`
month_naming=`date -d@$month_start +"%m_%Y"`
file_naming='kreator_monthly_'$month_naming
fi

mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.aggregate([{\$match:{dateline:{\$gte:$tgl_mulai,\$lt:$currentday}}},{\$group:{_id:{group_date:'\$group_date',post_userid:'\$userid',current_status:'\$current_status'},total:{\$sum:1}}},{\$project:{_id:0,group_date:'\$_id.group_date',userid:'\$_id.post_userid',pending:{\$cond:{if:{\$eq:['\$_id.current_status',2]},then: '\$total',else: 0}},approve:{\$cond:{if:{\$eq:['\$_id.current_status',1]},then: '\$total',else: 0}},reject:{\$cond:{if:{\$eq:['\$_id.current_status',3]},then: '\$total',else: 0}}}},{\$project:{date:'\$group_date',userid_creator:'\$userid',total_thread:{\$add:['\$approve','\$pending','\$reject']},approved_thread:'\$approve',pending_thread:'\$pending'}}]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s/{\n\t"date" : NumberLong(/"/g;s@),\n\t"userid_creator" : NumberLong(@","@g;s@),\n\t"total_thread" : @","@g;s@,\n\t"approved_thread" : @","@g;s@,\n\t"pending_thread" : @","@g;s@\n}@"@g' >> $data_dir/user_kreator_daily.csv


#create table user_kreator_daily (userid int(11), date_created Date, total_thread int(11), total_thread_approv int(11), total_thread_pending int(11));
mysqlimport --fields-terminated-by=, --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test  $data_dir/user_kreator_daily.csv;
echo '"Date","author","thread_created","thread_approve","thread_pending"' > $data_dir/$file_naming".csv"
mysql -h 172.20.0.159 -ubackup -pkaskus  test -r -s -N -e "select from_unixtime(date_created,'%Y-%m-%d'),userid,total_thread,total_thread_approv,total_thread_pending from user_kreator_daily where date_created >= $tgl_mulai and date_created < $currentday;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" >> $data_dir/$file_naming".csv"


bq load kaskus_reporting.user_kreator_daily $data_dir/user_kreator_daily.csv

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[$subjek] KREATOR USER STATISTIC" -m "STATISTIC KREATOR USER PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[$subjek] KREATOR USER STATISTIC" -m "STATISTIC KREATOR USER PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

