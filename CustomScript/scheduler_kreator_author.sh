akhir=`date  +%Y%m01`
start_date=`date -d "$akhir - 1 month" +%s`
end_date=`date -d "$akhir" +%s`
OID_START=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($start_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
date_name=`date -d@$start_date +%Y%m`
data_dir="/home/rully/kreator_report/monthly/author"
echo '"userid","username","join kaskus","join kreator","jumlah thread before kreator","jumlah thread after kreator","Jumlah thread approve","jumlah thread pending","total reply"' > $data_dir/kreator_author_$date_name".csv"

> $data_dir/creatorjoin.csv
forum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241);" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'`
forumid=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241);" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'  |sed "s@,@','@g;s@^@'@g;s@\\$@'@g"`
#user yang telah join menjadi creator
#mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.user_account_activity_log.find({processname:'accept_vtm_request',_id:{\$gte:ObjectId('$OID_START'),\$#lt:ObjectId('$OID_END')}},{_id:0,date:1,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f 3,6 |sed 's@: NumberLong(@@g' |sed 's@)@@g' |sed 's@"@@g;s@^ @"@g;s@, @","@g;s@$@"@g' >> $data_dir/creatorjoin.csv
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select distinct a.user_id, from_unixtime(b.response_date,'%Y-%m-%d') from forum_user_setting a,vtm_request b where a.user_id=b.userid and a.vtm_status=1 and b.status=2 and b.response_date >= $start_date and b.response_date < $end_date;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" >> $data_dir/creatorjoin.csv

#thread before creator
#mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.user_account_activity_log.find({processname:'accept_vtm_request',_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f3 |sed 's/[^0-9]*//g' > $data_dir/usercreator.temp
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select distinct a.user_id from forum_user_setting a,vtm_request b where a.user_id=b.userid and a.vtm_status=1 and b.status=2 and b.response_date >=$start_date and b.response_date<$end_date;" > $data_dir/usercreator.temp
> $data_dir/threadall.csv
> $data_dir/thread_before_creator.csv
for i in `cat $data_dir/usercreator.temp`
do
mod_user=`expr $i % 500`
mongoexport -h 172.20.0.242:27017 -d kaskus_forum1 -c mythread_$mod_user -uriamande -pchopinnocturne92 --authenticationDatabase=admin  -f thread_userid --type=csv -q "{forum_id:{\$in:[$forumid,'602']},thread_userid:'$i'}"  -o $data_dir/threadall.temp
cat $data_dir/threadall.temp |grep -v 'thread_userid' >> $data_dir/threadall.csv
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.count({userid:$i})"  |grep -v 'MongoDB shell version:\|connecting to:' > $data_dir/beforecreator.csv
jum_all=`cat $data_dir/threadall.temp |wc -l`
jum_creator=`cat $data_dir/beforecreator.csv`
jumthreadbefore=`expr $jum_all - $jum_creator`
echo '"'$i'","'$jumthreadbefore'"' >> $data_dir/thread_before_creator.csv
done


