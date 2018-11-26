host="172.16.0.88";
url="/home/rully/"
thread="'53f74345a09a3955758b4575'";

#(periode 14 May - 11 June)
#14 May 2014
awal="1400000400";
#11 June 2014
akhir="1402419600";

#(periode 28 - 29 May)
# 28  May 2014
awal2="1404666000";
# 29  June 2014
akhir2="1405357199";

#wap=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,from:'wap'}).length" |grep -v MongoDB|grep -v connecting`
#wap2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,from:'wap'}).count()" |grep -v MongoDB|grep -v connecting`
#web=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,from:{\\$exists:0}}).length" |grep -v MongoDB|grep -v connecting`
#web2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,from:{\\$exists:0}}).count()" |grep -v MongoDB|grep -v connecting`
#app=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,from:/^app/}).length" |grep -v MongoDB|grep -v connecting`
#app2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,from:/^app/}).count()" |grep -v MongoDB|grep -v connecting`

#p2_wap=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,dateline:{\\$gte:$awal2,\\$lte:$akhir2},from:'wap'}).length" |grep -v MongoDB|grep -$
#p2_wap2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,dateline:{\\$gte:$awal2,\\$lte:$akhir2},from:'wap'}).count()" |grep -v MongoDB|grep -v connecting`
#p2_web=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,dateline:{\\$gte:$awal2,\\$lte:$akhir2},from:{\\$exists:0}}).length" |grep -v MongoD$
#p2_web2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,dateline:{\\$gte:$awal2,\\$lte:$akhir2},from:{\\$exists:0}}).count()" |grep -v MongoDB|grep -v connecti$
#p2_app=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,dateline:{\\$gte:$awal2,\\$lte:$akhir2},from:/^app/}).length" |grep -v MongoDB|grep $
#p2_app2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,dateline:{\\$gte:$awal2,\\$lte:$akhir2},from:/^app/}).count()" |grep -v MongoDB|grep -v connecting`


p2_wap=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,from:'wap'}).length" |grep -v MongoDB|grep -v connecting`
p2_wap2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,from:'wap'}).count()" |grep -v MongoDB|grep -v connecting`
p2_web=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,from:{\\$exists:0}}).length" |grep -v MongoDB|grep -v connecting`
p2_web2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,from:{\\$exists:0}}).count()" |grep -v MongoDB|grep -v connecting`
p2_app=`mongo $host/kaskus_forum1 --eval "db.post.distinct(\"post_userid\",{thread_id:$thread,from:/^app/}).length" |grep -v MongoDB|grep -v connecting`
p2_app2=`mongo $host/kaskus_forum1 --eval "db.post.find({thread_id:$thread,from:/^app/}).count()" |grep -v MongoDB|grep -v connecting`


echo "------------------------------------------------------" >> $url/hasil.txt
echo "Thread ID : "$thread >> $url/hasil.txt
echo "------------------------------------------------------" >> $url/hasil.txt
#echo "Periode 14 May 2014 - 11 June 2014" >> $url/hasil.txt
#echo "[ WAP ] Total Unique Replies : " $wap >> $url/hasil.txt
#echo "[ WAP ] Total Replies : " $wap2 >> $url/hasil.txt
#echo "[ WEB ] Total Unique Replies : " $web >> $url/hasil.txt
#echo "[ WEB ] Total Replies : " $web2 >> $url/hasil.txt
#echo "[ MOBILE APPS ] Total Unique Replies : "$app >> $url/hasil.txt
#echo "[ MOBILE APPS ] Total Replies : "$app2 >> $url/hasil.txt

echo " " >> $url/hasil.txt

#echo "Periode 28 May 2014 - 29 May 2014" >> $url/hasil.txt
echo "[ WAP ] Total Unique Replies : " $p2_wap >> $url/hasil.txt
echo "[ WAP ] Total Replies : " $p2_wap2 >> $url/hasil.txt
echo "[ WEB ] Total Unique Replies : " $p2_web >> $url/hasil.txt
echo "[ WEB ] Total Replies : " $p2_web2 >> $url/hasil.txt
echo "[ MOBILE APPS ] Total Unique Replies : "$p2_app >> $url/hasil.txt
echo "[ MOBILE APPS ] Total Replies : "$p2_app2 >> $url/hasil.txt




