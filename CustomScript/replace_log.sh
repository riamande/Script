cp temp_archive/log_archive_raw.log temp_archive/log_thread_todelete.log
cp temp_archive/log_thread_todelete.log temp_archive/log_post_todelete.log
sed -i 's$thread $db.thread.remove({_id:ObjectId("$g' temp_archive/log_thread_todelete.log
sed -i 's$ archived$")});$g' temp_archive/log_thread_todelete.log
sed -i 's$thread $db.post.remove({thread_id:"$g' temp_archive/log_post_todelete.log
sed -i 's$ archived$"});$g' temp_archive/log_post_todelete.log

