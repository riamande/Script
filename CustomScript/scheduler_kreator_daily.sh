fjb=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`
bot="746,753,854,730,851,864"
data_dir="/home/rully/kreator_report/daily"

echo '"Date","total userid who create thread","total thread","total user register creator","total userid kreator","total thread creator","total user kreator who created thread approve","total thread approve","total user kreator who created thread pending","total thread pending"' > $data_dir/all_authordaily.csv
start_date=`date +%Y%m01`
akhir=`date  +%Y%m%d`
#akhir="$1" ## customdate
currentday=`date -d"$akhir" +%s`
kemarin=`date -d"$akhir - 1 day"`
akhir_str=`date +"%Y-%m-%d"`
yesterday=`date -d"$akhir - 1 day" +%s`
date_now=`date  +"%Y-%m-%d %H:%M:%S"`
if [ $start_date -eq $akhir ]
  then
  start_date=`date -d "- 1 month" +%Y%m01`
fi
awal_str=`date -d "$start_date" +"%Y-%m-%d"`
month_start=`date -d "$start_date" +%s`
date_end=`date -d "$akhir" +%s`
while [ $month_start -lt $date_end ]
do
end_date=`expr $month_start + 86400`
OID_START=`mongo 172.16.0.88:27018/kaskus_forum -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($month_start).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.16.0.88:27018/kaskus_forum -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
date_name=`date -d@$month_start +%Y-%m-%d`

#thred approve,pending.
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$month_start,\$lt:$end_date},current_status:2},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/thread_approve_authordaily.temp
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$month_start,\$lt:$end_date},current_status:1},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/thread_pending_authordaily.temp

total3=`cat $data_dir/thread_approve_authordaily.temp |sort |uniq |wc -l`
total4=`cat $data_dir/thread_approve_authordaily.temp |wc -l`
total5=`cat $data_dir/thread_pending_authordaily.temp |sort |uniq |wc -l`
total6=`cat $data_dir/thread_pending_authordaily.temp |wc -l`

month_start="$end_date"
echo '"'$date_name'","'$total3'","'$total4'","'$total5'","'$total6'"' > $data_dir/kreator_daily.temp
echo '"'$date_name'","'$date_now'","'$total3'","'$total4'","'$total5'","'$total6'"' > $data_dir/kreator_daily.csv
done

#thread all
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({dateline:{\$gte:$yesterday,\$lt:$currentday}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/threadall_authordaily.temp
jumlahuser=`cat $data_dir/thread_authordaily.temp |sort |uniq |wc -l`
jumlahthread=`cat $data_dir/thread_authordaily.temp |wc -l`

#Total registered creator
#mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.user_account_activity_log.find({_id:{\$gte:ObjectId('58b5ac900000000000000000'),\$lt:ObjectId('$OID_END')},processname:'accept_vtm_request'},{user_id:1,_id:0}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' |sort |uniq >  $data_dir/regiscreator_authordaily.temp
#mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select user_id from forum_user_setting where vtm_status=1;" > $data_dir/regiscreator_authordaily.temp
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select distinct a.user_id from forum_user_setting a,vtm_request b where a.user_id=b.userid and a.vtm_status=1 and b.status=2 ;" > $data_dir/regiscreator_authordaily.temp
jumlahregis=`cat $data_dir/regiscreator_authordaily.temp |wc -l`

#jumlah user kreator, jumlah thread kreator
mongo 172.16.0.88:27018/kaskus_forum -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread.find({forum_id:{\$nin:[$fjb,$bot,0]}, dateline:{\$gt:$yesterday,\$lt:$currentday}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 > $data_dir/thread_authordaily.temp
total1=`cat $data_dir/threadall_authordaily.temp |sort |uniq |wc -l`
total2=`cat $data_dir/threadall_authordaily.temp |wc -l`
echo '"'$date_name'","'$jumlahuser'","'$jumlahthread'","'$jumlahregis'","'$total1'","'$total2'"' > $data_dir/user_daily.temp

#create table user_daily (dateday DATE PRIMARY KEY ,total_user int(11), total_thread int(11), total_user_register int(11), total_user_creator int(11), total_thread_creator int(11));
#create table kreator_daily (dateday DATE PRIMARY KEY , total_user_approve int(11), total_thread_approve int(11), total_user_pending int(11), total_thread_pending int(11));

mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus -c dateday,total_user,total_thread,total_user_register,total_user_creator,total_thread_creator test $data_dir/user_daily.temp;
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus -c dateday,total_user_approve,total_thread_approve,total_user_pending,total_thread_pending test  $data_dir/kreator_daily.temp;

mysql -h 172.20.0.159 -ubackup -pkaskus test -r -s -N -e "select user_daily.*, kreator_daily.total_user_approve, kreator_daily.total_thread_approve, kreator_daily.total_user_pending,kreator_daily.total_thread_pending from user_daily join kreator_daily on user_daily.dateday=kreator_daily.dateday where user_daily.dateday >= '$awal_str' and user_daily.dateday <= '$akhir_str';" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" >> $data_dir/all_authordaily.csv

bq load kaskus_reporting.user_daily $data_dir/user_daily.temp
bq load kaskus_reporting.kreator_daily $data_dir/kreator_daily.csv 

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "DAILY THREAD CREATOR STATISTIC" -m "STATISTIC KREATOR PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/all_authordaily.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "DAILY THREAD CREATOR STATISTIC" -m "STATISTIC KREATOR PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/all_authordaily.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

