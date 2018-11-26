MONGO_USER="riamande"
MONGO_PASS="chopinnocturne92"
MYSQL_USER="riamande"
MYSQL_PASS="chopinnocturne92"
tgl_mulai=`date -d " - 1 month " +%Y%m%d`
date_mulai=`date -d "$tgl_mulai" +%s`
tgl_akhir=`date -d "$tgl_mulai + 1 month" +%s`
end_date=`date -d@$tgl_akhir +%Y-%m-%d`
datadir="/home/rully/kpi_report"
total=""
a="746 753 854 730 851 864"

echo '"Periode","Beritagar","Gatra","Media Indonesia","Metrotvnews.com","Tribunnews.com","IDNTimes"' > $datadir/total_thread_forum_partner_"$tgl_mulai".csv
echo '"Link_profile","Reply","Share"' > $datadir/top_thread_partner_"$tgl_mulai".csv

for i in $a
do
name=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum  -r -s -N -e "select name from forum_list where forum_id=$i;"`

### start jumlah thread/bulan
mongo 172.16.0.88:27018/kaskus_forum -u$MONGO_USER -p$MONGO_PASS --authenticationDatabase=admin --eval "db.thread.count({forum_id:{\$in:[$i]},dateline:{\$gte:$date_mulai,\$lte:$tgl_akhir},visible:1})" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/tot_thread1.temp

date_name=`date -d@$date_mulai +%m/%d/%Y`
result=`cat $datadir/tot_thread1.temp`
total="$total,$result"
### end jumlah thread/bulan

### start top 10 thread
mongo 172.16.0.88:27018/kaskus_forum  -u$MONGO_USER -p$MONGO_PASS --authenticationDatabase=admin --eval "db.thread.aggregate([{\$match:{forum_id:{\$in:[$i]},dateline:{\$gte:$date_mulai,\$lte:$tgl_akhir}}},{\$project:{reply_count:{\$ifNull:['\$reply_count',0]},'socialMediacounter.share_fb':{\$ifNull:['\$socialMediacounter.share_fb',0]},'socialMediacounter.share_gplus' : { \$ifNull: [ '\$socialMediacounter.share_gplus', 0 ] },'socialMediacounter.share_twitter' : { \$ifNull: [ '\$socialMediacounter.share_twitter', 0 ] }} },{\$project:{reply:'\$reply_count',share:{\$add:['\$socialMediacounter.share_fb','\$socialMediacounter.share_gplus','\$socialMediacounter.share_twitter']}}},{\$sort:{share:-1,reply:-1}},{\$limit:10}]).forEach(printjson)" |sed 's@"_id" : ObjectId("@"https://www.kaskus.co.id/thread/@g' |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/part.temp
echo '"'$name'"' >> $datadir/top_thread_partner_"$tgl_mulai".csv
cat $datadir/part.temp |sed ':a;N;$!ba;s/{\n\t//g;s@"),@",@g;s@,\n\t"reply" : NumberLong(@,"@g;s@),\n\t"share" : @","@g;s@\n}@"@g'  >> $datadir/top_thread_partner_"$tgl_mulai".csv
### end top 10 thread
done

echo '"'$date_name'"'$total>> $datadir/total_thread_forum_partner_"$tgl_mulai".csv

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[MONTHLY] FORUM PARTNER" -m "Data Forum Partner PER $end_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/top_thread_partner_"$tgl_mulai".csv $datadir/total_thread_forum_partner_"$tgl_mulai".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t quary.mitratama@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,rully@kaskusnetworks.com,db@kaskusnetworks.com -u "[MONTHLY] FORUM PARTNER" -m "Data Forum Partner PER $end_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/top_thread_partner_"$tgl_mulai".csv $datadir/total_thread_forum_partner_"$tgl_mulai".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
