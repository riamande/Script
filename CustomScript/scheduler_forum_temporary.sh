datadir="/home/rully/kpi_report/forum_custom/custom"
echo '"month","number of login","total registered users","total sign up"' > $datadir/users.csv
echo '"month","Unique User Voters","Unique User Give Reputation","User give Vote/Poll"' > $datadir/voters.csv
echo '"month","Unique User Subscribers","Unique User Subscribe Forum","Unique User Subscribe Thread","Unique User Add Friend","Unique User Stalk Friend"' > $datadir/subscribers.csv 
echo '"month","Unique User Commenters","Total Replies"' > $datadir/commenters.csv
echo '"month","Unique User Thread Starter","Total Threads Approved All","Total Threads Approved Partner","Total Threads Unapproved etc"' > $datadir/posters.csv
datestart=20140101
while [ $datestart -lt 20171101 ]
do
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
#datadir="/home/rully/kpi_report/forum_custom/custom"
#start_date=`date -d "-1 month" +%Y%m01`
##start_date=`date -d "$month_looper/1" +%Y%m%d`
start_date=$datestart
month_start=`date -d "$start_date" +%s`
month_end=`date -d "$start_date + 1 month" +%s`
#month_end=1508086800
day_count=`date -d "$start_date + 1 month - 1 day" +%d`
#day_count=15
date_naming=`date -d@$month_start +%Y%m`
OID_START_MONTH=`mongo --eval "Math.floor($month_start).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END_MONTH=`mongo --eval "Math.floor($month_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g' |sed "s@,@','@g;s@^@'@g;s/\$/'/g"`
forum_id=`echo $fjb_id |sed "s@'@@g"`
###
day_start=$month_start
day_end=$month_end
day_onfile=`date -d@$day_start +%m/%Y`
OID_START=$OID_START_MONTH
OID_END=$OID_END_MONTH
### daily userlogin ###
mongo 172.20.0.91/kaskus_user_log --eval "rs.slaveOk();db.userloginlog.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},referer:{\$nin:[/fjb./]}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum1.temp
total_1=`cat $datadir/temp_forum1.temp |cut -d '"' -f4 |sort |uniq |wc -l`
total_11=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 user -r -s -N -e "select count(*) from userinfo where joindate<$day_end and usergroupid not in (1,3);"`
total_12=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 user -r -s -N -e "select count(*) from userinfo where joindate>=$day_start and joindate<$day_end and usergroupid not in (1,3);"`
### daily voters ###
# reputation
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select distinct(whoadded) from forum_reputation where dateline>=$day_start and dateline<$day_end;" > $datadir/temp_forum21.temp
total_21=`cat $datadir/temp_forum21.temp |wc -l`
# polling
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select distinct(userid) from forum_poll_vote where votedate>=$day_start and votedate<$day_end;" > $datadir/temp_forum22.temp
total_22=`cat $datadir/temp_forum22.temp |wc -l`
# Unique User Voters
total_2=`cat $datadir/temp_forum21.temp $datadir/temp_forum22.temp |sort |uniq |wc -l`
### daily subscribers ###
# forum
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.subscribeforum.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum31.temp
total_31=`cat $datadir/temp_forum31.temp |sort |uniq |wc -l`
# thread
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.subscribethread.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum32.temp
total_32=`cat $datadir/temp_forum32.temp |sort |uniq |wc -l`
# friends
mongo 172.20.0.242/kaskus_friend_log --eval "rs.slaveOk();db.friend_activity_log.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},processname : 'friend_invite'},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum33.temp
total_33=`cat $datadir/temp_forum33.temp |sort |uniq |wc -l`
# follow friends
mongo 172.20.0.242/kaskus_friend_log --eval "rs.slaveOk();db.friend_activity_log.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},processname : 'friend_follow'},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum34.temp
total_34=`cat $datadir/temp_forum34.temp |sort |uniq |wc -l`
# unique User Subscribers
total_3=`cat $datadir/temp_forum31.temp $datadir/temp_forum32.temp $datadir/temp_forum33.temp $datadir/temp_forum34.temp |sort |uniq |wc -l`
### daily post reply ###
counter_post=0
counter_user=0
for modulus_post in `seq 0 499`
do
mongo 172.20.0.158/kaskus_forum1 --eval "rs.slaveOk();db.mypost_$modulus_post.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},forum_id:{\$nin:[$fjb_id]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum4.temp
temp_part1=`cat $datadir/temp_forum4.temp |sort |uniq |wc -l`
temp_part2=`cat $datadir/temp_forum4.temp |wc -l`
counter_user=`expr $counter_user + $temp_part1`
counter_post=`expr $counter_post + $temp_part2`
done
total_41=$counter_user
total_42=$counter_post
### daily thread creator ###
# thread approved all
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$forum_id]},visible:1,dateline:{\$gte:$day_start,\$lt:$day_end}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum51.temp
total_51=`cat $datadir/temp_forum51.temp |wc -l`
# thread approved partner
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$forum_id]},visible:1,dateline:{\$gte:$day_start,\$lt:$day_end},post_userid:{\$in:['8296201','9250512','9682662','4203448','8490746','9568276','9344125','9931398']}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum52.temp
total_52=`cat $datadir/temp_forum52.temp |wc -l`
# thread unapproved etc
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$forum_id]},visible:{\$nin:[1]},dateline:{\$gte:$day_start,\$lt:$day_end}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum53.temp
cat $datadir/temp_forum53.temp >> $datadir/temp_forum53_month.temp
total_53=`cat $datadir/temp_forum53.temp |wc -l`
# Unique User Thread Starter
total_5=`cat $datadir/temp_forum51.temp $datadir/temp_forum53.temp |sort |uniq |wc -l`
### export to file ###
echo '"'$day_onfile'","'$total_1'","'$total_11'","'$total_12'"' >> $datadir/users.csv
echo '"'$day_onfile'","'$total_2'","'$total_21'","'$total_22'"' >> $datadir/voters.csv
echo '"'$day_onfile'","'$total_3'","'$total_31'","'$total_32'","'$total_33'","'$total_34'"' >> $datadir/subscribers.csv
echo '"'$day_onfile'","'$total_41'","'$total_42'"' >> $datadir/commenters.csv
echo '"'$day_onfile'","'$total_5'","'$total_51'","'$total_52'","'$total_53'"' >> $datadir/posters.csv
datestart=`date -d "$datestart + 1 month" +%Y%m%d`
done
