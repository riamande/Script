tanggal=`date "+%s"`
tanggal_date=`date -d @$tanggal "+%Y-%m-%d %H:%M:%S"`
rangeweek=`expr 3600 \* 24 \* 7`
lastweek=`expr $tanggal - $rangeweek`
lastweek_date=`date -d @$lastweek "+%Y-%m-%d %H:%M:%S"`
kaskus_misc="172.20.0.91"
temp_mongo_script="/home/rully"
MYSQL_USER="kaskus_fight"
MYSQL_PASS="tryITharder1990"

fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.165 kaskus_forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`

echo "mongo $kaskus_misc/kaskus_user_log --eval 'db.userloginlog.count({datetime:{\$lte:\"$tanggal_date\",\$gte:\"$lastweek_date\"}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'a=ObjectId();b=db.post.findOne({dateline:{\$gte:$lastweek}},{_id:1});db.post.count({_id:{\$lte:a,\$gte:b._id}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$nin:[$fjb_id]}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[$fjb_id]},prefix_id:\"WTS\"})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[$fjb_id]},prefix_id:\"WTB\"})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[$fjb_id]},prefix_id:{\$nin:[\"WTS\",\"WTB\"]}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({dateline:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$nin:[$fjb_id]}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({dateline:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[$fjb_id]},prefix_id:\"WTS\"})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({dateline:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[$fjb_id]},prefix_id:\"WTB\"})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({dateline:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[$fjb_id]},prefix_id:{\$nin:[\"WTS\",\"WTB\"]}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$in: [$fjb_id]},last_post:{\$gte:$lastweek,\$lte:$tanggal},prefix_id:\"WTS\"},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str,dateline:{\$gte:$lastweek,\$lte:$tanggal}}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"active wts\",total:hasil});" >> $temp_mongo_script/tempmongoreport.JSON

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$in: [$fjb_id]},last_post:{\$gte:$lastweek,\$lte:$tanggal},prefix_id:\"WTB\"},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str,dateline:{\$gte:$lastweek,\$lte:$tanggal}}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"active wtb\",total:hasil});" >> $temp_mongo_script/tempmongoreport.JSON

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$in: [$fjb_id]},last_post:{\$gte:$lastweek,\$lte:$tanggal},prefix_id:{\$nin:[\"WTS\",\"WTB\"]}},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str,dateline:{\$gte:$lastweek,\$lte:$tanggal}}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"active misc\",total:hasil});" >> $temp_mongo_script/tempmongoreport.JSON

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$in: [$fjb_id]},dateline:{\$gte:$lastweek,\$lte:$tanggal},prefix_id:\"WTS\"},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"new wts\",total:hasil});" >> $temp_mongo_script/tempmongoreport.JSON

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$in: [$fjb_id]},dateline:{\$gte:$lastweek,\$lte:$tanggal},prefix_id:\"WTB\"},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"new wtb\",total:hasil});" >> $temp_mongo_script/tempmongoreport.JSON

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$in: [$fjb_id]},dateline:{\$gte:$lastweek,\$lte:$tanggal},prefix_id:{\$nin:[\"WTS\",\"WTB\"]}},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"new misc\",total:hasil});" >> $temp_mongo_script/tempmongoscript.sh

echo "var hasil = 0; var x = db.thread.find({forum_id:{\$nin:[$fjb_id]},dateline:{\$gte:$lastweek,\$lte:$tanggal}},{_id:1});for(i=0;i<x.length();i++){ try{hasil += db.post.find({thread_id:x[i]['_id'].str}).count();}catch(err){} }; db.report.save({dateline:$tanggal,type:\"new forum\",total:hasil});" >> $temp_mongo_script/tempmongoreport.JSON


chmod 700 $temp_mongo_script/tempmongoscript.sh

$temp_mongo_script/tempmongoscript.sh > $temp_mongo_script/templogmongo.log

mongo kaskus_forum1 $temp_mongo_script/tempmongoreport.JSON &

temp_ttl_pub_replies_wts=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"active wts"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_pub_replies_wtb=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"active wtb"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_pub_replies_misc=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"active misc"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_new_replies_wts=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"new wts"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_new_replies_wtb=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"new wtb"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_new_replies_misc=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"new misc"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_new_replies_forum=`mongo kaskus_forum1 --eval 'db.report.find({dateline:'$tanggal',type:"new forum"},{total:1,_id:0}).forEach(printjson)' |sed -n 3p |sed -e 's/ //g' |cut -d':' -f2 |cut -d'}' -f1`

temp_ttl_user_thread_forum=`mongo kaskus_forum1 --eval 'db.thread.distinct("post_userid",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$nin:['$fjb_id']}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |wc -l`

