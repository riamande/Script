MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
HOST_PXC_READ="172.20.0.73"
HOST_PXC_WRITE="172.20.0.71"
HOST_BACKUP="172.20.0.159"
WS_IP="172.16.0.88"
WS_PORT="27018"
#DATE_END_STR="$1"
DATE_END_STR=`date +%Y%m%d`
DATE_START_TS=`date -d"$DATE_END_STR - 1 day" +%s`
DATE_START_STR=`date -d@$DATE_START_TS +"%Y-%m-%d"`
DATE_END_TS=`date -d"$DATE_END_STR" +%s`
DAY_NOW=`date -d "$DATE_END_STR" +%d`
DATE_FILE=`date -d@$DATE_START_TS +%m%Y`
DATE_QUERY=`date -d@$DATE_START_TS +"%Y-%m-01"`
DATADIR="/home/rully/forum_report/daily"
DATABQ="/home/rully/bigquery"
DATADIR_MONTH="/home/rully/forum_report/monthly"
FORUM_ID=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h $HOST_PXC_READ forum -s -N -e "select child_list from forum_list where forum_id in (241,72);" |sed -e ':a;N;$!ba;s/\n/,/g;s$\,\-1$$g'`
MYPOST_FORUM_ID=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h $HOST_PXC_READ forum -s -N -e "select child_list from forum_list where forum_id in (241,72);" |sed -e ':a;N;$!ba;s/\n/,/g;s$\,\-1$$g' |sed "s@,@','@g;s@^@'@g;s@\\\$@'@g"`
OID_START=`mongo $WS_IP:$WS_PORT/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "Math.floor($DATE_START_TS).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo $WS_IP:$WS_PORT/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "Math.floor($DATE_END_TS).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`

## TOTAL REPLIES & UNIQ
> $DATADIR/forum_replies.temp
for mod_mypost in `seq 0 499`
do
mongoexport -h 172.20.0.156 -urootdbreplicaset -pRootDBReplicaSetKK2017 --authenticationDatabase=admin -d kaskus_forum1 -c mypost_$mod_mypost --type=csv -f forum_id,post_userid -q "{_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},forum_id:{\$in:[$MYPOST_FORUM_ID]}}" -o $DATADIR/temp_reply.temp
cat $DATADIR/temp_reply.temp >> $DATADIR/forum_replies.temp
done
## FOR MONTHLY
cat $DATADIR/forum_replies.temp >> $DATADIR_MONTH/temp_replies.temp
#############################

## TOTAL THREAD & UNIQ USER
mongoexport -h $WS_IP:$WS_PORT -uforumshardrw -pG5NVEI5WkLFgGTB1 --authenticationDatabase=kaskus_forum -d kaskus_forum -c thread --type=csv -f forum_id,post_userid -q "{_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},forum_id:{\$in:[$FORUM_ID]}}" -o $DATADIR/temp_thread.temp
## FOR MONTHLY
cat $DATADIR/temp_thread.temp >> $DATADIR_MONTH/temp_thread.temp

for i in `echo $FORUM_ID |sed 's@,@ @g'`
do

## TOTAL SHARE THREAD
mongo 172.16.0.88:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.aggregate([{\$match:{forum_id:$i}},{\$group:{_id:null,fb:{\$sum:'\$socialMediacounter.share_fb'},gplus:{\$sum:'\$socialMediacounter.share_gplus'},twitter:{\$sum:'\$socialMediacounter.share_twitter'},total_thread_judul_biar_panjang_buat_mecah_new_line:{\$sum:1}}}]).forEach(printjson)" |grep -v 'MongoDB shell\|connecting' > $DATADIR/temp_share.temp
#############################

