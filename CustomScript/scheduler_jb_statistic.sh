MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
#datadir="/home/rully/kpi_report"
datadir="/home/rully/kpi_report/custom/monthly"
#month_start=`date +%Y%m01`
month_start="$1"
end_date=`date -d "$month_start" +%s`
start_date=`date -d "$month_start - 1 month" +%s`
last_month=`date -d "$month_start - 2 month" +%s`
date_naming=`date -d@$start_date +%Y%m`
month_name=`date -d@$start_date +%m`
year_name=`date -d@$start_date +%Y`
OID_LAST=`mongo --eval "Math.floor($last_month).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_START=`mongo --eval "Math.floor($start_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`
### Active Login: Banyaknya user yang login di JB dalam 30 hari terakhir pada bulan X ###
/opt/mongodb_3.0.10/bin/mongo 172.20.0.91/kaskus_user_log -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.userloginlog.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},referer:/fjb./},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 |sort |uniq |wc -l > $datadir/temp_1.temp
total_1=`cat $datadir/temp_1.temp`
### SellerX: Banyaknya user yang membuat lapak pada bulan X ###
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},prefix_id:{\$in:[/wts/i,/sold/i]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_2.temp
total_3=`cat $datadir/temp_2.temp |sort |uniq |wc -l`
### Active Seller: Banyaknya Seller yang ada pada bulan X yang punya minimal 1 listing yang tidak sold out ###
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},prefix_id:{\$in:[/wts/i]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_3.temp
total_4=`cat $datadir/temp_3.temp |sort |uniq |wc -l`
### New Seller: Banyaknya user yang baru pertama kali buat lapak pada bulan X ###
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$in:[$fjb_id]},_id:{\$gte:ObjectId('$OID_LAST'),\$lt:ObjectId('$OID_START')},prefix_id:{\$in:[/wts/i,/sold/i]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_4.temp
cat $datadir/temp_4.temp |sort |uniq >> $datadir/temp_allseller.temp
cat $datadir/temp_allseller.temp |sort |uniq > $datadir/temp_allseller.txt
mv $datadir/temp_allseller.txt $datadir/temp_allseller.temp
#diff -u <(cat $datadir/temp_allseller.temp |sort |uniq) <(cat $datadir/temp_2.temp |sort |uniq) |grep '\+' |wc -l > $datadir/temp_count.temp
total_5=`cat $datadir/temp_2.temp |sort |uniq |diff -u $datadir/temp_allseller.temp - |grep '+' |wc -l`
### Seller: Banyaknya user yang membuat lapak hingga bulan X ###
total_2=`cat $datadir/temp_allseller.temp $datadir/temp_2.temp |sort |uniq |wc -l`
### Engaged Seller: Banyaknya seller yang membuat lapak pada bulan X dan juga membuat pada lapak pada bulan X-1 (sebelumnya) ###
#total_5=`diff -u <(cat $datadir/temp_4.temp |sort |uniq) <(cat $datadir/temp_2.temp |sort |uniq) |grep -v '\+\|\-' |wc -l`
cat $datadir/temp_2.temp |sort |uniq > $datadir/temp_diff2.temp
cat $datadir/temp_4.temp |sort |uniq > $datadir/temp_diff4.temp
total_6=`cat $datadir/temp_diff2.temp |diff -u $datadir/temp_diff4.temp - |grep -v '\+\|\-' |wc -l`
### New Listing: Banyaknya listing yang dibuat pada bulan X ###
total_7=`cat $datadir/temp_2.temp |wc -l`
### Listing: Banyaknya listing yang dibuat sampai bulan X ###
total_temp_all=`tail -n 1 $datadir/temp_total_listing.temp`
total_8=`expr $total_temp_all + $total_7`
echo $total_8 >> $datadir/temp_total_listing.temp
### Active Listing: Banyaknya Listing yang ada pada bulan X yang tidak sold out ###
total_9=`cat $datadir/temp_3.temp |wc -l`
### Buyer: Banyaknya user yang pernah membeli minimal 1 kali sejak awal JB sampai bulan X (seharusnya tiap bulan terus bertambah) ###
total_10=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(distinct buyer_id) from transaction where transaction_status in (5,6,8) and payment_date < $end_date;"`
### Buyer X: Banyaknya user yang membeli pada bulan X ###
total_11=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(distinct buyer_id) from transaction where transaction_status in (5,6,8) and payment_date>= $start_date and payment_date < $end_date;"`
### New buyer: Banyaknya user yang baru pertama kali membeli pada bulan X ###
total_12=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(*) from (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date>=$start_date and payment_date<$end_date) a left join (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date<$start_date) b on a.userid=b.userid where b.userid is null;"`
### Engaged Buyer: Banyaknya user yang membeli pada bulan X dan juga membeli pada bulan X-1 (sebelumnya) ###
total_13=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.77 kaskus_fjb -r -s -N -e "select count(*) from (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date>=$start_date and payment_date<$end_date) a join (select distinct(buyer_id) userid from transaction where transaction_status in (5,6,8) and payment_date>=$last_month and payment_date<$start_date) b on a.userid=b.userid;"`
echo '"Month","Year","[1] Active Login","[2] Seller","[3] Seller X","[4] Active Seller","[5] New Seller","[6] Engaged Seller","[7] New Listing","[8] Listing","[9] Active Listing","[10] Buyer","[11] Buyer X","[12] New buyer","[13] Engaged Buyer"' > $datadir/jb_statistic_report_"$date_naming".csv
echo '"'$month_name'","'$year_name'","'$total_1'","'$total_2'","'$total_3'","'$total_4'","'$total_5'","'$total_6'","'$total_7'","'$total_8'","'$total_9'","'$total_10'","'$total_11'","'$total_12'","'$total_13'"' >> $datadir/jb_statistic_report_"$date_naming".csv
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,novri.suhermi@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,antonia.kalisa@kaskusnetworks.com,fauzan.ramadhanu@kaskusnetworks.com,seno@kaskusnetworks.com -u "MONTHLY JB STATISTIC" -m "STATISTIC JB PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/jb_statistic_report_"$date_naming".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "MONTHLY JB STATISTIC" -m "STATISTIC JB PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/jb_statistic_report_"$date_naming".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
