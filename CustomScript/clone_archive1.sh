for i in `cat temp_archive/list_thread_archive.txtaa`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtab`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtac`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtad`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtae`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtaf`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtag`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtah`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtai`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtaj`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtak`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtal`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtam`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &


for i in `cat temp_archive/list_thread_archive.txtan`
do
#mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
for a in `cat list_shard_member.log`
do
ipsh=`mongo $a --eval "printjson(rs.status())" |grep '"name"\|"stateStr"' |sed -e 's$\t$$g' |sed ':a;N;$!ba;s/\n"stateStr"/"stateStr"/g' |grep PRIMARY |cut -d ',' -f1 |cut -d':' -f2,3 |cut -d'"' -f2`
mongo 172.20.0.245/kaskus_forum1 --eval "db.runCommand({ cloneCollection: 'kaskus_forum1.thread', from: '$ipsh', query: { _id : ObjectId('$i') }})"
done
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done &
