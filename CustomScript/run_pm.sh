condition="$1"
if [ "$condition" = "week" ]
then
rangetype=`date -d '1 week ago' "+%s"`
elif [ "$condition" = "month" ]
then
rangetype=`date -d '1 month ago' "+%s"`
fi

tanggal=`date "+%s"`
tanggal_date=`date -d @$tanggal "+%Y-%m-%d %H:%M:%S"`
rangeweek=`expr 3600 \* 24 \* 7`
lastweek="$rangetype"
lastweek_date=`date -d @$lastweek "+%Y-%m-%d %H:%M:%S"`
kaskus_misc="172.20.0.91"
temp_mongo_script="/home/rully"
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
reportweek="/home/rully/reportweekly"

i=0; while [ $i -lt 500 ]; do mysql -uhaproxy_root -pkaskus2014 -h 172.16.0.158 pm -r -s -N -e "select concat(userid,':',count(pm_id)) from pm_user_$i where date>='$lastweek_date' and date<='$tanggal_date' group by userid;" >> $temp_mongo_script/temp.log; i=`expr $i + 1`; done;

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.71 -e "USE user; CREATE TABLE temp(userid int primary key,totalpost int);"

mysqlimport -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.71 --local --fields-terminated-by=':' user $temp_mongo_script/temp.log

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.72 -s -N -e "use user; select concat(if(b.usergroupid=2,c.title,if(b.usergroupid=3,c.title,if(b.usergroupid=16,c.title,if(b.usergroupid=23,c.title,if(b.usergroupid=36,c.title,if(b.usergroupid in (5,7,19,24,29,30,37),'Moderator','Special Users')))))),':',count(a.userid),':',sum(a.totalpost)) from temp a join userinfo b on a.userid=b.userid join usergroup c on c.usergroupid = b.usergroupid group by (if(b.usergroupid=2,c.title,if(b.usergroupid=3,c.title,if(b.usergroupid=16,c.title,if(b.usergroupid=23,c.title,if(b.usergroupid=36,c.title,if(b.usergroupid in (5,7,19,24,29,30,37),'Moderator','Special Users')))))));" > $temp_mongo_script/pm_statistic.log

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.71 -s -N -e "use user;drop table temp;"

cp $temp_mongo_script/temp.log $temp_mongo_script/temp.log_bak
rm $temp_mongo_script/temp.log

echo "mongo $kaskus_misc/kaskus_user_log --eval 'db.userloginlog.count({datetime:{\$lte:\"$tanggal_date\",\$gte:\"$lastweek_date\"}})'" >> $temp_mongo_script/tempmongogeneral.sh

chmod 700 $temp_mongo_script/tempmongogeneral.sh

$temp_mongo_script/tempmongogeneral.sh >> $temp_mongo_script/temploggeneral.sh

TOTAL_MEMBER=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS user -N -s -e"select count(*) from userinfo;"`
TOTAL_REGISTER_WEEK=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS user -N -s -e"select count(*) from userinfo where joindate>=$lastweek and joindate<=$tanggal;"`
TOTAL_UNIQ_LOGIN=`mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS user -N -s -e"select count(*) from userlogin where lastlogin>=$lastweek and lastlogin<=$tanggal;"`
TOTAL_LOGIN=`cat $temp_mongo_script/temploggeneral.sh |sed -n 3p`

TOTAL_PM_01_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Registered" |cut -d':' -f3`
TOTAL_PM_02_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Users Awaiting Email Confirmation" |cut -d':' -f3`
TOTAL_PM_03_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Donator" |cut -d':' -f3`
TOTAL_PM_04_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Banned Users" |cut -d':' -f3`
TOTAL_PM_05_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Spammer" |cut -d':' -f3`
TOTAL_PM_06_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Moderator" |cut -d':' -f3`
TOTAL_PM_07_SEND=`cat $temp_mongo_script/pm_statistic.log |grep "Special Users" |cut -d':' -f3`
TOTAL_PM_01_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Registered" |cut -d':' -f2`
TOTAL_PM_02_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Users Awaiting Email Confirmation" |cut -d':' -f2`
TOTAL_PM_03_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Donator" |cut -d':' -f2`
TOTAL_PM_04_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Banned Users" |cut -d':' -f2`
TOTAL_PM_05_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Spammer" |cut -d':' -f2`
TOTAL_PM_06_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Moderator" |cut -d':' -f2`
TOTAL_PM_07_USER=`cat $temp_mongo_script/pm_statistic.log |grep "Special Users" |cut -d':' -f2`
TOTAL_PM_SEND=`expr $TOTAL_PM_01_SEND + $TOTAL_PM_03_SEND + $TOTAL_PM_04_SEND + $TOTAL_PM_05_SEND + $TOTAL_PM_06_SEND + $TOTAL_PM_07_SEND`

echo "KK-W-GEN-01 = $TOTAL_MEMBER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-02 = $TOTAL_REGISTER_WEEK" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-03 = $TOTAL_UNIQ_LOGIN" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-04 = $TOTAL_LOGIN" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-05-01(Registered) = $TOTAL_PM_01_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
#echo "KK-W-GEN-05-02(Users Awaiting Email Confirmation) = $TOTAL_PM_02_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-05-03(Donator 5$) = $TOTAL_PM_03_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-05-04(Banned Users) = $TOTAL_PM_04_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-05-05(Spammer) = $TOTAL_PM_05_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-05-06(Moderator) = $TOTAL_PM_06_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-05-07(Special Users) = $TOTAL_PM_07_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-06-01(Registered) = $TOTAL_PM_01_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
#echo "KK-W-GEN-06-02(Users Awaiting Email Confirmation) = $TOTAL_PM_02_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-06-03(Donator 5$) = $TOTAL_PM_03_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-06-04(Banned Users) = $TOTAL_PM_04_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-06-05(Spammer) = $TOTAL_PM_05_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-06-06(Moderator) = $TOTAL_PM_06_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-06-07(Special Users) = $TOTAL_PM_07_USER" >> $reportweek/"$condition"_generalreport_$tanggal".log"
echo "KK-W-GEN-07 = $TOTAL_PM_SEND" >> $reportweek/"$condition"_generalreport_$tanggal".log"

mv $reportweek/"$condition"_generalreport_$tanggal".log" $reportweek/"$condition"_generalreport_$tanggal".txt"
echo $reportweek/"$condition"_generalreport_$tanggal".txt" >> $temp_mongo_script/"$condition"_filesummary.log

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,glen@kaskusnetworks.com,rina.tantri@kaskusnetworks.com,ignatius.untung@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER $lastweek_date s/d $tanggal_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $reportweek/"$condition"_generalreport_$tanggal".txt" -s 103.6.117.20 > /dev/null  2>&1

rm $temp_mongo_script/tempmongogeneral.sh
rm $temp_mongo_script/temploggeneral.sh