temp_ttl_user_thread_fjb=`mongo kaskus_forum1 --eval 'db.thread.distinct("post_userid",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$in:['$fjb_id']}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |wc -l`

mongo kaskus_forum1 --eval 'db.thread.distinct("_id",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$nin:['$fjb_id']}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |sed -e 's$ObjectId($$g'|sed -e 's$)$$g' > $temp_mongo_script/list_thread_forum.log

mongo kaskus_forum1 --eval 'db.thread.distinct("_id",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$in:['$fjb_id']}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |sed -e 's$ObjectId($$g'|sed -e 's$)$$g' > $temp_mongo_script/list_thread_fjb.log

for f in `cat $temp_mongo_script/list_thread_forum.log`
do
mongo kaskus_forum1 --eval 'db.post.distinct("post_userid",{thread_id:'$f'}).forEach(printjson)' |grep -v MongoDB |grep -v connecting > $temp_mongo_script/temp_ttl_usr_forum.log
for g in `cat $temp_mongo_script/temp_ttl_usr_forum.log`
do
echo "db.forum.save({_id:$g});" >> $temp_mongo_script/importforum.JSON
done
done

for h in `cat $temp_mongo_script/list_thread_fjb.log `
do
mongo kaskus_forum1 --eval 'db.post.distinct("post_userid",{thread_id:'$h'}).forEach(printjson)' |grep -v MongoDB |grep -v connecting > $temp_mongo_script/temp_ttl_usr_fjb.log
for i in `cat $temp_mongo_script/temp_ttl_usr_fjb.log`
do
echo "db.fjb.save({_id:$i});" >> $temp_mongo_script/importfjb.JSON
done
done

counterlinesforum=`cat $temp_mongo_script/importforum.JSON |wc -l`
counterlinesfjb=`cat $temp_mongo_script/importforum.JSON |wc -l`

if [ "$counterlinesforum" < "5000000" ]
then
	split -l 50000 $temp_mongo_script/importforum.JSON $temp_mongo_script/importforum.JSON_50k
	for k in `ls $temp_mongo_script/importforum.JSON_50k*`
	do
		mongo test $k
		rm $k
	done
else
	split -l 5000000 $temp_mongo_script/importforum.JSON $temp_mongo_script/importforum.JSON_5m
	for j in `ls $temp_mongo_script/importforum.JSON_5m*`
	do
		split -l 50000 $j $j"_50k"
		rm $j
		for l in `ls $j"_50k"*`
		do
			mongo test $l
			rm $l
		done
	done
fi

if [ "$counterlinesfjb" < "5000000" ]
then
	split -l 50000 $temp_mongo_script/importfjb.JSON $temp_mongo_script/importfjb.JSON_50k
	for k in `ls $temp_mongo_script/importfjb.JSON_50k*`
	do
		mongo test $k
		rm $k
	done
else
	split -l 5000000 $temp_mongo_script/importfjb.JSON $temp_mongo_script/importfjb.JSON_5m
	for j in `ls $temp_mongo_script/importfjb.JSON_5m*`
	do
		split -l 50000 $j $j"_50k"
		rm $j
		for l in `ls $j"_50k"*`
		do
			mongo test $l
			rm $l
		done
	done
fi

temp_ttl_usr_forum=`mongo test --eval 'db.forum.count()' |sed -n 3p`
mongo test --eval 'db.forum.drop()'

temp_ttl_usr_fjb=`mongo test --eval 'db.fjb.count()' |sed -n 3p`
mongo test --eval 'db.fjb.drop()'

