
all_forum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'`
allforum=`mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select child_list from forum_list where forum_id in (72,241) and visible=1;" |sed ':a;N;$!ba;s/\n/,/g' |sed -e 's$\,\-1$$g'  |sed "s@,@','@g;s@^@'@g;s@\\$@'@g"`


data_dir="/home/rully/kpi_report/forum_funnel"
periode_report=7
week_start=`date -d "- $periode_report day" +%Y%m%d`
week_start_str=`date -d "$week_start" +%s`

mulai=`date +%Y%m01`
month_start=`date -d "$mulai" +%s`
tanggal=`date -d "yesterday" +%s`
if [ $tanggal -lt $month_start ]
  then
                echo "1" > $data_dir/count_week
                counter_week=`cat $data_dir/count_week`
    else
                counter_week=`cat $data_dir/count_week`
                counter_week=`expr $counter_week + 1`
                echo $counter_week > $data_dir/count_week
fi

month_naming=`date -d"yesterday" +"%m_%Y"`
file_naming='forum_user_weekly_'$month_naming'_W_'$counter_week
echo '"tanggal","total user login","voter","user_give_reputation","user_give_vote","subscriber","user_subscribe_thread","user_subscribe_forum ","user_add_friend","user_stalk","commenters","posters"' > $data_dir/$file_naming".csv"

for i in `seq 1 $periode_report`
do
start_date=`date -d "$week_start + $i day - 1 day" +%s`
end_date=`date -d "$week_start + $i day" +%s`

OID_START=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($start_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 172.20.0.91/kaskus_user_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
date_name=`date -d@$start_date +%Y-%m-%d`

#2-user login
mongo 172.20.0.96/kaskus_user -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk(); db.user_activity.find({last_activity:{\$gte:$start_date,\$lt:$end_date},referer:{\$nin:[/fjb./]}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/logged_in.temp
user_login=`cat $data_dir/logged_in.temp |sort |uniq |wc -l`

#4-user_give_reputation
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select whoadded from forum_reputation where dateline >= $start_date and dateline < $end_date;" > $data_dir/u1.temp
user_give_reputation=`cat $data_dir/u1.temp |sort |uniq |wc -l`

#5-user_give_vote
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select  userid from  forum_poll_vote where votedate >= $start_date and votedate < $end_date;" > $data_dir/u2.temp
user_give_vote=`cat $data_dir/u2.temp |sort |uniq |wc -l`

#3-voter
voter=`cat $data_dir/u1.temp $data_dir/u2.temp |sort |uniq |wc -l`

#7-user_subscribe_thread
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.subscribethread.find({forum_id:{\$in:[$all_forum]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0, userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g'  > $data_dir/st.temp
uniq_u_s_t=`cat $data_dir/st.temp |sort |uniq |wc -l`

#8-user_subscribe_forum
mongo 172.20.0.242/kaskus_forum1 -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.subscribeforum.find({forumid:{\$in:[$allforum]},_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0, userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/sf.temp
uniq_u_s_f=`cat $data_dir/sf.temp |sort |uniq |wc -l`

#9-user_add_friend,10-user_stalk
mongo 172.20.0.242/kaskus_friend_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_activity_log.find({processname: 'friend_invite', _id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/invite.temp
total_friend_invite=`cat $data_dir/invite.temp |sort |uniq |wc -l`
mongo 172.20.0.242/kaskus_friend_log -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_activity_log.find({processname: 'friend_friend', _id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/friend.temp
total_friend_friend=`cat $data_dir/friend.temp |sort |uniq |wc -l`
uniq_user_add_friend=`expr $total_friend_friend / 2 + $total_friend_invite`
mongo 172.20.0.242/kaskus_friend -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "rs.slaveOk();db.friend_follow.find({last_activity:{\$gte:$start_date,\$lte:$end_date}},{_id:0,followed_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g'  > $data_dir/stalk.temp
total_stalkfriend=`cat $data_dir/stalk.temp |sort |uniq |wc -l`
uniq_u_stalk_f=`expr $total_friend_friend / 2 + $total_stalkfriend`

#6-subscriber
susbcriber=`cat $data_dir/st.temp $data_dir/sf.temp $data_dir/invite.temp $data_dir/friend.temp $data_dir/stalk.temp  |sort |uniq |wc -l`

#12-posters
mongo 172.16.0.88:27018/kaskus_forum -uriamande -pchopinnocturne92 --authenticationDatabase=admin --eval "db.thread.find({forum_id:{\$in:[$all_forum]},dateline:{\$gte:$start_date,\$lt:$end_date}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's/[^0-9]*//g' > $data_dir/total_tred.temp
posters=`cat $data_dir/total_tred.temp |wc -l`

#11-commenters
rm $data_dir/mypost.temp
for i in `seq 0 499`
do
mongoexport -h 172.20.0.156 -uriamande -pchopinnocturne92 --authenticationDatabase=admin -d kaskus_forum1 -c mypost_$i -f post_userid --type=csv -q "{'forum_id':{\$in:[$allforum]}, _id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}}" -o $data_dir/post.csv
cat $data_dir/post.csv |grep -v 'post_userid' >> $data_dir/mypost.temp
done
comment=`cat $data_dir/mypost.temp |sort |uniq |wc -l` 

echo '"'$date_name'","'$user_login'","'$voter'","'$user_give_reputation'","'$user_give_vote'","'$susbcriber'","'$uniq_u_s_t'","'$uniq_u_s_f'","'$uniq_user_add_friend'","'$uniq_u_stalk_f'","'$comment'","'$posters'"' >> $data_dir/$file_naming".csv"
done

cat $data_dir/$file_naming".csv"  |grep -v '"tanggal","total user login","voter","user_give_reputation","user_give_vote","subscriber","user_subscribe_thread","user_subscribe_forum ","user_add_friend","user_stalk","commenters","posters"' > $data_dir/forum_user_weekly.csv

#create table forum_user_weekly (date_created date primary key, user_login int(11),voter int(11), user_give_reputation int(11), user_give_vote int(11), susbcriber int(11), subscribe_thread int(11),subscribe_forum int(11),add_friend int(11),stalk int(11),comment int(11),posters int(11));
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/forum_user_weekly.csv ;

bq load kaskus_reporting.forum_user_weekly  /home/rully/kpi_report/forum_funnel/forum_user_weekly.csv date_created:date,user_login:integer,voter:integer,user_give_reputation:integer,user_give_vote:integer,susbcriber:integer,subscribe_thread:integer,subscribe_forum:integer,add_friend:integer,stalk:integer,comment:integer,posters:integer
#bq load kaskus_reporting.forum_user_weekly $data_dir/forum_user_weekly.csv
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[WEEKLY] WEEKLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[WEEKLY] WEEKLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

