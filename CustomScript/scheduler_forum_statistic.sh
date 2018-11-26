MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
datadir="/home/rully/kpi_report"
start_date=`date -d "-1 month" +%Y%m01`
#start_date=20171001
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
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 user -s -N -e "select userid from userinfo where usergroupid in (5,7,24) order by userid asc;" > $datadir/temp_moderator.txt
> $datadir/temp_loginmod.temp
> $datadir/temp_monthly_reply.temp
for i in `seq 1 $day_count`
do
day_start=`date -d "$start_date + $i day - 1 day" +%s`
day_end=`date -d "$start_date + $i day" +%s`
day_onfile=`date -d@$day_start +%m/%d/%Y`
OID_START=`mongo --eval "Math.floor($day_start).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($day_end).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
### daily userlogin ###
/opt/mongodb_3.0.10/bin/mongo 172.20.0.91/kaskus_user_log -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.userloginlog.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},referer:{\$nin:[/fjb./]}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 |sort |uniq > $datadir/temp_forum1.temp
total_1=`cat $datadir/temp_forum1.temp |wc -l`
### daily voters ###
# reputation
total_21=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select count(distinct whoadded) from forum_reputation where dateline>=$day_start and dateline<$day_end;"`
total_22=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select count(*) from forum_reputation where dateline>=$day_start and dateline<$day_end;"`
# polling
total_23=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select count(distinct userid) from forum_poll_vote where votedate>=$day_start and votedate<$day_end;"`
total_24=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select count(*) from forum_poll_vote where votedate>=$day_start and votedate<$day_end;"`
### daily subscribers ###
# forum
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.subscribeforum.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum31.temp
total_31=`cat $datadir/temp_forum31.temp |sort |uniq |wc -l`
total_32=`cat $datadir/temp_forum31.temp |wc -l`
# thread
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.subscribethread.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum32.temp
total_33=`cat $datadir/temp_forum32.temp |sort |uniq |wc -l`
total_34=`cat $datadir/temp_forum32.temp |wc -l`
# friends
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_friend -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.friend_friends.find({since:{\$gte:$day_start,\$lt:$day_end}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/temp_forum33.temp
total_35=`cat $datadir/temp_forum33.temp |sort |uniq |wc -l`
total_36=`cat $datadir/temp_forum33.temp |wc -l`
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
cat $datadir/temp_forum4.temp >> $datadir/temp_monthly_reply.temp
done
total_41=$counter_user
total_42=$counter_post
### daily moderator ###
cat $datadir/temp_moderator.txt |sort |uniq |diff -u $datadir/temp_forum1.temp - |grep -v '\+\|\-' >> $datadir/temp_loginmod.temp
### export to file ###
echo '"'$day_onfile'","'$total_1'"' >> $datadir/active_user_"$date_naming".csv
echo '"'$day_onfile'","'$total_21'","'$total_22'","give reputation"' >> $datadir/active_voters_"$date_naming".csv
echo '"'$day_onfile'","'$total_23'","'$total_24'","give polling"' >> $datadir/active_voters_"$date_naming".csv
echo '"'$day_onfile'","'$total_31'","'$total_32'","subscribe forum"' >> $datadir/active_subscribers_"$date_naming".csv
echo '"'$day_onfile'","'$total_33'","'$total_34'","subscribe thread"' >> $datadir/active_subscribers_"$date_naming".csv
echo '"'$day_onfile'","'$total_35'","'$total_36'","add friend"' >> $datadir/active_subscribers_"$date_naming".csv
echo '"'$day_onfile'","'$total_41'","'$total_42'"' >> $datadir/active_commenters_"$date_naming".csv
done
### monthly login ###
/opt/mongodb_3.0.10/bin/mongo 172.20.0.91/kaskus_user_log -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.userloginlog.find({_id:{\$gte:ObjectId('$OID_START_MONTH'),\$lt:ObjectId('$OID_END_MONTH')},referer:{\$nin:[/fjb./]}},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 |sort |uniq |wc -l > $datadir/temp_forummonth1.temp
total_month1=`cat $datadir/temp_forummonth1.temp`
### monthly voters ###
# reputation
total_month21=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select count(distinct whoadded) from forum_reputation where dateline>=$month_start and dateline<$month_end;"`
# polling
total_month22=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -r -s -N -e "select count(distinct userid) from forum_poll_vote where votedate>=$month_start and votedate<$month_end;"`
### monthly subscribers ###
# forum
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.subscribeforum.find({_id:{\$gte:ObjectId('$OID_START_MONTH'),\$lt:ObjectId('$OID_END_MONTH')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sort |uniq |wc -l > $datadir/temp_forummonth21.temp
total_month31=`cat $datadir/temp_forummonth21.temp`
# thread
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.subscribethread.find({_id:{\$gte:ObjectId('$OID_START_MONTH'),\$lt:ObjectId('$OID_END_MONTH')},is_fjb:0},{_id:0,userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sort |uniq |wc -l > $datadir/temp_forummonth22.temp
total_month32=`cat $datadir/temp_forummonth22.temp`
# friends
/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_friend -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.friend_friends.find({since:{\$gte:$month_start,\$lt:$month_end}},{_id:0,user_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sort |uniq |wc -l > $datadir/temp_forummonth23.temp
total_month33=`cat $datadir/temp_forummonth23.temp`
### monthly post reply ###
total_month4=`cat $datadir/temp_monthly_reply.temp |sort |uniq |wc -l`
### monthly thread creator ###
mysql -h 172.20.0.159 -ubackup -pkaskus -e "truncate temp_monthlyforum;"
/opt/mongodb_3.0.10/bin/mongoexport -h 127.0.0.1 --port 27018 -d kaskus_forum -c thread -uforumshardrw -pG5NVEI5WkLFgGTB1 --authenticationDatabase=kaskus_forum -q "{forum_id:{\$nin:[$forum_id]},visible:1,dateline:{\$gte:$month_start,\$lt:$month_end}}" --fields dateline,post_username,forum_id --type=csv -o $datadir/temp_monthlyforum.csv
sed -i '/dateline,post_username,forum_id/d' $datadir/temp_monthlyforum.csv
mysqlimport -h 172.20.0.159 -ubackup -pkaskus --local --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" test $datadir/temp_monthlyforum.csv
mysql -h 172.20.0.159 -ubackup -pkaskus test -r -s -N -e "select from_unixtime(dateline,'%m/%d/%Y') dateline,post_username,replace(name,'\n','\\n') name from temp_monthlyforum a,forum_list b where a.forum_id=b.forum_id;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $datadir/active_poster_"$date_naming".csv
gzip $datadir/active_poster_"$date_naming".csv
total_month5=`cat $datadir/temp_monthlyforum.csv |cut -d ',' -f2 |sort |uniq |wc -l`
### monthly moderator ###
total_month6=`cat $datadir/temp_loginmod.temp |sed 's@ @@g' |sort |uniq |wc -l`
### export to file ###
echo '"monthly active user","'$total_month1'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly voters reputation","'$total_month21'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly voters polling","'$total_month22'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly subscribers forum","'$total_month31'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly subscribers thread","'$total_month32'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly subscribers friends","'$total_month33'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly commenters","'$total_month4'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly posters","'$total_month5'"' >> $datadir/monthly_summary_"$date_naming".csv
echo '"monthly active moderator","'$total_month6'"' >> $datadir/monthly_summary_"$date_naming".csv
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,antonia.kalisa@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,fauzan.ramadhanu@kaskusnetworks.com,seno@kaskusnetworks.com,ronald.seng@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/monthly_summary_"$date_naming".csv $datadir/active_user_"$date_naming".csv $datadir/active_voters_"$date_naming".csv $datadir/active_subscribers_"$date_naming".csv $datadir/active_commenters_"$date_naming".csv $datadir/active_poster_"$date_naming".csv.gz -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM PER $date_naming \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/monthly_summary_"$date_naming".csv $datadir/active_user_"$date_naming".csv $datadir/active_voters_"$date_naming".csv $datadir/active_subscribers_"$date_naming".csv $datadir/active_commenters_"$date_naming".csv $datadir/active_poster_"$date_naming".csv.gz -o tls=no -s 103.6.117.20 > /dev/null  2>&1
