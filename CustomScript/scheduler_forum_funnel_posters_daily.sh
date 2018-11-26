allforum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'  |sed "s@,@','@g;s@^@'@g;s@\\$@'@g"`
data_dir="/home/rully/kpi_report/forum_funnel/daily"

month_naming=`date -d"yesterday" +"%Y-%m"`
nama_file='posters_'$month_naming

start_date=`date +%Y%m01`
akhir=`date  +%Y%m%d`
if [ $start_date -eq $akhir ]
  then
  start_date=`date -d "- 1 month" +%Y%m01`
fi
mulai=`date -d "$akhir - 1 day" +%s`
month_start=`date -d "$start_date" +%s`
date_end=`date -d "$akhir" +%s`
OID_START=`mongo 172.20.0.156/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($mulai).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.20.0.156/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($date_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
date_name=`date -d@$mulai +%Y-%m-%d`


rm $data_dir/mypost_forum.temp
for i in `seq 0 499`
do
mongoexport -h 172.20.0.156 -uriamande -pchopinnocturne92 --authenticationDatabase=admin -d kaskus_forum1 -c mypost_$i -f post_userid --type=csv -q "{'forum_id':{\$in:[$allforum]}, _id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}}" -o $data_dir/post_forum.csv
cat $data_dir/post_forum.csv |grep -v 'post_userid' >> $data_dir/mypost_forum.temp
done
comment=`cat $data_dir/mypost_forum.temp |sort |uniq |wc -l`
post=`cat $data_dir/mypost_forum.temp |wc -l`

echo '"'$date_name'","'$comment'","'$post'"' > $data_dir/posters_daily.csv

#create table posters_daily (date_created date, user_comment int(11), reply int(11));
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/posters_daily.csv;
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select * from posters_daily where date_created >='$start_date' and date_created < '$akhir' ;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" >  $data_dir/$nama_file".csv"

bq load kaskus_reporting.posters_daily $data_dir/posters_daily.csv date_created:date,user_comment:integer,reply:integer
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[DAILY] MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM FUNNEL POSTER PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$nama_file".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM FUNNEL POSTER PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$nama_file".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
