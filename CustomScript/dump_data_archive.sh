for i in `cat list_thread_archive.txt`
do
mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive.json

mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive.json
#mongoexport -d kaskus_forum1 -c post -q "{thread_id:ObjectId('$i')}" >> temp_archive/post_archive.json

echo "thread $i archived" >> temp_archive/log_archive.log
done
