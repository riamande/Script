INPUT1=$1
STARTDATE_STR=`date -d "1 $INPUT1 ago" +%Y%m%d`
ENDDATE_STR=`date +%Y%m%d`
STARTDATE_UNIXTIMESTAMP=`date -d "$STARTDATE_STR" +%s`
ENDDATE_UNIXTIMESTAMP=`date -d "$ENDDATE_STR" +%s`
DAYSEC=`expr 60 \* 60 \* 24`
DATEDIFFSEC=`expr $ENDDATE_UNIXTIMESTAMP - $STARTDATE_UNIXTIMESTAMP`
DATEFORLOOP=`expr $DATEDIFFSEC / $DAYSEC + 1`
DATESTART_OID=`date -d@$STARTDATE_UNIXTIMESTAMP +"ISODate('%Y-%m-%d %T')"`
DATEEND_OID=`date -d@$ENDDATE_UNIXTIMESTAMP +"ISODate('%Y-%m-%d %T')"`
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
cd /home/rully/product_request
rm mypost_"$INPUT1".json
mongo 172.20.0.230/statistic --eval "db.dropDatabase()"
mongo 172.20.0.230/statistic --eval "db.post_statistic.ensureIndex({dateline:1,visible:1,type_forum:1,from:1})"
mongo 172.20.0.230/statistic --eval "db.thread_statistic.ensureIndex({_id:1,visible:1,gateaction:1})"
mongo 172.20.0.230/statistic --eval "db.post_history.ensureIndex({_id:1,gateaction:1})"
mongo 172.20.0.230/statistic --eval "db.mypost.ensureIndex({forum_id:1})"
FJB_ID=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g' |sed "s@,@','@g" |sed "s@^@'@g" |sed "s@\\$@'@g"`
mongo test --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };objectIdFromDate($DATESTART_OID)" |grep -v 'MongoDB shell version\|connecting to:' > oid_startdate.temp
mongo test --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };objectIdFromDate($DATEEND_OID)" |grep -v 'MongoDB shell version\|connecting to:' > oid_enddate.temp
STARTDATE_OID=`cat oid_startdate.temp`
ENDDATE_OID=`cat oid_enddate.temp`
/opt/mongodb_3.0.10/bin/mongoexport -h 172.16.0.88:27018 -urootdbsharding -pRootDBShardingKK2017 --authenticationDatabase=admin -d kaskus_forum -c post --query "{_id:{\$gte:ObjectId('$STARTDATE_OID'),\$lte:ObjectId('$ENDDATE_OID')}}" > post_"$INPUT1".json
/opt/mongodb_3.0.10/bin/mongoexport -h 172.16.0.88:27018 -urootdbsharding -pRootDBShardingKK2017 --authenticationDatabase=admin -d kaskus_forum -c thread --query "{_id:{\$gte:ObjectId('$STARTDATE_OID'),\$lte:ObjectId('$ENDDATE_OID')}}" > thread_"$INPUT1".json
mongoexport -h 172.20.0.155 -d kaskus_forum_log -c post_history --query "{_id:{\$gte:ObjectId('$STARTDATE_OID'),\$lte:ObjectId('$ENDDATE_OID')}}" > posthistory_"$INPUT1".json
/opt/mongodb_3.0.10/bin/mongoimport -h 172.20.0.230 -d statistic -c post_statistic --file post_"$INPUT1".json
/opt/mongodb_3.0.10/bin/mongoimport -h 172.20.0.230 -d statistic -c thread_statistic --file thread_"$INPUT1".json
mongoimport -h 172.20.0.230 -d statistic -c post_history --file posthistory_"$INPUT1".json
i=0
while [ $i -lt 500 ]
do
mongoexport -h 172.20.0.158 -d kaskus_forum1 -c mypost_$i --query "{_id:{\$gte:ObjectId('$STARTDATE_OID'),\$lte:ObjectId('$ENDDATE_OID')}}" >> mypost_"$INPUT1".json
i=`expr $i + 1`
done
mongoimport -h 172.20.0.230 -d statistic -c mypost --file mypost_"$INPUT1".json
mongo 172.20.0.230/statistic --eval "db.mypost.find({forum_id:{\$in:[$FJB_ID]}},{_id:1,forum_id:1}).snapshot().forEach( function (elem) { db.post_statistic.update( { _id: elem._id }, { \$set: { forum_id: elem.forum_id, type_forum: 'fjb' } } ); } );"
mongo 172.20.0.230/statistic --eval "db.mypost.find({forum_id:{\$nin:[$FJB_ID]}},{_id:1,forum_id:1}).snapshot().forEach( function (elem) { db.post_statistic.update( { _id: elem._id }, { \$set: { forum_id: elem.forum_id, type_forum: 'forum' } } ); } );"
echo '"DATE","UNAPPROVED.FJB.WAP","UNAPPROVED.FJB.APP","UNAPPROVED.FJB.WEB","UNAPPROVED.FORUM.WAP","UNAPPROVED.FORUM.APP","UNAPPROVED.FORUM.WEB","APPROVED.FJB.WAP","APPROVED.FJB.APP","APPROVED.FJB.WEB","APPROVED.FORUM.WAP","APPROVED.FORUM.APP","APPROVED.FORUM.WEB","DELETED.FJB.WAP","DELETED.FJB.APP","DELETED.FJB.WEB","DELETED.FORUM.WAP","DELETED.FORUM.APP","DELETED.FORUM.WEB","MOVED.FJB.WAP","MOVED.FJB.APP","MOVED.FJB.WEB","MOVED.FORUM.WAP","MOVED.FORUM.APP","MOVED.FORUM.WEB","SPAM.FJB.WAP","SPAM.FJB.APP","SPAM.FJB.WEB","SPAM.FORUM.WAP","SPAM.FORUM.APP","SPAM.FORUM.WEB"' > post_breakdown_"$ENDDATE_STR".csv
echo '"DATE","FJB","FORUM"' > posthistory_breakdown_"$ENDDATE_STR".csv
echo '"DATE","FJB.UNAPPROVED","FJB.APPROVED","FJB.DELETED","FJB.MOVED","FJB.SPAM","FORUM.UNAPPROVED","FORUM.APPROVED","FORUM.DELETED","FORUM.MOVED","FORUM.SPAM"' > thread_breakdown_"$ENDDATE_STR".csv
echo '"DATE","TOTAL"' > user_registration_"$ENDDATE_STR".csv
i=1
while [ $i -lt $DATEFORLOOP ]
do
DATESTART=`date -d "$i day ago" +%s`
DATEEND=`expr $DATESTART + $DAYSEC`
DATESTART_STR=`date -d@$DATESTART "+%Y-%m-%d"`
DATESTARTOID=`date -d@$DATESTART +"ISODate('%Y-%m-%d %T')"`
DATEENDOID=`date -d@$DATEEND +"ISODate('%Y-%m-%d %T')"`
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:0,type_forum:'fjb',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis0fjbwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:0,type_forum:'fjb',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis0fjbapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:0,type_forum:'fjb',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis0fjbweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:0,type_forum:'forum',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis0frmwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:0,type_forum:'forum',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis0frmapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:0,type_forum:'forum',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis0frmweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:1,type_forum:'fjb',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis1fjbwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:1,type_forum:'fjb',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis1fjbapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:1,type_forum:'fjb',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis1fjbweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:1,type_forum:'forum',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis1frmwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:1,type_forum:'forum',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis1frmapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:1,type_forum:'forum',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis1frmweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:2,type_forum:'fjb',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis2fjbwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:2,type_forum:'fjb',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis2fjbapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:2,type_forum:'fjb',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis2fjbweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:2,type_forum:'forum',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis2frmwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:2,type_forum:'forum',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis2frmapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:2,type_forum:'forum',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis2frmweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:3,type_forum:'fjb',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis3fjbwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:3,type_forum:'fjb',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis3fjbapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:3,type_forum:'fjb',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis3fjbweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:3,type_forum:'forum',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis3frmwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:3,type_forum:'forum',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis3frmapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:3,type_forum:'forum',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis3frmweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:4,type_forum:'fjb',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis4fjbwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:4,type_forum:'fjb',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis4fjbapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:4,type_forum:'fjb',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis4fjbweb.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:4,type_forum:'forum',from:'wap'})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis4frmwap.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:4,type_forum:'forum',from:/app/})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis4frmapp.txt
mongo 172.20.0.230/statistic --eval "db.post_statistic.count({dateline:{\$gte:$DATESTART,\$lt:$DATEEND},visible:4,type_forum:'forum',from:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > countpostvis4frmweb.txt
post0fjbwap=`cat countpostvis0fjbwap.txt`
post0fjbapp=`cat countpostvis0fjbapp.txt`
post0fjbweb=`cat countpostvis0fjbweb.txt`
post0frmwap=`cat countpostvis0frmwap.txt`
post0frmapp=`cat countpostvis0frmapp.txt`
post0frmweb=`cat countpostvis0frmweb.txt`
post1fjbwap=`cat countpostvis1fjbwap.txt`
post1fjbapp=`cat countpostvis1fjbapp.txt`
post1fjbweb=`cat countpostvis1fjbweb.txt`
post1frmwap=`cat countpostvis1frmwap.txt`
post1frmapp=`cat countpostvis1frmapp.txt`
post1frmweb=`cat countpostvis1frmweb.txt`
post2fjbwap=`cat countpostvis2fjbwap.txt`
post2fjbapp=`cat countpostvis2fjbapp.txt`
post2fjbweb=`cat countpostvis2fjbweb.txt`
post2frmwap=`cat countpostvis2frmwap.txt`
post2frmapp=`cat countpostvis2frmapp.txt`
post2frmweb=`cat countpostvis2frmweb.txt`
post3fjbwap=`cat countpostvis3fjbwap.txt`
post3fjbapp=`cat countpostvis3fjbapp.txt`
post3fjbweb=`cat countpostvis3fjbweb.txt`
post3frmwap=`cat countpostvis3frmwap.txt`
post3frmapp=`cat countpostvis3frmapp.txt`
post3frmweb=`cat countpostvis3frmweb.txt`
post4fjbwap=`cat countpostvis4fjbwap.txt`
post4fjbapp=`cat countpostvis4fjbapp.txt`
post4fjbweb=`cat countpostvis4fjbweb.txt`
post4frmwap=`cat countpostvis4frmwap.txt`
post4frmapp=`cat countpostvis4frmapp.txt`
post4frmweb=`cat countpostvis4frmweb.txt`
echo '"'$DATESTART_STR'","'$post0fjbwap'","'$post0fjbapp'","'$post0fjbweb'","'$post0frmwap'","'$post0frmapp'","'$post0frmweb'","'$post1fjbwap'","'$post1fjbapp'","'$post1fjbweb'","'$post1frmwap'","'$post1frmapp'","'$post1frmweb'","'$post2fjbwap'","'$post2fjbapp'","'$post2fjbweb'","'$post2frmwap'","'$post2frmapp'","'$post2frmweb'","'$post3fjbwap'","'$post3fjbapp'","'$post3fjbweb'","'$post3frmwap'","'$post3frmapp'","'$post3frmweb'","'$post4fjbwap'","'$post4fjbapp'","'$post4fjbweb'","'$post4frmwap'","'$post4frmapp'","'$post4frmweb'"' >> post_breakdown_"$ENDDATE_STR".csv
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.post_history.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},gateaction:{\$exists:true}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempposthisfjb.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.post_history.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},gateaction:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempposthisfrm.txt
posthisfjb=`cat tempposthisfjb.txt`
posthisfrm=`cat tempposthisfrm.txt`
echo '"'$DATESTART_STR'","'$posthisfjb'","'$posthisfrm'"' >> posthistory_breakdown_"$ENDDATE_STR".csv
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:0,gateaction:{\$exists:true}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread0fjb.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:1,gateaction:{\$exists:true}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread1fjb.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:2,gateaction:{\$exists:true}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread2fjb.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:3,gateaction:{\$exists:true}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread3fjb.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:4,gateaction:{\$exists:true}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread4fjb.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:0,gateaction:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread0frm.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:1,gateaction:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread1frm.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:2,gateaction:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread2frm.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:3,gateaction:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread3frm.txt
mongo 172.20.0.230/statistic --eval "var objectIdFromDate = function (date) { return Math.floor(date.getTime() / 1000).toString(16) + '0000000000000000'; };a=objectIdFromDate($DATESTARTOID);b=objectIdFromDate($DATEENDOID);db.thread_statistic.count({_id:{\$gte:ObjectId(a),\$lt:ObjectId(b)},visible:4,gateaction:{\$exists:false}})" |grep -v 'MongoDB shell version\|connecting to: ' > tempthread4frm.txt
thread0fjb=`cat tempthread0fjb.txt`
thread1fjb=`cat tempthread1fjb.txt`
thread2fjb=`cat tempthread2fjb.txt`
thread3fjb=`cat tempthread3fjb.txt`
thread4fjb=`cat tempthread4fjb.txt`
thread0frm=`cat tempthread0frm.txt`
thread1frm=`cat tempthread1frm.txt`
thread2frm=`cat tempthread2frm.txt`
thread3frm=`cat tempthread3frm.txt`
thread4frm=`cat tempthread4frm.txt`
echo '"'$DATESTART_STR'","'$thread0fjb'","'$thread1fjb'","'$thread2fjb'","'$thread3fjb'","'$thread4fjb'","'$thread0frm'","'$thread1frm'","'$thread2frm'","'$thread3frm'","'$thread4frm'"' >> thread_breakdown_"$ENDDATE_STR".csv
mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS user -r -s -N -e "select count(*) from userinfo where joindate >= $DATESTART and joindate < $DATEEND and usergroupid not in (1,3);" > tempusercreation.txt
usercreation=`cat tempusercreation.txt`
echo '"'$DATESTART_STR'","'$usercreation'"' >> user_registration_"$ENDDATE_STR".csv
i=`expr $i + 1`
done
ENDDATE_MOD=`date -d "$ENDDATE_STR 1 day ago" +%Y%m%d`
sendemail -f statistic@kaskusnetworks.com -t sandy.soesilo@kaskusnetworks.com,ardy.alam@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY FORUM STATISTIC" -m "STATISTIC PER $STARTDATE_STR s/d $ENDDATE_MOD \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a post_breakdown_"$ENDDATE_STR".csv posthistory_breakdown_"$ENDDATE_STR".csv thread_breakdown_"$ENDDATE_STR".csv user_registration_"$ENDDATE_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "WEEKLY FORUM STATISTIC" -m "STATISTIC PER $STARTDATE_STR s/d $ENDDATE_MOD \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a post_breakdown_"$ENDDATE_STR".csv posthistory_breakdown_"$ENDDATE_STR".csv thread_breakdown_"$ENDDATE_STR".csv user_registration_"$ENDDATE_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
