MYSQL_USER='percona'
MYSQL_PASS='kaskus2014'
forum_id=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select child_list from forum_list where forum_id=241;" |sed -e 's$\,\-1$$g' |sed "s@,@','@g;s@^@'@g;s/\$/'/g"`
forum_reg=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select child_list from forum_list where forum_id=72;" |sed -e 's$\,\-1$$g' |sed "s@,@','@g;s@^@'@g;s/\$/'/g"`
forum=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select child_list from forum_list where forum_id=241;" |sed -e 's$\,\-1$$g'`
regional=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -s -N -e "select child_list from forum_list where forum_id=72;" |sed -e 's$\,\-1$$g'`
data_dir="/home/rully/kpi_report/kreator"
tgl_start_str=`date -d "- 1 day" +%Y%m%d`
tgl_start=`date -d "$tgl_start_str" +%s`
end_date=`date -d "$tgl_start_str + 1 day" +%s`
### enable for custom dates only
#tgl_start=`date -d "20180211" +%s`
#tgl_end=`date -d "20180213" +%s`
#while [ $tgl_start -lt $tgl_end ]
#do
#end_date=`expr $tgl_start + 86400`
### end
date_name=`date -d@$tgl_start +%m/%d/%Y`
OID_START=`mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "Math.floor($tgl_start).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "Math.floor($end_date).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
rm $data_dir/mypost.temp
rm $data_dir/thread.temp
rm $data_dir/reply.temp
rm $data_dir/test_sed.sh

mongoexport -h 127.0.0.1:27018 -d kaskus_forum -c thread -uforumshardrw -pG5NVEI5WkLFgGTB1 -f _id,forum_id --type=csv -q "{_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},forum_id:{\$in:[$forum,$regional]}}" -o $data_dir/mythread.temp
cat $data_dir/mythread.temp |grep -v '_id,forum_id' |sed 's@ObjectId(@@g;s@NumberLong(@@g;s@)@@g' > $data_dir/mythread1.temp
for i in `seq 0 499`
do
mongoexport -h 172.20.0.158 -ukkreplreadall -pgs5B7Y6jhsRv7LRt --authenticationDatabase=admin -d kaskus_forum1 -c mypost_$i -f thread_id,forum_id --type=csv -q "{_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')},forum_id:{\$in:[$forum_id,$forum_reg]}}" -o $data_dir/mypost.csv
cat $data_dir/mypost.csv |grep -v 'thread_id,forum_id' >> $data_dir/mypost.temp
done
mongo 172.20.0.242/kaskus_forum1 -ukkreplreadall -pgs5B7Y6jhsRv7LRt --authenticationDatabase=admin --eval "rs.slaveOk();db.thread_warehouse.find({_id:{\$gte:ObjectId('$OID_START'),\$lt:ObjectId('$OID_END')}},{_id:0,thread_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d '"' -f4 > $data_dir/Warehouse.temp
touch $data_dir/thread.temp $data_dir/reply.temp
total_wh=`cat $data_dir/Warehouse.temp |wc -l`
if [ $total_wh -gt 0 ]
then
for i in `cat $data_dir/Warehouse.temp`
do
cat $data_dir/mythread1.temp |grep "$i" >> $data_dir/thread.temp
cat $data_dir/mypost.temp |grep "$i" >> $data_dir/reply.temp
result="$result|$i"
done
hasil=`echo $result|sed 's@^|@@g'`
grep -Ev "$hasil" $data_dir/mythread1.temp > $data_dir/thread_nonKreator.temp
grep -Ev "$hasil" $data_dir/mypost.temp > $data_dir/reply_nonKreator.temp
else
cat $data_dir/mythread1.temp > $data_dir/thread_nonKreator.temp
cat $data_dir/mypost.temp > $data_dir/reply_nonKreator.temp
fi

for i in `mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -r -s -N -e "select forum_id from forum_list where parent_id in (72,241);"`
do
a=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -r -s -N -e "select concat('s@,',replace(replace(child_list,',',concat('$\@,',forum_id,'@g;s@,')),';s@,-1','')) from forum_list where forum_id=$i;" |sed 's@\\$@\\\\$@g'`
b=`echo $a |sed 's@\\$@\\\\$@g'`
echo 'sed -i "'$a'" thread.temp reply.temp thread_nonKreator.temp reply_nonKreator.temp' >> $data_dir/test_sed.sh
done
chmod 700 $data_dir/test_sed.sh
$data_dir/test_sed.sh

cat $data_dir/thread.temp |cut -d ',' -f2 |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F $',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=$','  > $data_dir/creator_t
cat $data_dir/reply.temp |cut -d ',' -f2 |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F $',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=$',' > $data_dir/creator_r
cat $data_dir/thread_nonKreator.temp |cut -d ',' -f2 |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F $',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=$',' > $data_dir/noncreator_t
cat $data_dir/reply_nonKreator.temp |cut -d ',' -f2 |sort |uniq -c |sed 's@^  *@@g;s@  *@,@g' |awk -F $',' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=$',' > $data_dir/noncreator_r

join -11 -a1 $data_dir/creator_r $data_dir/creator_t -o1.1,1.2,2.2 -e0 -t ',' |sed "s@^@\"$date_name\",@g" >> $data_dir/gabungan_kreator
join -11 -a1 $data_dir/noncreator_r $data_dir/noncreator_t -o1.1,1.2,2.2 -e0 -t ',' |sed "s@^@\"$date_name\",@g" >> $data_dir/gabungan_non

for i in `mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -r -s -N -e "select forum_id from forum_list where parent_id in (72,241);"`
do
forum_name=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS forum -r -s -N -e "select replace(name,'&','and') from forum_list where forum_id=$i;"`
sed -i "s@^\"$date_name\",$i,@\"$date_name\",\"$forum_name\",@g" $data_dir/gabungan_kreator $data_dir/gabungan_non
done
sed -i "s@^\"$date_name\",72,@delete_forum_id@g;/^delete_forum_id/d" $data_dir/gabungan_kreator $data_dir/gabungan_non
sed -i "s@^\"$date_name\",241,@delete_forum_id@g;/^delete_forum_id/d" $data_dir/gabungan_kreator $data_dir/gabungan_non
mv $data_dir/gabungan_non $data_dir/nonkreator_$tgl_start_str".csv"
mv $data_dir/gabungan_kreator $data_dir/kreator_$tgl_start_str".csv"

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,seno@kaskusnetworks.com -u "DAILY THREAD CREATOR STATISTIC" -m "STATISTIC THREAD CREATOR PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/kreator_$tgl_start_str".csv" $data_dir/nonkreator_$tgl_start_str".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

### enable for custom dates
#tgl_start="$end_date"
#done
### end