for i in {0..499}; do (mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.153 kaskus_pm -e "select  concat(userid,':',count(pm_id)) from pm_user_$i where date>='$lastweek_date' and date<='$tanggal_date' group by userid;") | grep '[0-9]' >> $temp_mongo_script/temp.log;done;

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.170 -e "USE kaskus_user; CREATE TABLE temp(userid int primary key,totalpost int);" 

mysqlimport -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.170 --local --fields-terminated-by=':' kaskus_user $temp_mongo_script/temp.log

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.170 -s -N -e "use kaskus_user; select concat(if(b.usergroupid=2,c.title,if(b.usergroupid=3,c.title,if(b.usergroupid=16,c.title,if(b.usergroupid=23,c.title,if(b.usergroupid=36,c.title,if(b.usergroupid in (5,7,19,24,29,30,37),'Moderator','Special Users')))))),':',count(a.userid),':',sum(a.totalpost)) from temp a join userinfo b on a.userid=b.userid join usergroup c on c.usergroupid = b.usergroupid group by (if(b.usergroupid=2,c.title,if(b.usergroupid=3,c.title,if(b.usergroupid=16,c.title,if(b.usergroupid=23,c.title,if(b.usergroupid=36,c.title,if(b.usergroupid in (5,7,19,24,29,30,37),'Moderator','Special Users')))))));" > $temp_mongo_script/pm_statistic.log



mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.170 -s -N -e "use kaskus_user;drop table temp;"

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.170 kaskus_user -s -N -e "select concat(if(gender=1,'L',if(gender=2,'P','unidentified')),':',count(*)) from userinfo group by gender;" > $temp_mongo_script/gender_statistic.log;

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.170 kaskus_user -s -N -e "select concat(if((year(sysdate())-year(dateofbirth))<=15,'under 15',if((year(sysdate())-year(dateofbirth))>=16 and (year(sysdate())-year(dateofbirth))<=20,'16 - 20',if((year(sysdate())-year(dateofbirth))>=21 and (year(sysdate())-year(dateofbirth))<=25,'21 - 25',if((year(sysdate())-year(dateofbirth))>=26 and (year(sysdate())-year(dateofbirth))<=30,'26 - 30',if((year(sysdate())-year(dateofbirth))>=31 and (year(sysdate())-year(dateofbirth))<=35,'31 - 35',if((year(sysdate())-year(dateofbirth))>=36 and (year(sysdate())-year(dateofbirth))<=40,'36 - 40',if((year(sysdate())-year(dateofbirth))>=41 and (year(sysdate())-year(dateofbirth))<=45,'41 - 45',if((year(sysdate())-year(dateofbirth))>=46 and (year(sysdate())-year(dateofbirth))<=50,'46 - 50',if((year(sysdate())-year(dateofbirth))>=51 and (year(sysdate())-year(dateofbirth))<=55,'51 - 55',if((year(sysdate())-year(dateofbirth))>=56 and (year(sysdate())-year(dateofbirth))<=60,'56 - 60',if((year(sysdate())-year(dateofbirth))>=61 and (year(sysdate())-year(dateofbirth))<=65,'61 - 65',if((year(sysdate())-year(dateofbirth))>=66,'66++','')))))))))))),':',count(*)) from userinfo group by (if((year(sysdate())-year(dateofbirth))<=15,'under 15',if((year(sysdate())-year(dateofbirth))>=16 and (year(sysdate())-year(dateofbirth))<=20,'16 - 20',if((year(sysdate())-year(dateofbirth))>=21 and (year(sysdate())-year(dateofbirth))<=25,'21 - 25',if((year(sysdate())-year(dateofbirth))>=26 and (year(sysdate())-year(dateofbirth))<=30,'26 - 30',if((year(sysdate())-year(dateofbirth))>=31 and (year(sysdate())-year(dateofbirth))<=35,'31 - 35',if((year(sysdate())-year(dateofbirth))>=36 and (year(sysdate())-year(dateofbirth))<=40,'36 - 40',if((year(sysdate())-year(dateofbirth))>=41 and (year(sysdate())-year(dateofbirth))<=45,'41 - 45',if((year(sysdate())-year(dateofbirth))>=46 and (year(sysdate())-year(dateofbirth))<=50,'46 - 50',if((year(sysdate())-year(dateofbirth))>=51 and (year(sysdate())-year(dateofbirth))<=55,'51 - 55',if((year(sysdate())-year(dateofbirth))>=56 and (year(sysdate())-year(dateofbirth))<=60,'56 - 60',if((year(sysdate())-year(dateofbirth))>=61 and (year(sysdate())-year(dateofbirth))<=65,'61 - 65',if((year(sysdate())-year(dateofbirth))>=66,'66++','')))))))))))));" > $temp_mongo_script/age_statistic.log

