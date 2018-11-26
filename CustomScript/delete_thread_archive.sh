for i in `cat temp_archive/log_thread_todelete.log`
do
mongo kaskus_forum1 --eval "$i"
echo " thread `echo $i |cut -d'"' -f2 |cut -d'"' -f1` deleted " >> temp_archive/log_delete_thread.log
done
