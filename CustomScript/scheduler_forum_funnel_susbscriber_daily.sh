all_forum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'`
allforum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'  |sed "s@,@','@g;s@^@'@g;s@\\$@'@g"`

data_dir="/home/rully/kpi_report/forum_funnel/daily"
month_naming=`date -d"yesterday" +"%Y-%m"`
naming_file='Subscribers_'$month_naming

start_date=`date +%Y%m01`
akhir=`date  +%Y%m%d`
if [ $start_date -eq $akhir ]
  then
  start_date=`date -d "- 1 month" +%Y%m01`
fi
month_start=`date -d "$start_date" +%s`
date_end=`date -d "$akhir" +%s`
mulai=`date -d "$akhir - 1 day" +%s`
date_name=`date -d@$mulai +%Y-%m-%d`
OID_START=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($mulai).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($date_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`


#user_subscribe_thread
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.subscribethread.find({forum_id:{\$in:[$all_forum]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0, userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g'  > $data_dir/substhread.temp
subscribe_thread=`cat $data_dir/substhread.temp |sort |uniq |wc -l`

#user_subscribe_forum
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.subscribeforum.find({forumid:{\$in:[$allforum]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0, userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/subsforum.temp
subscribe_forum=`cat $data_dir/subsforum.temp |sort |uniq |wc -l`

#9-user_add_friend,10-user_stalk
mongo 172.20.0.242/kaskus_friend_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_activity_log.find({processname: 'friend_invite', _id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/subsinvite.temp
total_friend_invite=`cat $data_dir/subsinvite.temp |sort |uniq |wc -l`
mongo 172.20.0.242/kaskus_friend_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_activity_log.find({processname: 'friend_friend', _id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/subsfriend.temp
total_friend_friend=`cat $data_dir/subsfriend.temp |sort |uniq |wc -l`
uniq_user_add_friend=`expr $total_friend_friend / 2 + $total_friend_invite`
mongo 172.20.0.242/kaskus_friend -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_follow.find({last_activity:{\$gte:$mulai,\$lte:$date_end}},{_id:0,followed_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g'  > $data_dir/subsstalk.temp
total_stalkfriend=`cat $data_dir/subsstalk.temp |sort |uniq |wc -l`
uniq_u_stalk_f=`expr $total_friend_friend / 2 + $total_stalkfriend`

uniq_susbcriber=`cat $data_dir/substhread.temp $data_dir/subsforum.temp $data_dir/subsinvite.temp $data_dir/subsfriend.temp $data_dir/subsstalk.temp  |sort |uniq |wc -l`

event_subscribe_forum=`cat $data_dir/subsforum.temp |wc -l`
event_subscribe_thread=`cat $data_dir/substhread.temp |wc -l`

event1=`cat $data_dir/subsinvite.temp |wc -l`
event2=`cat $data_dir/subsfriend.temp |wc -l`
event_add_friend=`expr $event2 / 2 + $event1`

event_stalk_friend=`cat $data_dir/subsstalk.temp |wc -l`

echo '"'$date_name'","'$uniq_susbcriber'","'$subscribe_forum'","'$subscribe_thread'","'$uniq_user_add_friend'","'$uniq_u_stalk_f'","'$event_subscribe_forum'","'$event_subscribe_thread'","'$event_add_friend'","'$event_stalk_friend'"' > $data_dir/subscriber_daily.csv

#create table subscriber_daily (date_created date, uniq_subscriber int(11),susbcribe_forum int(11),subscribe_thread int(11),uniq_user_add_friend int(11),uniq_u_stalk_f int(11),event_subscribe_forum int(11),event_subscribe_thread int(11),event_add_friend int(11),event_stalk_friend int(11));
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/subscriber_daily.csv;
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select * from subscriber_daily where date_created >='$start_date' and date_created < '$akhir' ;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $data_dir/$naming_file".csv"

bq load kaskus_reporting.subscribers_daily $data_dir/subscriber_daily.csv date_created:date,uniq_subscriber:integer,subscribe_forum:integer,subscribe_thread:integer,uniq_user_add_friend:integer,uniq_u_stalk_f:integer,event_subscribe_forum:integer,event_subscribe_thread:integer,event_add_friend:integer,event_stalk_friend:integer
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[DAILY] MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM FUNNEL SUBSCRIBE PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$naming_file".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM FUNNEL SUBSCRIBE PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$naming_file".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
