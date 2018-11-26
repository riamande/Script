#datadir="/home/rully/kpi_report"
#echo '"month","Unique User Voters","Unique User Give Reputation","User give Vote/Poll"' > $datadir/voters_2017.csv
#echo '"month","Unique User Subscribers","Unique User Subscribe Forum","Unique User Subscribe Thread","Unique User Add Friend","Unique User Stalk Friend"' > $datadir/subscribers_2017.csv 
#echo '"month","Unique User Commenters","Total Replies"' > $datadir/commenters_2017.csv
#echo '"month","Unique User Thread Starter","Total Threads Approved All","Total Threads Approved Partner","Total Threads Unapproved etc"' > $datadir/posters_2017.csv
#for month_looper in `seq 1 9`
#do
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
datadir="/home/rully/kpi_report/forum_custom"
start_date=`date +%Y%m01`
##start_date=`date -d "$month_looper/1" +%Y%m%d`
#start_date=20171001
month_start=`date -d "$start_date" +%s`
month_end=`date -d "$start_date + 14 day" +%s`
#month_end=1508086800
day_count=`date -d@$month_end +%d`
#day_count=15
date_naming=`date -d@$month_start +%Y%m`
OID_START_MONTH=`mongo --eval "Math.floor($month_start).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END_MONTH=`mongo --eval "Math.floor($month_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g' |sed "s@,@','@g;s@^@'@g;s/\$/'/g"`
forum_id=`echo $fjb_id |sed "s@'@@g"`
### initial file temp month
> $datadir/temp_forum1_month.temp # initial file for userlogin
> $datadir/temp_forum21_month.temp # initial file for reputation
> $datadir/temp_forum22_month.temp # initial file for polling
> $datadir/temp_forum31_month.temp # initial file for subscriber forum
> $datadir/temp_forum32_month.temp # initial file for subscriber thread
> $datadir/temp_forum33_month.temp # initial file for add friends
> $datadir/temp_forum34_month.temp # initial file for stalk friends
> $datadir/temp_forum4_month.temp # initial file for replies
> $datadir/temp_forum51_month.temp # initial file for thread approved all
> $datadir/temp_forum52_month.temp # initial file for thread approved partner
> $datadir/temp_forum53_month.temp # initial file for thread unapproved etc
echo '"date","Unique User Voters","Unique User Give Reputation","User give Vote/Poll"' > $datadir/voters_"$date_naming".csv
echo '"date","Unique User Subscribers","Unique User Subscribe Forum","Unique User Subscribe Thread","Unique User Add Friend","Unique User Stalk Friend"' > $datadir/subscribers_"$date_naming".csv 
echo '"date","Unique User Commenters","Total Replies"' > $datadir/commenters_"$date_naming".csv
echo '"date","Unique User Thread Starter","Total Threads Approved All","Total Threads Approved Partner","Total Threads Unapproved etc"' > $datadir/posters_"$date_naming".csv
###
for i in `seq 1 $day_count`
do
day_start=`date -d "$start_date + $i day - 1 day" +%s`
day_end=`date -d "$start_date + $i day" +%s`
day_onfile=`date -d@$day_start +%m/%d/%Y`
OID_START=`mongo --eval "Math.floor($day_start).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($day_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
### daily userlogin ###
/opt/mongodb_3.0.10/bin/mongo 172.20.0.91/kaskus_user_log -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.userloginlog.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},referer:{\$nin:[/fjb./]}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 |sort |uniq > $datadir/temp_forum1.temp
cat $datadir/temp_forum1.temp >> $datadir/temp_forum1_month.temp
total_1=`cat $datadir/temp_forum1.temp |wc -l`
### daily voters ###
# reputation
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select distinct(whoadded) from forum_reputation where dateline>=$day_start and dateline<$day_end;" > $datadir/temp_forum21.temp
cat $datadir/temp_forum21.temp >> $datadir/temp_forum21_month.temp
total_21=`cat $datadir/temp_forum21.temp |wc -l`
# polling
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select distinct(userid) from forum_poll_vote where votedate>=$day_start and votedate<$day_end;" > $datadir/temp_forum22.temp
cat $datadir/temp_forum22.temp >> $datadir/temp_forum22_month.temp
total_22=`cat $datadir/temp_forum22.temp |wc -l`
# Unique User Voters
total_2=`cat $datadir/temp_forum21.temp $datadir/temp_forum22.temp |sort |uniq |wc -l`
### daily subscribers ###
# forum
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.subscribeforum.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum31.temp
cat $datadir/temp_forum31.temp >> $datadir/temp_forum31_month.temp
total_31=`cat $datadir/temp_forum31.temp |sort |uniq |wc -l`
# thread
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.subscribethread.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum32.temp
cat $datadir/temp_forum32.temp >> $datadir/temp_forum32_month.temp
total_32=`cat $datadir/temp_forum32.temp |sort |uniq |wc -l`
# friends
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_friend_log -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.friend_activity_log.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},processname : 'friend_invite'},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum33.temp
cat $datadir/temp_forum33.temp >> $datadir/temp_forum33_month.temp
total_33=`cat $datadir/temp_forum33.temp |sort |uniq |wc -l`
# follow friends
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_friend_log -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.friend_activity_log.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},processname : 'friend_follow'},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum34.temp
cat $datadir/temp_forum34.temp >> $datadir/temp_forum34_month.temp
total_34=`cat $datadir/temp_forum34.temp |sort |uniq |wc -l`
# unique User Subscribers
total_3=`cat $datadir/temp_forum31.temp $datadir/temp_forum32.temp $datadir/temp_forum33.temp $datadir/temp_forum34.temp |sort |uniq |wc -l`
### daily post reply ###
counter_post=0
counter_user=0
for modulus_post in `seq 0 499`
do
/opt/mongodb_3.0.10/bin/mongo 172.20.0.156/kaskus_forum1 -ukkreplrw4 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.mypost_$modulus_post.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},forum_id:{\$nin:[$fjb_id]}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum4.temp
temp_part1=`cat $datadir/temp_forum4.temp |sort |uniq |wc -l`
temp_part2=`cat $datadir/temp_forum4.temp |wc -l`
counter_user=`expr $counter_user + $temp_part1`
counter_post=`expr $counter_post + $temp_part2`
cat $datadir/temp_forum4.temp >> $datadir/temp_forum4_month.temp
done
total_41=$counter_user
total_42=$counter_post
### daily thread creator ###
# thread approved all
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$forum_id]},visible:1,dateline:{\$gte:$day_start,\$lt:$day_end}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum51.temp
cat $datadir/temp_forum51.temp >> $datadir/temp_forum51_month.temp
total_51=`cat $datadir/temp_forum51.temp |wc -l`
# thread approved partner
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$forum_id]},visible:1,dateline:{\$gte:$day_start,\$lt:$day_end},post_userid:{\$in:['8296201','9250512','9682662','4203448','8490746','9568276','9344125','9931398']}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum52.temp
cat $datadir/temp_forum52.temp >> $datadir/temp_forum52_month.temp
total_52=`cat $datadir/temp_forum52.temp |wc -l`
# thread unapproved etc
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:{\$nin:[$forum_id]},visible:{\$nin:[1]},dateline:{\$gte:$day_start,\$lt:$day_end}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum53.temp
cat $datadir/temp_forum53.temp >> $datadir/temp_forum53_month.temp
total_53=`cat $datadir/temp_forum53.temp |wc -l`
# Unique User Thread Starter
total_5=`cat $datadir/temp_forum51.temp $datadir/temp_forum53.temp |sort |uniq |wc -l`
### export to file ###
echo '"'$day_onfile'","'$total_2'","'$total_21'","'$total_22'"' >> $datadir/voters_"$date_naming".csv
echo '"'$day_onfile'","'$total_3'","'$total_31'","'$total_32'","'$total_33'","'$total_34'"' >> $datadir/subscribers_"$date_naming".csv
echo '"'$day_onfile'","'$total_41'","'$total_42'"' >> $datadir/commenters_"$date_naming".csv
echo '"'$day_onfile'","'$total_5'","'$total_51'","'$total_52'","'$total_53'"' >> $datadir/posters_"$date_naming".csv
done
### monthly login ###
total_month1=`cat $datadir/temp_forum1_month.temp |sort |uniq |wc -l`
### monthly voters ###
# reputation
total_month21=`cat $datadir/temp_forum21_month.temp |sort |uniq |wc -l`
# polling
total_month22=`cat $datadir/temp_forum22_month.temp |sort |uniq |wc -l`
# Unique User Voters
total_month2=`cat $datadir/temp_forum21_month.temp $datadir/temp_forum22_month.temp |sort |uniq |wc -l`
### monthly subscribers ###
# forum
total_month31=`cat $datadir/temp_forum31_month.temp |sort |uniq |wc -l`
# thread
total_month32=`cat $datadir/temp_forum32_month.temp |sort |uniq |wc -l`
# friends
total_month33=`cat $datadir/temp_forum33_month.temp |sort |uniq |wc -l`
# follow friends
total_month34=`cat $datadir/temp_forum34_month.temp |sort |uniq |wc -l`
# Unique User Subscribers
total_month3=`cat $datadir/temp_forum31_month.temp $datadir/temp_forum32_month.temp $datadir/temp_forum33_month.temp $datadir/temp_forum34_month.temp |sort |uniq |wc -l`
### monthly post reply ###
# Unique User Commenters
total_month41=`cat $datadir/temp_forum4_month.temp |sort |uniq |wc -l`
# Total Replies
total_month42=`cat $datadir/temp_forum4_month.temp |wc -l`
### monthly thread creator ###
# Total Threads Approved All
total_month51=`cat $datadir/temp_forum51_month.temp |wc -l`
# Total Threads Approved Partner
total_month52=`cat $datadir/temp_forum52_month.temp |wc -l`
# Total Threads Unapproved etc
total_month53=`cat $datadir/temp_forum53_month.temp |wc -l`
# Unique User Thread Starter
total_month5=`cat $datadir/temp_forum51_month.temp $datadir/temp_forum53_month.temp |sort |uniq |wc -l`
### export to file ###
echo '"'$date_naming'","'$total_month2'","'$total_month21'","'$total_month22'"' >> $datadir/voters_"$date_naming".csv
echo '"'$date_naming'","'$total_month3'","'$total_month31'","'$total_month32'","'$total_month33'","'$total_month34'"' >> $datadir/subscribers_"$date_naming".csv
echo '"'$date_naming'","'$total_month41'","'$total_month42'"' >> $datadir/commenters_"$date_naming".csv
echo '"'$date_naming'","'$total_month5'","'$total_month51'","'$total_month52'","'$total_month53'"' >> $datadir/posters_"$date_naming".csv
#done
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,antonia.kalisa@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,fauzan.ramadhanu@kaskusnetworks.com,seno@kaskusnetworks.com,ronald.seng@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/monthly_summary_"$date_naming".csv $datadir/active_user_"$date_naming".csv $datadir/active_voters_"$date_naming".csv $datadir/active_subscribers_"$date_naming".csv $datadir/active_commenters_"$date_naming".csv $datadir/active_poster_"$date_naming".csv.gz -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/monthly_summary_"$date_naming".csv $datadir/active_user_"$date_naming".csv $datadir/active_voters_"$date_naming".csv $datadir/active_subscribers_"$date_naming".csv $datadir/active_commenters_"$date_naming".csv $datadir/active_poster_"$date_naming".csv.gz -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,antonia.kalisa@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,fauzan.ramadhanu@kaskusnetworks.com,seno@kaskusnetworks.com,ronald.seng@kaskusnetworks.com -u "HALF-MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/voters_"$date_naming".csv $datadir/subscribers_"$date_naming".csv $datadir/commenters_"$date_naming".csv $datadir/posters_"$date_naming".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