cp $temp_mongo_script/temp.log $temp_mongo_script/temp.log_bak
rm $temp_mongo_script/temp.log
rm $temp_mongo_script/importforum.JSON
rm $temp_mongo_script/importfjb.JSON
rm $temp_mongo_script/tempmongoscript.sh
rm $temp_mongo_script/tempmongoreport.JSON

TOTAL_ACTIVE_USER=`mysql -h 172.20.0.165 -u$MYSQL_USER -p$MYSQL_PASS kaskus_forum -N -s -e"select count(*) from forum_user_setting where (lastpost_time>=$lastweek and lastpost_time<=$tanggal) or (lastthread_time>=$lastweek and lastthread_time<=$tanggal);"`
TOTAL_USER_FORUM_THREAD="$temp_ttl_user_thread_forum"
TOTAL_USER_FORUM_POST=`expr $temp_ttl_usr_forum - $temp_ttl_user_thread_forum`
TOTAL_USER_ACTIVE_FORUM="$temp_ttl_usr_forum"
TOTAL_USER_FJB_THREAD="$temp_ttl_user_thread_fjb"
TOTAL_USER_FJB_POST=`expr $temp_ttl_usr_fjb - $temp_ttl_user_thread_fjb`
TOTAL_USER_ACTIVE_FJB="$temp_ttl_usr_fjb"
TOTAL_THREAD_FORUM=`cat $temp_mongo_script/templogmongo.log |sed -n 9p`
TOTAL_THREAD_FJB_WTS=`cat $temp_mongo_script/templogmongo.log |sed -n 12p`
TOTAL_THREAD_FJB_WTB=`cat $temp_mongo_script/templogmongo.log |sed -n 15p`
TOTAL_THREAD_FJB_MISC=`cat $temp_mongo_script/templogmongo.log |sed -n 18p`

TOTAL_NEW_FORUM=`cat $temp_mongo_script/templogmongo.log |sed -n 21p`
TOTAL_NEW_FJB_WTS=`cat $temp_mongo_script/templogmongo.log |sed -n 24p`
TOTAL_NEW_FJB_WTB=`cat $temp_mongo_script/templogmongo.log |sed -n 27p`
TOTAL_NEW_FJB_MISC=`cat $temp_mongo_script/templogmongo.log |sed -n 30p`

