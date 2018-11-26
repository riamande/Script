WS="172.16.0.88"
PORT="27018"
DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_START_STR=$(env TZ=Asia/Jakarta date -d "1 day ago" +'%Y%m%d')
DATA_PATH="/home/rully/data_thread_share"
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"



FJB_ID=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`

/opt/mongodb_3.0.10/bin/mongo $WS:$PORT/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "printjson(db.thread.aggregate([{\$match:{forum_id:{\$nin:[$FJB_ID]}}},{\$group:{_id:null,fb:{\$sum:'\$socialMediacounter.share_fb'},gplus:{\$sum:'\$socialMediacounter.share_gplus'},twiiter:{\$sum:'\$socialMediacounter.share_twitter'},total:{\$sum:1}}}]))" |grep -v 'MongoDB shell version:\|connecting to:' > $DATA_PATH/temp_forumshare.txt
/opt/mongodb_3.0.10/bin/mongo $WS:$PORT/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "printjson(db.thread.aggregate([{\$match:{forum_id:{\$in:[$FJB_ID]}}},{\$group:{_id:null,fb:{\$sum:'\$socialMediacounter.share_fb'},gplus:{\$sum:'\$socialMediacounter.share_gplus'},twiiter:{\$sum:'\$socialMediacounter.share_twitter'},total:{\$sum:1}}}]))" |grep -v 'MongoDB shell version:\|connecting to:' > $DATA_PATH/temp_jbshare.txt

FB_FORUM=`cat $DATA_PATH/temp_forumshare.txt |grep '"fb"' |sed 's/[^0-9]*//g'`
FB_JB=`cat $DATA_PATH/temp_jbshare.txt |grep '"fb"' |sed 's/[^0-9]*//g'`

GPLUS_FORUM=`cat $DATA_PATH/temp_forumshare.txt |grep '"gplus"' |sed 's/[^0-9]*//g'`
GPLUS_JB=`cat $DATA_PATH/temp_jbshare.txt |grep '"gplus"' |sed 's/[^0-9]*//g'`

TWITTER_FORUM=`cat $DATA_PATH/temp_forumshare.txt |grep '"twiiter"' |sed 's/[^0-9]*//g'`
TWITTER_JB=`cat $DATA_PATH/temp_jbshare.txt |grep '"twiiter"' |sed 's/[^0-9]*//g'`

TOTAL_FORUM=`cat $DATA_PATH/temp_forumshare.txt |grep '"total"' |sed 's/[^0-9]*//g'`
TOTAL_JB=`cat $DATA_PATH/temp_jbshare.txt |grep '"total"' |sed 's/[^0-9]*//g'`

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.72 kaskus_statistic -e "insert into thread_share (type,title,total,date_str) values ('forum','fb','$FB_FORUM','$DATE_START_STR'),('forum','gplus','$GPLUS_FORUM','$DATE_START_STR'),('forum','twitter','$TWITTER_FORUM','$DATE_START_STR'),('forum','open','$TOTAL_FORUM','$DATE_START_STR');"
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.72 kaskus_statistic -e "insert into thread_share (type,title,total,date_str) values ('jb','fb','$FB_JB','$DATE_START_STR'),('jb','gplus','$GPLUS_JB','$DATE_START_STR'),('jb','twitter','$TWITTER_JB','$DATE_START_STR'),('jb','open','$TOTAL_JB','$DATE_START_STR');"

sendemail -f statistic@kaskusnetworks.com -t ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,seno@kaskusnetworks.com,zarona@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "[automated] DAILY THREAD SHARE HISTORY - $DATE_START_STR" -m "SHARE HISTORY $DATE_START_STR s/d $DATE_END_STR \n\n Details information : \n\n Forum \n Facebook Share : $FB_FORUM \n Gplus Share : $GPLUS_FORUM \n Twitter Share : $TWITTER_FORUM \n Total Open : $TOTAL_FORUM \n\n Jual Beli \n Facebook Share : $FB_JB \n Gplus Share : $GPLUS_JB \n Twitter Share : $TWITTER_JB \n Total Open : $TOTAL_JB \n\n\n\n Regards, \n DBA" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[automated] DAILY THREAD SHARE HISTORY - $DATE_START_STR" -m "SHARE HISTORY $DATE_START_STR s/d $DATE_END_STR \n\n Details information : \n\n Forum \n Facebook Share \t : $FB_FORUM \n Gplus Share \t : $GPLUS_FORUM \n Twitter Share \t : $TWITTER_FORUM \n Total Open \t : $TOTAL_FORUM \n\n Jual Beli \n Facebook Share \t : $FB_JB \n Gplus Share \t : $GPLUS_JB \n Twitter Share \t : $TWITTER_JB \n Total Open \\t : $TOTAL_JB \n\n\n\n Regards, \n DBA" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
