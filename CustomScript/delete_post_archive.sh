for i in `cat temp_archive/log_post_todelete.logaa`
do
for j in `cat webserver.txt`
do
mongo $j/kaskus_forum1 --eval "$i"
echo " post in thread : `echo $i |cut -d'"' -f2 |cut -d'"' -f1` deleted " >> temp_archive/log_delete_post.log
done
done &


for k in `cat temp_archive/log_post_todelete.logab`
do
for l in `cat webserver.txt`
do
mongo $l/kaskus_forum1 --eval "$k"
echo " post in thread : `echo $k |cut -d'"' -f2 |cut -d'"' -f1` deleted " >> temp_archive/log_delete_post.log
done
done &