TOTAL_PUB_REPLIES_WTS="$temp_ttl_pub_replies_wts"
TOTAL_PUB_REPLIES_WTB="$temp_ttl_pub_replies_wtb"
TOTAL_PUB_REPLIES_MISC="$temp_ttl_pub_replies_misc"
TOTAL_NEW_REPLIES_WTS="$temp_ttl_new_replies_wts"
TOTAL_NEW_REPLIES_WTB="$temp_ttl_new_replies_wtb"
TOTAL_NEW_REPLIES_MISC="$temp_ttl_new_replies_misc"
TOTAL_NEW_REPLIES_FORUM="$temp_ttl_new_replies_forum"
TOTAL_AGE_15=`cat $temp_mongo_script/age_statistic.log |grep "under 15" |cut -d':' -f2`
TOTAL_AGE_1620=`cat $temp_mongo_script/age_statistic.log |grep "16 - 20" |cut -d':' -f2`
TOTAL_AGE_2125=`cat $temp_mongo_script/age_statistic.log |grep "21 - 25" |cut -d':' -f2`
TOTAL_AGE_2630=`cat $temp_mongo_script/age_statistic.log |grep "26 - 30" |cut -d':' -f2`
TOTAL_AGE_3135=`cat $temp_mongo_script/age_statistic.log |grep "31 - 35" |cut -d':' -f2`
TOTAL_AGE_3640=`cat $temp_mongo_script/age_statistic.log |grep "36 - 40" |cut -d':' -f2`
TOTAL_AGE_4145=`cat $temp_mongo_script/age_statistic.log |grep "41 - 45" |cut -d':' -f2`
TOTAL_AGE_4650=`cat $temp_mongo_script/age_statistic.log |grep "46 - 50" |cut -d':' -f2`
TOTAL_AGE_5155=`cat $temp_mongo_script/age_statistic.log |grep "51 - 55" |cut -d':' -f2`
TOTAL_AGE_5660=`cat $temp_mongo_script/age_statistic.log |grep "56 - 60" |cut -d':' -f2`
TOTAL_AGE_6165=`cat $temp_mongo_script/age_statistic.log |grep "61 - 65" |cut -d':' -f2`
TOTAL_AGE_66=`cat $temp_mongo_script/age_statistic.log |grep "66++" |cut -d':' -f2`
TOTAL_GENDER_L=`cat $temp_mongo_script/gender_statistic.log |grep "L" |cut -d':' -f2`
TOTAL_GENDER_P=`cat $temp_mongo_script/gender_statistic.log |grep "P" |cut -d':' -f2`
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
TOTAL_PM_SEND=`expr $TOTAL_PM_01_SEND + $TOTAL_PM_02_SEND + $TOTAL_PM_03_SEND + $TOTAL_PM_04_SEND + $TOTAL_PM_05_SEND + $TOTAL_PM_06_SEND + $TOTAL_PM_07_SEND`

TOTAL_POST=`cat $temp_mongo_script/templogmongo.log |sed -n 6p`
TOTAL_UNIQ_LOGIN=`mysql -h 172.20.0.170 -u$MYSQL_USER -p$MYSQL_PASS kaskus_user -N -s -e"select count(*) from userlogin where lastlogin>=$lastweek and lastlogin<=$tanggal;"`
TOTAL_LOGIN=`cat $temp_mongo_script/templogmongo.log |sed -n 3p`
TOTAL_REGISTER_WEEK=`mysql -h 172.20.0.170 -u$MYSQL_USER -p$MYSQL_PASS kaskus_user -N -s -e"select count(*) from userinfo where joindate>=$lastweek and joindate<=$tanggal;"`
TOTAL_MEMBER=`mysql -h 172.20.0.170 -u$MYSQL_USER -p$MYSQL_PASS kaskus_user -N -s -e"select count(*) from userinfo;"`


