DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START_STR=$(env TZ=Asia/Jakarta date -d "-1 day" +'%Y%m%d')
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "-1 day" +'%Y/%m/%d') +"%s") # get 1 day ago
OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
DATA_DIR="/home/rully/image_event"

/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:6,tagsearch:{\$in:[/Wisata,Wisata/,/Kuliner,Kuliner/,/Ngabuburit,Ngabuburit/,/KASKUSCendolin,KASKUSCendolin/,/Mudik,Mudik/]},visible:1,dateline:{\$gte:$DATE_START,\$lte:$DATE_END}},{first_post_id:1,_id:0}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed 's@{ "first_post_id" : @ObjectId(@g' |sed 's@ }@)@g' > $DATA_DIR/image_firstid.txt

totalimage=`cat $DATA_DIR/image_firstid.txt |wc -l`
modulus_image=`expr $totalimage % 999`
if [ $modulus_image -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalimage \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/participant_ragamramadhan.csv
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/image_firstid.txt |sed -n "$bawah,$atas p" |tr '"' "'" | tr '\n' ','|sed -e 's/,$//g'`
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.post.find({_id:{\$in:[$id]},from:'app_59244a7e1cbfaa63598b456c'},{thread_id:1,post_username:1,post_userid:1,_id:0}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s@{\n\t"thread_id" : "@"https://www.kaskus.co.id/thread/@g' |sed ':a;N;$!ba;s@,\n\t"post_username" : @,@g' |sed ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' |sed '/}/d' >> $DATA_DIR/participant_ragamramadhan.csv
done

> $DATA_DIR/participant_ragamramadhan_$DATE_START_STR.csv
total_phone=`cat $DATA_DIR/participant_ragamramadhan.csv |wc -l`
for i in `seq 1 $total_phone`
do
iduser=`cat $DATA_DIR/participant_ragamramadhan.csv |cut -d ',' -f3 |cut -d'/' -f6|cut -d '"' -f1 |sed -n "$i p"`
idphone=`mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select phone from userinfo where userid=$iduser;"`
cat $DATA_DIR/participant_ragamramadhan.csv |sed -n "$i p" |sed "s@\$@,\"$idphone\"@g" >> $DATA_DIR/participant_ragamramadhan_$DATE_START_STR.csv
done

sendemail -f statistic@kaskusnetworks.com -t rezky.putra@kaskusnetworks.com,kk.community@kaskusnetworks.com,zarona@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com -u "[ DAILY - $DATE_START_STR ] KASKUS Ramadan Forum Image" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_DIR/participant_ragamramadhan_$DATE_START_STR.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
