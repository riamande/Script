DATE_STR=`date +%Y%m%d`
DATE_UNIX_START=`date -d "$DATE_STR" +%s`
DATE_UNIX_END=`date -d "$DATE_STR 16:00" +%s`
#DATE_WEEK=`date +%u`
WAVE_COUNT=`cat /home/rully/temp_videochalangecount.temp`
DATE_WEEK=`expr $WAVE_COUNT + 1`
#echo $DATE_UNIX_START $DATE_UNIX_END $DATE_STR

if [ $DATE_WEEK = 1 ]
then
DATE_UNIX_START=`date -d'20170508' +%s`
DATE_UNIX_END=`date -d'20170510' +%s`
elif [ $DATE_WEEK = 2 ]
then
DATE_UNIX_START=`date -d'20170510' +%s`
DATE_UNIX_END=`date -d'20170512' +%s`
elif [ $DATE_WEEK = 3 ]
then
DATE_UNIX_START=`date -d'20170512' +%s`
DATE_UNIX_END=`date -d'20170515' +%s`
elif [ $DATE_WEEK = 4 ]
then
DATE_UNIX_START=`date -d'20170515' +%s`
DATE_UNIX_END=`date -d'20170517' +%s`
elif [ $DATE_WEEK = 5 ]
then
DATE_UNIX_START=`date -d'20170517' +%s`
DATE_UNIX_END=`date -d'20170519' +%s`
elif [ $DATE_WEEK = 6 ]
then
DATE_UNIX_START=`date -d'20170519' +%s`
DATE_UNIX_END=`date -d'20170522' +%s`
elif [ $DATE_WEEK = 7 ]
then
DATE_UNIX_START=`date -d'20170522' +%s`
DATE_UNIX_END=`date -d'20170524' +%s`
fi 

/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:8,dateline:{\$gte:$DATE_UNIX_START,\$lte:$DATE_UNIX_END},content_filename:/c.kaskus.id/,tagsearch:{\$in:[/kaskusvideochallenge,wave$DATE_WEEK/,/wave$DATE_WEEK,kaskusvideochallenge/]}},{post_username:1,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > kaskusvideochallenge_wave"$DATE_WEEK".csv
sed -i ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/thread/@g' kaskusvideochallenge_wave"$DATE_WEEK".csv
sed -i ':a;N;$!ba;s@),\n\t"post_username" : @,@g' kaskusvideochallenge_wave"$DATE_WEEK".csv
sed -i ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' kaskusvideochallenge_wave"$DATE_WEEK".csv
sed -i '/}/d' kaskusvideochallenge_wave"$DATE_WEEK".csv
sendemail -f statistic@kaskusnetworks.com -t tiwi@kaskusnetworks.com,zarona@kaskusnetworks.com,rezky.putra@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com  -u "DAILY VIDEO CHALLENGE WAVE$DATE_WEEK" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a kaskusvideochallenge_wave"$DATE_WEEK".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t dominiko.dany@kaskusnetworks.com,vika.praditriyani@kaskusnetworks.com,vicky.gunawan@kaskusnetworks.com,septantya.pamungkas@kaskusnetworks.com,ira.sari@kaskusnetworks.com,zarona@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com  -u "DAILY VIDEO CHALLENGE $DATE_STR" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a kaskusvideochallenge_"$DATE_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com  -u "DAILY VIDEO CHALLENGE $DATE_STR" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a kaskusvideochallenge_"$DATE_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
echo $DATE_WEEK > /home/rully/temp_videochalangecount.temp
