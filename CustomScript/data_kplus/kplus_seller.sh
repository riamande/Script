DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START_TIMESTAMP=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "1 month ago" +'%Y/%m/%d') +"%s") # get 1 day ago
DATE_START_DATETIME=`date -d@$DATE_START_TIMESTAMP +"%Y-%m-%d %T"`
DATE_END_DATETIME=`date -d $DATE_END_STR +"%Y-%m-%d %T"`
DATE_NAMING=`date -d@$DATE_START_TIMESTAMP +'%m%Y'`
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
DATA_PATH="/home/rully/data_kplus"
rm -f $DATA_PATH/temp_kplusactive_sell.txt
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 user -s -N -e "select userid from userinfo where usergroupid=16;" > $DATA_PATH/kplususers.txt
fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g' |sed -e "s@^@'@g" |sed -e "s@\\$@'@g" |sed -e "s@,@','@g"`
for i in `cat $DATA_PATH/kplususers.txt`
do
a=`expr $i % 500`
mongo 172.20.0.242/kaskus_forum1 --eval "rs.slaveOk();db.mythread_$a.count({thread_userid:'$i',forum_id:{\$in:[$fjb_id]},visible:1,prefix_id:'WTS'})" |grep -v 'MongoDB\|connecting' > $DATA_PATH/tempcount.temp
b=`cat $DATA_PATH/tempcount.temp`
if [ $b -gt 0 ]
then
echo $i >> $DATA_PATH/temp_kplusactive_sell.txt
fi
done

for j in `cat $DATA_PATH/temp_kplusactive_sell.txt`
do
mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 user -r -s -N -e "select b.username,a.userid,concat('http://www.kaskus.co.id/profile/',a.userid) link_profile,a.email,a.phone from userinfo a,userlogin b where a.userid=b.userid and a.userid=$j;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" >> $DATA_PATH/kplus_seller_$DATE_NAMING.csv
done

sendemail -f statistic@kaskusnetworks.com -t marsha.septiani@kaskusnetworks.com,carolina.ardelia@kaskusnetworks.com,hilda@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "[automated] K+ SELLER - $DATE_NAMING" -m "K+ SELLER $DATE_NAMING \n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_PATH/kplus_seller_$DATE_NAMING.csv -o tls=no -s 103.6.117.20
