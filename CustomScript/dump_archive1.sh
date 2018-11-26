for i in `cat temp_archive/list_thread_archive.txtaa`
do
mongoexport -d kaskus_forum1 -c thread -q "{ _id : ObjectId('$i') }" >> temp_archive/thread_archive1.json
mongoexport -d kaskus_forum1 -c post -q "{thread_id:'$i'}" >> temp_archive/post_archive_raw.json
echo "thread $i archived" >> temp_archive/log_archive_raw.log
done