#thread after creator
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.aggregate([{\$group:{_id:{post_userid:'\$userid'},total:{\$sum:1}}}]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sort > $data_dir/creator_thread
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.aggregate([{\$group:{_id:{post_userid:'\$userid',current_status:'\$current_status'},total:{\$sum:1}}}]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s/{\n\t//g;s@\n@@g;s@\t@@g;s@"_id" :@\n@g;s@}@@g' > $data_dir/approvedanpending
cat $data_dir/creator_thread |sed 's/[^0-9,]*//g' > $data_dir/threadcreator.temp
cat $data_dir/approvedanpending |grep  '"current_status" : NumberLong(2)' |sed 's@"current_status" : NumberLong(2),@@g' |sed 's/[^0-9,]*//g' |sort > $data_dir/approve_daily.temp
cat $data_dir/approvedanpending |grep  '"current_status" : NumberLong(1)' |sed 's@"current_status" : NumberLong(1),@@g' |sed 's/[^0-9,]*//g' |sort > $data_dir/pending_daily.temp

#mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.aggregate([{\$match:{dateline:{\$gte:$start_date,\$lt:$end_date}}},{\$group:{_id:{group_date:'\$group_date',post_userid:'\$userid'},total:{\$sum:1}}}]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s/{\n\t//g;s@\n@@g;s@\t@@g;s@"_id" :@\n@g;s@}@@g' |sed 's/[^0-9,]*//g' |sort > $data_dir/threadcreator.temp
#mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.aggregate([{\$match:{dateline:{\$gte:$start_date,\$lt:$end_date}}},{\$group:{_id:{group_date:'\$group_date',post_userid:'\$userid',current_status:'\$current_status'},total:{\$sum:1}}}]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s/{\n\t//g;s@\n@@g;s@\t@@g;s@"_id" :@\n@g;s@}@@g' > $data_dir/approvedanpending
#cat $data_dir/approvedanpending |grep  '"current_status" : NumberLong(2)' |sed 's@"current_status" : NumberLong(2),@@g' |sed 's/[^0-9,]*//g' |sort > $data_dir/approve_daily.temp
#cat $data_dir/approvedanpending |grep  '"current_status" : NumberLong(1)' |sed 's@"current_status" : NumberLong(1),@@g' |sed 's/[^0-9,]*//g' |sort > $data_dir/pending_daily.temp


#Total reply
mongoexport -h  172.16.0.88:27018  -d kaskus_forum  -c thread -uriamande -pchopinnocturne92 --authenticationDatabase=admin  -f 'post_userid,reply_count,_id' --type=csv -q "{forum_id:{\$in:[$forum]},verified_creator:{\$exists:true},sticky:0,last_post:{\$gte:$start_date,\$lt:$end_date}}" -o $data_dir/thread_verified_creator.temp
cat $data_dir/thread_verified_creator.temp |grep -v 'post_userid,reply_count,_id' |cut -d '"' -f 4,7,10 |sed 's@" : @,@g' |sed 's@ "@@g' |sed 's@ObjectId(@@g;s@)@@g' > $data_dir/thread_reply.csv


#cat $data_dir/threadall.csv |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F ',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=','  >> $data_dir/thread_all.csv

join -11 -a1 $data_dir/threadcreator.temp $data_dir/approve_daily.temp -o1.1,1.2,2.2 -e0 -t ','  > $data_dir/all_and_approve
join -11 -a1 $data_dir/all_and_approve $data_dir/pending_daily.temp -o1.1,1.2,1.3,2.2 -e0 -t ','  > $data_dir/thread_aftercreator.csv


mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/creatorjoin.csv;
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/thread_reply.csv;
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/thread_aftercreator.csv;
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/thread_before_creator.csv;


mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select userlogin.userid, userlogin.username, \
from_unixtime(joindate) joindatekaskus, \
creatorjoin.joindate_creator, \
if(thread_before_creator.Total_before_creator is null,0,thread_before_creator.Total_before_creator) beforecreator, \
if(thread_aftercreator.total_thread is null,0,thread_aftercreator.total_thread) aftercreator , \
if(thread_aftercreator.total_thread_approve is null,0,thread_aftercreator.total_thread_approve) threadapproved, \
if(thread_aftercreator.total_thread_pending is null,0,thread_aftercreator.total_thread_pending) threadpending, \
SUM(if(thread_reply.total_reply is null,0,thread_reply.total_reply)) total_reply \
from userlogin \
join userinfo on userlogin.userid=userinfo.userid \
join creatorjoin on creatorjoin.userid=userlogin.userid \
left join thread_before_creator on thread_before_creator.userid=userlogin.userid \
left join thread_aftercreator on thread_aftercreator.userid=userlogin.userid \
left join  thread_reply on thread_reply.userid=userlogin.userid \
group by creatorjoin.userid;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $data_dir/kreator_author_$date_name".csv"

bq load kaskus_reporting.creatorjoin   $data_dir/creatorjoin.csv
bq load kaskus_reporting.thread_reply $data_dir/thread_reply.csv
bq load kaskus_reporting.thread_aftercreator $data_dir/thread_aftercreator.csv
bq load kaskus_reporting.thread_before_creator $data_dir/thread_before_creator.csv

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[MONTHLY] DAILY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/kreator_author_$date_name".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[MONTHLY] DAILY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/kreator_author_$date_name".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
