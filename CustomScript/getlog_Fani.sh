#! /bin/sh

DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "-1 day" +'%Y/%m/%d') +"%s") # get 1 day ago
OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
DATE_FILE=$(env TZ=Asia/Jakarta date -d '-1 day' +'%Y%m%d')
FILE_PATH="/home/rully"

mongoexport -h 172.20.0.91 -d kaskus_user_log -c user_device_log -q "{_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}}" -o $FILE_PATH/"$DATE_FILE"_userdevicelog.json

for i in `cat $FILE_PATH/"$DATE_FILE"_userdevicelog.json |sed 's@"userid" : @|@g' |cut -d '|' -f2 |cut -d '"' -f2 |sort |uniq`
do
mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select concat('{ \"userid\" : \"',userid,'\", \"status\" : \"',b.title,'\", \"phone\" : \"',phone,'\" }') from userinfo a,usergroup b where a.usergroupid=b.usergroupid and a.userid=$i;" >> $FILE_PATH/"$DATE_FILE"_userphonestatus.json
done

sendemail -f statistic@kaskusnetworks.com -t fani.bahar@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "[automated] DAILY DATA FEED" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $FILE_PATH/"$DATE_FILE"_userdevicelog.json $FILE_PATH/"$DATE_FILE"_userphonestatus.json -o tls=no -s 103.6.117.20 > /dev/null  2>&1

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[automated] DAILY DATA FEED" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $FILE_PATH/"$DATE_FILE"_userdevicelog.json -o tls=no -s 103.6.117.20 > /dev/null  2>&1
