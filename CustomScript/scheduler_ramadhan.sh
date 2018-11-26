DATE_END=`date +%Y%m%d`
DATE_START=`date -d '1 day ago' +%Y%m%d`
DATE_UNIX_START=`date -d "$DATE_START" +%s`
DATE_UNIX_END=`date -d "$DATE_END" +%s`
DATA_DIR="/home/rully/tualang_ramadhan"

mongo 172.20.0.92/kaskus_oauth --eval "rs.slaveOk();db.access_token.find({consumer_key:'7acf0b1f5bd7cf97495f49646b51a5',generated:{\$gte:$DATE_UNIX_START,\$lt:$DATE_UNIX_END}},{_id:0,userid:1,username:1}).forEach(printjson)" |grep -v 'MongoDB shell version\|connecting to:' > $DATA_DIR/tualang_temp.json
cat $DATA_DIR/tualang_temp.json |sed 's@{ "userid" : @@g' |sed 's@ "username" : @@g' |sed 's@ }@@g' |sort |uniq > $DATA_DIR/tualang_$DATE_END.csv

sendemail -f statistic@kaskusnetworks.com -t agnes.revian@kaskusnetworks.com,zarona@kaskusnetworks.com,giovani.ardy@kaskusnetworks.com,kk.community@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com -u "DAILY TUALANG RAMADHAN $DATE_END" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_DIR/tualang_$DATE_END.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
