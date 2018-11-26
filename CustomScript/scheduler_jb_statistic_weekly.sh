MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
periode_report=7 ### weekly
fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`
datadir="/home/rully/kpi_report/weekly"
#datadir="/home/rully/kpi_report/custom"
naming_date=`date +%Y%m%d`
week_start=`date -d "-1 day - $periode_report day" +%Y%m%d` ### start H -7
week_end=`date -d "$week_start + $periode_report day" +%s`
week_start_timestamp=`date -d "$week_start" +%s` ### start H -7
echo '"Date","[1] Active Login","[2] Seller","[3] Seller X","[4] Active Seller","[5] New Seller","[6] Engaged Seller","[7] New Listing","[8] Listing","[9] Active Listing","[10] Buyer","[11] Buyer X","[12] New buyer","[13] Engaged Buyer"' > $datadir/jb_statistic_report_"$naming_date".csv

### initial data sold
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},dateline:{\$lt:$week_start_timestamp},visible:1,prefix_id:/wts/i},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_datex.temp
### loop
for i in `seq 1 $periode_report`
do
start_date=`date -d "$week_start + $i day - 1 day" +%s`
start_date_str=`date -d@$start_date +%Y%m%d`
end_date=`date -d "$week_start + $i day" +%s`
last_week=`date -d "$start_date_str - 7 day" +%s` ### lastweek interval 7 days
last_month=`date -d "$start_date_str - 30 day" +%s` ### last 30 days interval
date_naming=`date -d@$start_date +%m/%d/%Y`
OID_LASTWEEK=`mongo --eval "Math.floor($last_week).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_START=`mongo --eval "Math.floor($start_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_LASTMONTH=`mongo --eval "Math.floor($last_month).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`

### Active Login: Banyaknya user yang login di JB dalam 30 hari terakhir pada tanggal X ###
/opt/mongodb_3.0.10/bin/mongo 172.20.0.91/kaskus_user_log -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.userloginlog.find({_id:{\$gte:ObjectId('$OID_LASTMONTH'),\$lt:ObjectId('$OID_END')},referer:/fjb./},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 |sort |uniq |wc -l > $datadir/temp_1.temp
total_1=`cat $datadir/temp_1.temp`
### SellerX: Banyaknya user yang membuat lapak pada tanggal X ###
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},prefix_id:{\$in:[/wts/i,/sold/i]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_2.temp
total_13=`cat $datadir/temp_2.temp |sort |uniq |wc -l`
### Active Seller: Banyaknya Seller yang ada pada tanggal X yang punya minimal 1 listing yang tidak sold out ###
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},prefix_id:{\$in:[/wts/i]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_3.temp
cat $datadir/temp_3.temp >> $datadir/temp_datex.temp
total_3=`cat $datadir/temp_datex.temp |sort |uniq |wc -l`
### New Seller: Banyaknya user yang baru pertama kali buat lapak pada tanggal X ###
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},_id:{\$gte:ObjectId('$OID_LASTWEEK'),\$lt:ObjectId('$OID_START')},prefix_id:{\$in:[/wts/i,/sold/i]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_4.temp
cat $datadir/temp_4.temp |sort |uniq >> $datadir/temp_allseller.temp
cat $datadir/temp_allseller.temp |sort |uniq > $datadir/temp_allseller.txt
mv $datadir/temp_allseller.txt $datadir/temp_allseller.temp
#diff -u <(cat $datadir/temp_allseller.temp |sort |uniq) <(cat $datadir/temp_2.temp |sort |uniq) |grep '\+' |wc -l > $datadir/temp_count.temp
total_4=`cat $datadir/temp_2.temp |sort |uniq |diff -u $datadir/temp_allseller.temp - |grep '+' |wc -l`
### Seller: Banyaknya user yang membuat lapak hingga tanggal X ###
total_2=`cat $datadir/temp_2.temp $datadir/temp_allseller.temp |sort |uniq |wc -l`
### Engaged Seller: Banyaknya seller yang membuat lapak pada tanggal X dan juga membuat pada lapak pada tanggal X-7 (sebelumnya) ###
#total_5=`diff -u <(cat $datadir/temp_4.temp |sort |uniq) <(cat $datadir/temp_2.temp |sort |uniq) |grep -v '\+\|\-' |wc -l`
cat $datadir/temp_2.temp |sort |uniq > $datadir/temp_diff2.temp
cat $datadir/temp_4.temp |sort |uniq > $datadir/temp_diff4.temp
total_5=`cat $datadir/temp_diff2.temp |diff -u $datadir/temp_diff4.temp - |grep -v '\+\|\-' |wc -l`
### New Listing: Banyaknya listing yang dibuat pada tanggal X ###
total_6=`cat $datadir/temp_2.temp |wc -l`
### Listing: Banyaknya listing yang dibuat sampai tanggal X ###
total_temp_all=`tail -n 1 $datadir/temp_total_listing.temp`
total_7=`expr $total_temp_all + $total_6`
echo $total_7 >> $datadir/temp_total_listing.temp
### Active Listing: Banyaknya Listing yang ada pada tanggal X yang tidak sold out ###
total_8=`cat $datadir/temp_datex.temp |wc -l`
### Buyer: Banyaknya user yang pernah membeli minimal 1 kali sejak awal JB sampai tanggal X (seharusnya tiap bulan terus bertambah) ###
total_9=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(distinct buyer_id) from transaction where transaction_status in (5,6,8) and payment_date < $end_date;"`
### Buyer X: Banyaknya user yang membeli pada tanggal X ###
total_10=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(distinct buyer_id) from transaction where transaction_status in (5,6,8) and payment_date>= $start_date and payment_date < $end_date;"`
### New buyer: Banyaknya user yang baru pertama kali membeli pada tanggal X ###
total_11=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(*) from (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date>=$start_date and payment_date<$end_date) a left join (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date<$start_date) b on a.userid=b.userid where b.userid is null;"`
### Engaged Buyer: Banyaknya user yang membeli pada tanggal X dan juga membeli pada tanggal X-7 (sebelumnya) ###
total_12=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(*) from (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date>=$start_date and payment_date<$end_date) a join (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date>=$last_week and payment_date<$start_date) b on a.userid=b.userid;"`

echo '"'$date_naming'","'$total_1'","'$total_2'","'$total_13'","'$total_3'","'$total_4'","'$total_5'","'$total_6'","'$total_7'","'$total_8'","'$total_9'","'$total_10'","'$total_11'","'$total_12'"' >> $datadir/jb_statistic_report_"$naming_date".csv
done
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,novri.suhermi@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,antonia.kalisa@kaskusnetworks.com,fauzan.ramadhanu@kaskusnetworks.com,seno@kaskusnetworks.com -u "WEEKLY JB STATISTIC" -m "STATISTIC JB PER $naming_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/jb_statistic_report_"$naming_date".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "WEEKLY JB STATISTIC" -m "STATISTIC JB PER $naming_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/jb_statistic_report_"$naming_date".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
