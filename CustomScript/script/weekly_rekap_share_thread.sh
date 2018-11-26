
WS="172.16.0.88"
PORT="27017"
DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_START_STR=$(env TZ=Asia/Jakarta date -d "7 day ago" +'%Y%m%d')
DATA_PATH="/home/rully/data_thread_share"
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"


mysql -h 172.20.0.72 -u$MYSQL_USER -p$MYSQL_PASS kaskus_statistic -r -e "select date_str,type,title,total from thread_share where date_str >= DATE_FORMAT((NOW() - interval 7 day), '%Y%m%d');" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $DATA_PATH/rekap_weekly_thread_"$DATE_START_STR".csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[automated] WEEKLY THREAD SHARE REKAP - $DATE_START_STR" -m "THREAD SHARE REKAP $DATE_START_STR s/d $DATE_END_STR \n\n Details information attached below : \n\n\n\n Regards, \n DBA" -a $DATA_PATH/rekap_weekly_thread_"$DATE_START_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
