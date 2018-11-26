MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
echo "Judul Thread_Link Thread_Date Created_Date HT_Total Views_Total Views HT_Total Replies_Total Replies HT_Total Replies HT 1 Week_Total Replies HT 2 Weeks_Total Replies HT 30 Days_Total Share FB_Total Share GPlus_Total Share Twitter_Avg Star Rating_Total Rate-r" > list_ht_jan_mar.csv
for i in `mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select id,thread_id from hot_thread_statistic where dateline > '2015-01-01 00:00:00' and dateline < '2015-04-01 00:00:00';" |sed -e 's$\t$_$g'`
do
id=`echo $i |cut -d'_' -f1`
threadid=`echo $i |cut -d'_' -f2`
judul=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select original_title from hot_thread_statistic where id=$id;"`
replies_ht=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select replies from hot_thread_statistic where id=$id;"`
view_ht=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select view from hot_thread_statistic where id=$id;"`
linkthread="http://www.kaskus.co.id/thread/$threadid"
created_date=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,dateline:1}).forEach(printjson)" |grep dateline |sed 's/[^0-9]*//g'`
created_date=`date -d @$created_date "+%Y-%m-%d %H:%M:%S"`
date_ht=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select dateline from hot_thread_statistic where id = $id;"`
#date_ht=`echo $i |cut -d'_' -f5`
date_ts=`date -d "$date_ht" +%s`
date1w=`expr $date_ts + 604800`
date2w=`expr $date_ts + 1209600`
date1m=`expr $date_ts + 2592000`
total_views=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,views:1}).forEach(printjson)" |grep views |sed 's/[^0-9]*//g'`
reply_count=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,reply_count:1}).forEach(printjson)" |grep reply_count |sed 's/[^0-9]*//g'`
mongo kaskus_forum1 --eval "db.post.count({thread_id:'$threadid',dateline:{\$gte:$date_ts,\$lte:$date1w}})" |grep -v MongoDB |grep -v connecting > reply_1w.log
mongo kaskus_forum1 --eval "db.post.count({thread_id:'$threadid',dateline:{\$gte:$date_ts,\$lte:$date2w}})" |grep -v MongoDB |grep -v connecting > reply_2w.log
mongo kaskus_forum1 --eval "db.post.count({thread_id:'$threadid',dateline:{\$gte:$date_ts,\$lte:$date1m}})" |grep -v MongoDB |grep -v connecting > reply_1m.log
reply_1w=`cat reply_1w.log`
reply_2w=`cat reply_2w.log`
reply_1m=`cat reply_1m.log`
share_fb=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,socialMediacounter:1}).forEach(printjson)" |grep share_fb |sed 's/[^0-9]*//g'`
share_gplus=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,socialMediacounter:1}).forEach(printjson)" |grep share_gplus |sed 's/[^0-9]*//g'`
share_twitter=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,socialMediacounter:1}).forEach(printjson)" |grep share_twitter |sed 's/[^0-9]*//g'`
vote_ttl=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,vote_total:1}).forEach(printjson)" |grep vote_total |sed 's/[^0-9]*//g'`
vote_num=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('$threadid')},{_id:0,vote_num:1}).forEach(printjson)" |grep vote_num |sed 's/[^0-9]*//g'`
vote_avg=`echo "scale=1; $vote_ttl/$vote_num"|bc`
echo $judul'_'$linkthread'_'$created_date'_'$date_ht'_'$total_views'_'$view_ht'_'$reply_count'_'$replies_ht'_'$reply_1w'_'$reply_2w'_'$reply_1m'_'$share_fb'_'$share_gplus'_'$share_twitter'_'$vote_avg'_'$vote_num >> list_ht_jan_mar.csv
done
