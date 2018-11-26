all_forum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'`
allforum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'  |sed "s@,@','@g;s@^@'@g;s@\\$@'@g"`

periode_report=7
week_start=`date -d " - $periode_report day" +%Y%m%d`
week_end=`date -d "$week_start + $periode_report day" +%s`
week_start_timestamp=`date -d "$week_start" +%s` ### start
OID_START=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($week_start_timestamp).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($week_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
date_name=`date -d@$week_end +%Y-%m-%d`
data_dir="/home/rully/kpi_report/forum_funnel"

mulai=`date +%Y%m01`
month_start=`date -d "$mulai" +%s`
tanggal=`date -d "yesterday" +%s`
if [ $tanggal -lt $month_start ]
  then
                echo "1" > $data_dir/count_week_hit
                counter_week_hit=`cat $data_dir/count_week_hit`
    else
                counter_week_hit=`cat $data_dir/count_week_hit`
                counter_week_hit=`expr $counter_week_hit + 1`
                echo $counter_week_hit > $data_dir/count_week_hit
fi

month_naming=`date -d"yesterday" +"%m_%Y"`
file_naming='forum_hit_weekly_'$month_naming'_W_'$counter_week_hit

echo '"tanggal","reputation","vote","subscribe_thread","subscribe_forum","add_friend","stalk","comment","created_thread","approved_threads"' > $data_dir/$file_naming".csv"

#user_give_reputation
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select whoadded from forum_reputation where dateline >=$week_start_timestamp  and dateline < $week_end ;" > $data_dir/u1_hit.temp
reputation=`cat $data_dir/u1_hit.temp |sort |uniq |wc -l`

#vote
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select  userid from  forum_poll_vote where votedate >=$week_start_timestamp  and votedate < $week_end;" > $data_dir/u2_hit.temp
vote=`cat $data_dir/u2_hit.temp |sort |uniq |wc -l`

#user_subscribe_thread
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.subscribethread.find({forum_id:{\$in:[$all_forum]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0, userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g'  > $data_dir/st_hit.temp
subscribe_thread=`cat $data_dir/st_hit.temp |sort |uniq |wc -l`

#user_subscribe_forum
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.subscribeforum.find({forumid:{\$in:[$allforum]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0, userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/sf_hit.temp
subscribe_forum=`cat $data_dir/sf_hit.temp |sort |uniq |wc -l`


#user_add_friend,user_stalk
mongo 172.20.0.242/kaskus_friend_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_activity_log.find({processname: 'friend_invite', _id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/invite_hit.temp
total_friend_invite=`cat $data_dir/invite_hit.temp |sort |uniq |wc -l`
mongo 172.20.0.242/kaskus_friend_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_activity_log.find({processname: 'friend_friend', _id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/friend_hit.temp
total_friend_friend=`cat $data_dir/friend_hit.temp |sort |uniq |wc -l`
add_friend=`expr $total_friend_friend / 2 + $total_friend_invite`
mongo 172.20.0.242/kaskus_friend -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_follow.find({last_activity:{\$gte:$week_start_timestamp ,\$lte:$week_end}},{_id:0,followed_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g'  > $data_dir/stalk_hit.temp
total_stalkfriend=`cat $data_dir/stalk_hit.temp |sort |uniq |wc -l`
stalk=`expr $total_friend_friend / 2 + $total_stalkfriend`

#number of comment
rm $data_dir/mypost_hit.temp
for i in `seq 0 499`
do
mongoexport -h 172.20.0.156 -uriamande -pchopinnocturne92 --authenticationDatabase=admin -d kaskus_forum1 -c mypost_$i -f post_userid --type=csv -q "{'forum_id':{\$in:[$allforum]}, _id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}}" -o $data_dir/post_hit.csv
cat $data_dir/post_hit.csv |grep -v 'post_userid' >> $data_dir/mypost_hit.temp
done
comment=`cat $data_dir/mypost_hit.temp |wc -l`

#create thread_id
mongo 172.16.0.88:27018/kaskus_forum -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "db.thread.find({forum_id:{\$in:[$all_forum]},dateline:{\$gte:$week_start_timestamp,\$lt:$week_end}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/total_tred_hit.temp
created_thread=`cat $data_dir/total_tred_hit.temp |wc -l`

#thread approved
mongo 172.16.0.88:27018/kaskus_forum -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "db.thread.find({forum_id:{\$in:[$all_forum]},dateline:{\$gte:$week_start_timestamp,\$lt:$week_end},visible:1},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/total_tread_hit.temp
approved_threads=`cat $data_dir/total_tread_hit.temp |wc -l`

echo '"'$date_name'","'$reputation'","'$vote'","'$subscribe_thread'","'$subscribe_forum'","'$add_friend'","'$stalk'","'$comment'","'$created_thread'","'$approved_threads'"' >> $data_dir/$file_naming".csv"

cat $data_dir/$file_naming".csv" |grep -v '"tanggal","reputation","vote","subscribe_thread","subscribe_forum","add_friend","stalk","comment","created_thread","approved_threads"' > $data_dir/forum_hit_weekly.csv

#create table forum_hit_weekly (created_date date, reputation int(11),vote int(11), subscribe_thread int(11),subscribe_forum int(11),add_friend int(11),stalk int(11),comment int(11),created_thread int(11),approved_threads int(11));
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.159 -ubackup -pkaskus  test $data_dir/forum_hit_weekly.csv ;

bq load kaskus_reporting.forum_hit_weekly $data_dir/forum_hit_weekly.csv created_date:date,reputation:integer,vote:integer,subscribe_thread:integer,subscribe_forum:integer,add_friend:integer,stalk:integer,comment:integer,created_thread:integer,approved_threads:integer
#bq load kaskus_reporting.forum_hit_weekly $data_dir/forum_hit_weekly.csv 
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[WEEKLY] WEEKLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[WEEKLY] WEEKLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

