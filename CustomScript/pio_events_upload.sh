diruniq="/home/rully/uniq_threadpio"
datadir=/home/rully/data_pio
cat $diruniq/uniq_thread* |sort |uniq > $diruniq/uniq_thread_view.txt
pio_accesskey="$1"
rm $datadir/splitter/* 2> /dev/null
for i in `ls $datadir |grep -v splitter`
do
split -l 5000 $datadir/$i $datadir/splitter/$i
for j in `ls $datadir/splitter/$i*`
do
file_count=`cat $j |wc -l`
for k in `seq 1 $file_count`
do
data=`sed -n $k'p' $j`
#curl -i -X POST http://47.74.153.10:7070/batch/events.json?accessKey=ur-tr-weekly-access-key -H "Content-Type: application/json" -d "$data"
curl -i -X POST http://47.74.153.10:7070/batch/events.json?accessKey=$pio_accesskey -H "Content-Type: application/json" -d "$data"
status=`cat /home/rully/proc_killer.txt`
if [ $status = 0 ]
then
break
fi
date > /home/rully/end_time.txt
done &
done
done

#line_counter=`cat $diruniq/uniq_thread_view.txt | grep -v '[g-zG-Z+%&$.]' |wc -l`
#> $diruniq/uniq_thread_clean.json
#mod_counter=`expr $line_counter % 50`
#var_looper=`expr $line_counter / 50`
#if [ $mod_counter != 0 ]
#then
#var_plus=1
#else
#var_plus=0
#fi
#seq_loop=`expr $var_looper + $var_plus`
#for i in `seq 1 $seq_loop`
#do
#sed_start=`expr $i \* 50 + 1 - 50`
#sed_end=`expr $i \* 50`
#cat $diruniq/uniq_thread_view.txt | grep -v '[g-zG-Z+%&$.]' |sed -n $sed_start,$sed_end'p' |sed "s@^@ObjectId('@g;s@\$@')@g" |sed ':a;N;$!ba;s/\n/,/g' > $diruniq/test.test
#var_threadid=`cat $diruniq/test.test`
#/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.aggregate([{\$match:{_id:{\$in:[$var_threadid]}}},{\$project:{_id:0,event:{\$literal:'\$set'},entityType:{\$literal:'item'},entityId:'\$_id',properties:{forumid:'\$forum_id',view:'\$views',rating:{\$divide:[{\$multiply:['\$vote_total',99]},{\$add:[{\$multiply:['\$vote_num',99]},1]}]},share:{\$add:['\$socialMediacounter.share_fb','\$socialMediacounter.share_gplus']}}}},{\$project:{event:1,entityType:1,entityId:1,'properties.forumid':1,'properties.view':1,'properties.rating':{\$cond:[{\$gte:['\$properties.rating',4.5]},5,{\$cond:[{\$gte:['\$properties.rating',3.5]},4,{\$cond:[{\$gte:['\$properties.rating',2.5]},3,{\$cond:[{\$gte:['\$properties.rating',1.5]},2,{\$cond:[{\$gte:['\$properties.rating',0.5]},1,0]}]}]}]}]},'properties.share':1}}]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s/{\n\t"event"/{ "event"/g;s@,\n\t"entityType"@, "entityType"@g;s@,\n\t"entityId"@, "entityId"@g;s@,\n\t"properties"@, "properties"@g;s@{\n\t\t"forumid"@{ "forumid"@g;s@,\n\t\t"view"@, "view"@g;s@,\n\t\t"rating"@, "rating"@g;s@,\n\t\t"share"@, "share"@g;s@\n\t}@ }@g;s@}\n}@} }@g' |sed 's@ObjectId(@@g;s@), "properties"@, "properties"@g;s@NumberLong(@@g;s@), "view"@, "view"@g;s@), "rating"@, "rating"@g;s@"forumid" : @"forumid" : "@g;s@, "view"@", "view"@g;s@) } }@ } }@g;s@, "share" : null@@g;s@, "rating" : 0@@g' |grep -v 'Error: invalid object id\|at (shell eval)\|SyntaxError: Unexpected token' >> $diruniq/uniq_thread_clean.json
#done

#line_counter=`cat $diruniq/uniq_thread_clean.json |wc -l`
#mod_counter=`expr $line_counter % 50`
#var_looper=`expr $line_counter / 50`
#> $diruniq/clean_uniq_thread_clean.json
#if [ $mod_counter != 0 ]
#then
#var_plus=1
#else
#var_plus=0
#fi
#seq_loop=`expr $var_looper + $var_plus`
#for j in `seq 1 $seq_loop`
#do
#sed_start=`expr $j \* 50 + 1 - 50`
#sed_end=`expr $j \* 50`
#sed -n $sed_start,$sed_end'p' $diruniq/uniq_thread_clean.json |sed ':a;N;$!ba;s/\n/,/g;s@^@[@g;s@$@]@g' >> $diruniq/clean_uniq_thread_clean.json
#done

#rm $diruniq/splitter/* 2> /dev/null
#split -l 10000 $diruniq/clean_uniq_thread_clean.json $diruniq/splitter/clean_uniq_thread_clean.json
#for j in `ls $diruniq/splitter/clean_uniq_thread_clean.json*`
#do
#file_count=`cat $j |wc -l`
#for k in `seq 1 $file_count`
#do
#data=`sed -n $k'p' $j`
#curl -i -X POST http://47.74.153.10:7070/batch/events.json?accessKey=ur-tr-weekly-access-key -H "Content-Type: application/json" -d "$data"
#status=`cat /home/rully/proc_killer.txt`
#if [ $status = 0 ]
#then
#break
#fi
#date > end_time.txt
#done &
#done


