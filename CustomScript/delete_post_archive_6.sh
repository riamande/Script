for i in `cat temp_archive/log_post_todelete.log2aa`
do
for j in `cat webserver.txt`
do
mongo $j/kaskus_forum1 --eval "$i"
echo " post in thread : `echo $i |cut -d'"' -f2 |cut -d'"' -f1` deleted " >> temp_archive/log_delete_post.log
done
done &


for k in `cat temp_archive/log_post_todelete.log2ab`
do
for l in `cat webserver.txt`
do
mongo $l/kaskus_forum1 --eval "$k"
echo " post in thread : `echo $k |cut -d'"' -f2 |cut -d'"' -f1` deleted " >> temp_archive/log_delete_post.log
done
done &

for m in `cat temp_archive/log_post_todelete.log2ac`
do
for n in `cat webserver.txt`
do
mongo $n/kaskus_forum1 --eval "$m"
echo " post in thread : `echo $m |cut -d'"' -f2 |cut -d'"' -f1` deleted " >> temp_archive/log_delete_post.log
done
done &
