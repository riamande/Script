tanggal=`date "+%s"`
tanggal_date=`date -d @$tanggal "+%Y-%m-%d %H:%M:%S"`
rangeweek=`expr 3600 \* 24 \* 7`
lastweek=`expr $tanggal - $rangeweek`
lastweek_date=`date -d @$lastweek "+%Y-%m-%d %H:%M:%S"`
kaskus_misc="172.20.0.91"
temp_mongo_script="/home/rully"
MYSQL_USER="kaskus_fight"
MYSQL_PASS="tryITharder1990"

echo "mongo $kaskus_misc/kaskus_user_log --eval 'db.userloginlog.count({datetime:{\$lte:\"$tanggal_date\",\$gte:\"$lastweek_date\"}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'a=ObjectId();b=db.post.findOne({dateline:{\$gte:$lastweek}},{_id:1});db.post.count({_id:{\$lte:a,\$gte:b._id}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$nin:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]}})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]},prefix_id:\"WTS\"})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]},prefix_id:\"WTB\"})'" >> $temp_mongo_script/tempmongoscript.sh

echo "mongo kaskus_forum1 --eval 'db.thread.count({last_post:{\$gte:$lastweek,\$lte:$tanggal},forum_id:{\$in:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]},prefix_id:{\$nin:[\"WTS\",\"WTB\"]}})'" >> $temp_mongo_script/tempmongoscript.sh

chmod 700 $temp_mongo_script/tempmongoscript.sh

$temp_mongo_script/tempmongoscript.sh > $temp_mongo_script/templogmongo.log

rm $temp_mongo_script/tempmongoscript.sh

temp_ttl_user_thread_forum=`mongo kaskus_forum1 --eval 'db.thread.distinct("post_userid",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$nin:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |wc -l`

temp_ttl_user_thread_fjb=`mongo kaskus_forum1 --eval 'db.thread.distinct("post_userid",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$in:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |wc -l`

mongo kaskus_forum1 --eval 'db.thread.distinct("_id",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$nin:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |sed -e 's$ObjectId($$g'|sed -e 's$)$$g' > $temp_mongo_script/list_thread_forum.log

mongo kaskus_forum1 --eval 'db.thread.distinct("_id",{dateline:{$gte:'$lastweek',$lte:'$tanggal'},forum_id:{$in:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,212,196,216,451,450,302,449,624,600,215,257,310,311,197,218,219,296,151,210,527,574,381,573,286,287,448,288,202,269,268,553,284,603,285,293,604,605,294,299,198,261,231,262,444,606,233,291,590,292,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,333,334,206,207,208,256,209,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,273,204,270,566,271,272]}}).forEach(printjson)' |grep -v MongoDB |grep -v connecting |sed -e 's$ObjectId($$g'|sed -e 's$)$$g' > $temp_mongo_script/list_thread_fjb.log

for f in `cat $temp_mongo_script/list_thread_forum.log`
do
mongo kaskus_forum1 --eval 'db.post.distinct("post_userid",{thread_id:'$f'}).forEach(printjson)' |grep -v MongoDB |grep -v connecting > $temp_mongo_script/temp_ttl_usr_forum.log
for g in `cat $temp_mongo_script/temp_ttl_usr_forum.log`
do
echo "db.forum.save({_id:$g});" >> $temp_mongo_script/importforum.JSON
done
#mongo test $temp_mongo_script/importforum.JSON
#rm $temp_mongo_script/importforum.JSON
done

for h in `cat $temp_mongo_script/list_thread_fjb.log `
do
mongo kaskus_forum1 --eval 'db.post.distinct("post_userid",{thread_id:'$h'}).forEach(printjson)' |grep -v MongoDB |grep -v connecting > $temp_mongo_script/temp_ttl_usr_fjb.log
for i in `cat $temp_mongo_script/temp_ttl_usr_fjb.log`
do
echo "db.fjb.save({_id:$i});" >> $temp_mongo_script/importfjb.JSON
done
#mongo test $temp_mongo_script/importfjb.JSON
#rm $temp_mongo_script/importfjb.JSON
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

rm $temp_mongo_script/importforum.JSON
rm $temp_mongo_script/importfjb.JSON

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
TOTAL_POST=`cat $temp_mongo_script/templogmongo.log |sed -n 6p`
TOTAL_UNIQ_LOGIN=`mysql -h 172.20.0.170 -u$MYSQL_USER -p$MYSQL_PASS kaskus_user -N -s -e"select count(*) from userlogin where lastlogin>=$lastweek and lastlogin<=$tanggal;"`
TOTAL_LOGIN=`cat $temp_mongo_script/templogmongo.log |sed -n 3p`
TOTAL_REGISTER_WEEK=`mysql -h 172.20.0.170 -u$MYSQL_USER -p$MYSQL_PASS kaskus_user -N -s -e"select count(*) from userinfo where joindate>=$lastweek and joindate<=$tanggal;"`
TOTAL_MEMBER=`mysql -h 172.20.0.170 -u$MYSQL_USER -p$MYSQL_PASS kaskus_user -N -s -e"select count(*) from userinfo;"`


sendemail -f statistic@kaskusnetworks.com -t yesika.manik@kaskusnetworks.com,dian.marsi@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com,alken@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER $lastweek_date s/d $tanggal_date : \n\n\n TOTAL ACTIVE USERS -> FORUM & FJB = $TOTAL_ACTIVE_USER \n USER -> FORUM -> THREAD = $TOTAL_USER_FORUM_THREAD \n USER -> FORUM -> POST = $TOTAL_USER_FORUM_POST \n USER -> FORUM -> ACTIVE = $TOTAL_USER_ACTIVE_FORUM \n USER -> FJB -> THREAD = $TOTAL_USER_FJB_THREAD \n USER -> FJB -> POST = $TOTAL_USER_FJB_POST \n USER -> FJB -> ACTIVE = $TOTAL_USER_ACTIVE_FJB \n THREAD -> FORUM = $TOTAL_THREAD_FORUM \n THREAD -> FJB -> WTS = $TOTAL_THREAD_FJB_WTS \n THREAD -> FJB -> WTB = $TOTAL_THREAD_FJB_WTB \n THREAD -> FJB -> UNIDENTIFIED = $TOTAL_THREAD_FJB_MISC \n TOTAL POST (FJB & FORUM) = $TOTAL_POST \n LOGIN -> UNIQUE USER = $TOTAL_UNIQ_LOGIN \n LOGIN -> TOTAL LOGIN = $TOTAL_LOGIN \n REGISTERED MEMBER -> NEW REGISTERED = $TOTAL_REGISTER_WEEK \n REGISTERED MEMBER -> TOTAL MEMBER = $TOTAL_MEMBER \n\n\n\n Regards, \n DBA" -s 172.16.0.5 > /dev/null  2>&1


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

