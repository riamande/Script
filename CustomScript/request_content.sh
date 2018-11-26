start_date=`date -d $1 +%s`
end_date=`date -d $2 +%s`

mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$nin:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,196,216,302,660,657,658,659,311,215,257,310,197,218,219,296,151,210,527,574,381,573,212,286,287,448,288,202,269,268,553,631,284,603,285,293,605,294,604,299,198,261,231,262,444,606,233,291,590,292,676,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,208,334,209,333,206,207,256,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,677]},dateline:{\$gte:$start_date,\$lte:$end_date},visible:1},{_id:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d':' -f2 |cut -d' ' -f2 |sed -e 's$"$@$g' |sed -e "s/@/'/g" > data_thread_content.txt
echo title'|'link'|'views'|'replies'|'share fb'|'share gplus'|'share twitter'|'avg vote > thread_content.csv
for i in `cat data_thread_content.txt`
do
mongo kaskus_forum1 --eval "db.thread.find({_id:$i},{_id:0,title:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |sed -e 's${ "title" : "$$g' |sed -e 's@" }$@@g' > title.log

echo www.kaskus.co.id/thread/`echo $i |cut -d"'" -f2` > link.log

mongo kaskus_forum1 --eval "db.thread.find({_id:$i},{_id:0,views:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's$) }$$g' > views.log

mongo kaskus_forum1 --eval "db.thread.find({_id:$i},{_id:0,reply_count:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's$) }$$g' > replies.log

a=`mongo kaskus_forum1 --eval "db.thread.find({_id:$i},{_id:0, vote_total:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's$) }$$g'`
b=`mongo kaskus_forum1 --eval "db.thread.find({_id:$i},{_id:0, vote_num:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's$) }$$g'`
c=`expr $a / $b`

d=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('54e4c5345074108a118b4568')},{_id:0, socialMediacounter:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |grep fb |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's/),$//g'`

e=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('54e4c5345074108a118b4568')},{_id:0, socialMediacounter:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |grep gplus |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's/),$//g'`

f=`mongo kaskus_forum1 --eval "db.thread.find({_id:ObjectId('54e4c5345074108a118b4568')},{_id:0, socialMediacounter:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |grep twitter |cut -d':' -f2 |sed -e 's$ NumberLong($$g' |sed -e 's/),$//g'`

echo `cat title.log`'|'`cat link.log`'|'`cat views.log `'|'`cat replies.log`'|'`echo $d`'|'`echo $e`'|'`echo $f`'|'`echo $c` >> thread_content.csv
done