## COMPUTING THE NUMBERS
REPORTDATE=`date -d@$DATE_START_TS +"%Y-%m-%d"`
FORUMID="$i"
TOTALTHREAD=`cat $DATADIR/temp_thread.temp |grep "$i," |wc -l`
TOTALREPLIES=`cat $DATADIR/forum_replies.temp |grep "$i," |wc -l`
SHAREFB=`cat $DATADIR/temp_share.temp |grep '"fb" :' |sed 's/[^0-9]*//g'`
SHARETWITTER=`cat $DATADIR/temp_share.temp |grep '"twitter" :' |sed 's/[^0-9]*//g'`
SHAREGPLUS=`cat $DATADIR/temp_share.temp |grep '"gplus" :' |sed 's/[^0-9]*//g'`
TOTALPOSTER=`cat $DATADIR/temp_thread.temp |grep "$i," |sort |uniq |wc -l`
TOTALCOMMENTER=`cat $DATADIR/forum_replies.temp |grep "$i," |sort |uniq |wc -l`
file_checker_value=`cat $DATADIR/temp_share.temp |wc -l`
if [ $file_checker_value = 0 ]
then
SHAREFB=0
SHARETWITTER=0
SHAREGPLUS=0
fi
#############################
## INSERT INTO MYSQL
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "insert into forum_daily values ('$REPORTDATE',$FORUMID,$TOTALTHREAD,$TOTALREPLIES,$TOTALPOSTER,$TOTALCOMMENTER,$SHAREFB,$SHARETWITTER,'$SHAREGPLUS');"
#############################
## GENERATE MONTHLY

if [ "$DAY_NOW" = "01" ]
then
REPORTDATE=`date -d@$DATE_START_TS +"%Y%m"`
FORUMID="$i"
TOTALTHREAD=`cat $DATADIR_MONTH/temp_thread.temp |grep "$i," |wc -l`
TOTALREPLIES=`cat $DATADIR_MONTH/temp_replies.temp |grep "$i," |wc -l`
TOTALPOSTER=`cat $DATADIR_MONTH/temp_thread.temp |grep "$i," |sort |uniq |wc -l`
TOTALCOMMENTER=`cat $DATADIR_MONTH/temp_replies.temp |grep "$i," |sort |uniq |wc -l`

## INSERT INTO MYSQL
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "insert into forum_monthly values ('$REPORTDATE',$FORUMID,$TOTALTHREAD,$TOTALREPLIES,$TOTALPOSTER,$TOTALCOMMENTER,$SHAREFB,$SHARETWITTER,'$SHAREGPLUS');"
fi
#############################

done

## GENERATE & SENDING REPORT 
## GENERATE DAILY
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select a.report_date,a.forum_id,b.name forum_name,a.total_thread,a.total_reply,a.total_poster,a.total_commenter, a.share_fb,a.share_twitter,a.share_gplus from forum_daily a,forum_list b where a.forum_id=b.forum_id and a.report_date>='$DATE_QUERY';" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $DATADIR/forum_daily_$DATE_FILE".csv"
mysql -h 172.20.0.159 -ubackup -pkaskus test -r -s -N -e "select a.report_date,a.forum_id,b.name forum_name,a.total_thread,a.total_reply,a.total_poster,a.total_commenter, a.share_fb,a.share_twitter,a.share_gplus from forum_daily a,forum_list b where a.forum_id=b.forum_id and a.report_date>='$DATE_START_STR';" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $DATABQ/forum_daily.csv
bq load kaskus_reporting.forum_daily $DATABQ/forum_daily.csv
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[DAILY] FORUM DISTRIBUTION" -m "STATISTIC FORUM DISTRIBUTION PER $DATE_END_STR \n\n\n Details information is attached below. \n It can also be found at BigQuery under kaskus-166400 project. \n\n\n\n Regards, \n DBA" -a $DATADIR/forum_daily_$DATE_FILE".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
## GENERATE MONTHLY
if [ "$DAY_NOW" = "01" ]
then
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select a.report_date,a.forum_id,b.name forum_name,a.total_thread,a.total_reply,a.total_poster,a.total_commenter, a.share_fb,a.share_twitter,a.share_gplus from forum_monthly a,forum_list b where a.forum_id=b.forum_id and a.report_date='$REPORTDATE';" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $DATADIR_MONTH/forum_monthly_$DATE_FILE".csv"
cat $DATADIR_MONTH/forum_monthly_$DATE_FILE".csv" |grep -v '"report_date"' > $DATABQ/forum_monthly.csv
bq load kaskus_reporting.forum_monthly $DATABQ/forum_monthly.csv
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "[MONTHLY] FORUM DISTRIBUTION" -m "STATISTIC FORUM DISTRIBUTION PER $REPORTDATE \n\n\n Details information is attached below. \n It can also be found at BigQuery under kaskus-166400 project. \n\n\n\n Regards, \n DBA" -a $DATADIR_MONTH/forum_monthly_$DATE_FILE".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
> $DATADIR_MONTH/temp_thread.temp
> $DATADIR_MONTH/temp_replies.temp
fi
#############################
