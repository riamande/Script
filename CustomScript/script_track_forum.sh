start_date=$1
end_date=$2
forumid=$3
ts_poster_count=$4

mongo kaskus_forum1 --eval "db.thread.count({forum_id:$forumid,dateline:{\$gte:$start_date,\$lte:$end_date}})" |grep -v Mongo |grep -v connect > count_temp_thread_$forumid
total_thread=`cat count_temp_thread_$forumid`
mongo kaskus_forum1 --eval "db.thread.find({forum_id:$forumid},{_id:1}).forEach(printjson)" |grep -v Mongo |grep -v connect |cut -d'"' -f4 > threadid_$forumid
mongo kaskus_forum1 --eval "db.thread.find({forum_id:$forumid,dateline:{\$gte:$start_date,\$lte:$end_date}},{_id:1}).forEach(printjson)" |grep -v Mongo |grep -v connect |cut -d'"' -f4 > threadid_1m_$forumid

if [ "$ts_poster_count" = "y" ]
then
for i in `cat threadid_$forumid`
do
mongo kaskus_forum1 --eval "db.post.find({thread_id:'$i'},{post_userid:1,_id:0}).forEach(printjson)" |grep -v Mongo |grep -v connect >> counter_reply_$forumid
done
total_poster=`cat counter_reply_$forumid |sort |uniq |wc -l`
total_ts=`mongo kaskus_forum1 --eval "db.thread.find({forum_id:$forumid},{post_userid:1,_id:0}).forEach(printjson)" |grep -v Mongo |grep -v connect |sort |uniq |wc -l`
fi

for i in `cat threadid_$forumid`
do
mongo kaskus_forum1 --eval "db.post.count({thread_id:'$i',dateline:{\$gte:$start_date,\$lte:$end_date}})" |grep -v Mongo |grep -v connect > count_temp_$forumid
a=`cat count_temp_$forumid`
total_reply_month=`expr $total_reply_month + $a`
done
echo "Total TS = $total_ts"
echo "Total Poster = $total_poster"
echo "Total Thread = $total_thread"
echo "Total Reply = $total_reply_month"
