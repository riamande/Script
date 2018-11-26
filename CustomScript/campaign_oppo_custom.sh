#DATE_END_STR="$1"
DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START_STR=$(env TZ=Asia/Jakarta date -d "$DATE_END_STR - 1 day" +'%Y%m%d')
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "$DATE_END_STR - 1 day" +'%Y/%m/%d') +"%s") # get 1 day ago
OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
DATA_DIR="/home/rully/campaign_oppo"

#forum image
#thread
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({visible:1,forum_id:6,_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')},tagsearch:/sportastic/i},{post_userid:1,post_username:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $DATA_DIR/image_oppo.csv
sed -i ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/thread/@g' $DATA_DIR/image_oppo.csv
sed -i ':a;N;$!ba;s@),\n\t"post_username" : @,@g' $DATA_DIR/image_oppo.csv
sed -i ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' $DATA_DIR/image_oppo.csv
sed -i '/}/d' $DATA_DIR/image_oppo.csv
cp $DATA_DIR/image_oppo.csv $DATA_DIR/image_oppo_$DATE_START_STR.csv

sendemail -f statistic@kaskusnetworks.com -t elista.manda@kaskusnetworks.com,zarona@kaskusnetworks.com,christoforus.stefanus@kaskusnetworks.com,giovani.ardy@kaskusnetworks.com,kk.community@kaskusnetworks.com,db@kaskusnetworks.com,rully@kaskusnetworks.com -u "[DAILY - $DATE_START_STR] OPPO Online Activity" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_DIR/image_oppo_$DATE_START_STR.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[DAILY - $DATE_START_STR] OPPO Online Activity" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_DIR/image_oppo_$DATE_START_STR.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