sendemail -f statistic@kaskusnetworks.com -t yesika.manik@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com,alken@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER $lastweek_date s/d $tanggal_date : \n\n\n TOTAL ACTIVE USERS -> FORUM & FJB = $TOTAL_ACTIVE_USER \n KK-W-FRM-01 = $TOTAL_USER_FORUM_THREAD \n KK-W-FRM-02 = $TOTAL_USER_FORUM_POST \n KK-W-FRM-03 = $TOTAL_USER_ACTIVE_FORUM \n KK-W-FJB-01 = $TOTAL_USER_FJB_THREAD \n KK-W-FJB-02 = $TOTAL_USER_FJB_POST \n KK-W-FJB-03 = $TOTAL_USER_ACTIVE_FJB \n KK-W-FRM-04 = $TOTAL_THREAD_FORUM \n KK-W-FRM-05 = $TOTAL_NEW_FORUM \n KK-W-FRM-07 = $TOTAL_NEW_REPLIES_FORUM \n KK-W-FJB-04 = $TOTAL_THREAD_FJB_WTB \n KK-W-FJB-05 = $TOTAL_THREAD_FJB_WTS \n KK-W-FJB-06 = $TOTAL_THREAD_FJB_MISC \n KK-W-FJB-07 = $TOTAL_NEW_FJB_WTB \n KK-W-FJB-08 = $TOTAL_NEW_FJB_WTS \n KK-W-FJB-09 = $TOTAL_NEW_FJB_MISC \n KK-W-FJB-13 = $TOTAL_PUB_REPLIES_WTB \n KK-W-FJB-14 = $TOTAL_PUB_REPLIES_WTS \n KK-W-FJB-15 = $TOTAL_PUB_REPLIES_MISC \n KK-W-FJB-16 = $TOTAL_NEW_REPLIES_WTB \n KK-W-FJB-17 = $TOTAL_NEW_REPLIES_WTS \n KK-W-FJB-18 = $TOTAL_NEW_REPLIES_MISC \n TOTAL POST (FJB & FORUM) = $TOTAL_POST \n KK-W-GEN-03 = $TOTAL_UNIQ_LOGIN \n KK-W-GEN-04 = $TOTAL_LOGIN \n KK-W-GEN-02 = $TOTAL_REGISTER_WEEK \n KK-W-GEN-01 = $TOTAL_MEMBER \n\n\n NEW REPORT, APPLY AFTER THIS WEEK \n\n KK-W-GEN-05-01(Registered) = $TOTAL_PM_01_SEND \n KK-W-GEN-05-02(Users Awaiting Email Confirmation) = $TOTAL_PM_02_SEND \n KK-W-GEN-05-03(Donator 5$) = $TOTAL_PM_03_SEND \n KK-W-GEN-05-04(Banned Users) = $TOTAL_PM_04_SEND \n KK-W-GEN-05-05(Spammer) = $TOTAL_PM_05_SEND \n KK-W-GEN-05-06(Moderator) = $TOTAL_PM_06_SEND \n KK-W-GEN-05-07(Special Users) = $TOTAL_PM_07_SEND \n KK-W-GEN-06-01(Registered) = $TOTAL_PM_01_USER \n KK-W-GEN-06-02(Users Awaiting Email Confirmation) = $TOTAL_PM_02_USER \n KK-W-GEN-06-03(Donator 5$) = $TOTAL_PM_03_USER \n KK-W-GEN-06-04(Banned Users) = $TOTAL_PM_04_USER \n KK-W-GEN-06-05(Spammer) = $TOTAL_PM_05_USER \n KK-W-GEN-06-06(Moderator) = $TOTAL_PM_06_USER \n KK-W-GEN-06-07(Special Users) = $TOTAL_PM_07_USER \n KK-W-GEN-07 = $TOTAL_PM_SEND \n KK-W-DEM-01-01(male) = $TOTAL_GENDER_L \n KK-W-DEM-01-02(female) = $TOTAL_GENDER_P \n KK-W-DEM-02-01 = $TOTAL_AGE_15 \n KK-W-DEM-02-02 = $TOTAL_AGE_1620 \n KK-W-DEM-02-03 = $TOTAL_AGE_2125 \n KK-W-DEM-02-04 = $TOTAL_AGE_2630 \n KK-W-DEM-02-05 = $TOTAL_AGE_3135 \n KK-W-DEM-02-06 = $TOTAL_AGE_3640 \n KK-W-DEM-02-07 = $TOTAL_AGE_4145 \n KK-W-DEM-02-08 = $TOTAL_AGE_4650 \n KK-W-DEM-02-09 = $TOTAL_AGE_5155 \n KK-W-DEM-02-10 = $TOTAL_AGE_5660 \n KK-W-DEM-02-11 = $TOTAL_AGE_6165 \n KK-W-DEM-02-12 = $TOTAL_AGE_66 \n\n\n\n Regards, \n DBA" -s 172.16.0.5 > /dev/null  2>&1


echo 1 $TOTAL_ACTIVE_USER
echo 2 $TOTAL_USER_FORUM_THREAD
echo 3 $TOTAL_USER_FORUM_POST
echo 4 $TOTAL_USER_ACTIVE_FORUM
echo 5 $TOTAL_USER_FJB_THREAD
echo 6 $TOTAL_USER_FJB_POST
echo 7 $TOTAL_USER_ACTIVE_FJB
echo 8 $TOTAL_THREAD_FORUM
echo 9 $TOTAL_THREAD_FJB_WTS
echo 10 $TOTAL_THREAD_FJB_WTB
echo 11 $TOTAL_THREAD_FJB_MISC
echo 12 $TOTAL_POST
echo 13 $TOTAL_UNIQ_LOGIN
echo 14 $TOTAL_LOGIN
echo 15 $TOTAL_REGISTER_WEEK
echo 16 $TOTAL_MEMBER


